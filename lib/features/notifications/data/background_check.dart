import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../../core/config/app_config.dart';
import '../../../core/platform/platform_info.dart';
import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/secret_store.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../hermes/api/hermes_api.dart';
import '../../../hermes/client/connection_state.dart';
import '../../../hermes/client/hermes_client.dart';
import '../../../hermes/hermes_log.dart';
import '../../connection/data/credential_storage.dart';
import '../../connection/data/gateway_settings.dart';
import '../../settings/domain/preference_keys.dart';
import '../domain/notification_policy.dart';
import 'away_store.dart';
import 'message_check.dart';
import 'notification_gateway.dart';

/// The periodic check for bot messages while the app is away, as the system
/// schedules it: Android's WorkManager, iOS's background app refresh (iOS
/// picks the moments, from a few times an hour to a few a day). A seam: the
/// plugin needs a real platform.
abstract interface class BackgroundCheckScheduler {
  /// Asks the system for the check when [wanted], else withdraws it.
  Future<void> sync({required bool wanted});
}

class NoopBackgroundCheckScheduler implements BackgroundCheckScheduler {
  const NoopBackgroundCheckScheduler();

  @override
  Future<void> sync({required bool wanted}) async {}
}

class WorkmanagerCheckScheduler implements BackgroundCheckScheduler {
  WorkmanagerCheckScheduler([Workmanager? workmanager])
    : _workmanager = workmanager ?? Workmanager();

  /// The task's id, also in `Info.plist` (`BGTaskSchedulerPermittedIdentifiers`)
  /// and `AppDelegate.swift`.
  static const String task = '${AppConfig.appId}.messageCheck';

  final Workmanager _workmanager;
  Future<void>? _initialized;
  bool? _wanted;

  @override
  Future<void> sync({required bool wanted}) async {
    if (wanted == _wanted) return;
    _wanted = wanted;
    try {
      await (_initialized ??= _workmanager.initialize(backgroundCheckMain));
      if (!wanted) return await _workmanager.cancelByUniqueName(task);
      await _workmanager.registerPeriodicTask(
        task,
        task,
        frequency: AppConfig.messageCheckEvery,
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );
    } on Object catch (e, st) {
      _wanted = null;
      log.w('background check not scheduled', error: e, stackTrace: st);
    }
  }
}

/// The background isolate's entry point.
@pragma('vm:entry-point')
void backgroundCheckMain() {
  Workmanager().executeTask((task, _) async {
    initLogging();
    try {
      await runBackgroundCheck().timeout(AppConfig.messageCheckBudget);
    } on Object catch (e, st) {
      log.w('background check failed', error: e, stackTrace: st);
    }
    // Always done: a failure here is a quiet run, not a reason for the
    // system to retry sooner.
    return true;
  });
}

/// One check, from stored settings alone: no providers, no widgets.
Future<void> runBackgroundCheck() async {
  WidgetsFlutterBinding.ensureInitialized();
  final kv = await SharedPrefsStore.create();
  final config = readGatewayConfig(kv);
  final uri = config?.uri;
  if (config == null || uri == null) return;
  if (!(kv.getBool(PreferenceKeys.notificationsEnabled) ?? true)) return;
  final store = PrefsAwayStore();
  if (await store.awaySince() == null) return;

  final gateway = LocalNotificationGateway(platform: PlatformInfo.host());
  await gateway.initialize();
  final policy = NotificationPolicy(
    enabled: true,
    permissionGranted: await gateway.hasPermission(),
    l10n: platformL10n(),
  );
  if (!policy.canNotify) return;

  final storage = SecureCredentialStorage(SecureSecretStore());
  var credential = await storage.load();
  final client = HermesClient(
    baseUrl: uri,
    credential: () => credential,
    onCredentialRotated: (c) async {
      credential = c;
      await storage.save(c);
    },
    log: (m, [e]) => log.w(
      'hermes (background): ${redactSecrets(m)}',
      error: safeErrorText(e),
    ),
  );
  try {
    final ready = client.states.firstWhere(
      (s) => s is Connected || s is AuthRequired || s is Disconnected,
    );
    unawaited(client.connect());
    if (await ready is! Connected) return;
    await checkMessages(
      api: HermesApi(client),
      store: store,
      gateway: gateway,
      policy: policy,
      account: config.accountKey,
    );
  } finally {
    await client.dispose();
  }
}
