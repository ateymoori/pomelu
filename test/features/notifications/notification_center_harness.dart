import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/storage/key_value_store.dart';
import 'package:hermes/core/storage/secret_store.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/notifications/data/connection_service_controller.dart';
import 'package:hermes/features/notifications/data/notification_gateway.dart';
import 'package:hermes/features/notifications/domain/app_notification.dart';
import 'package:hermes/features/notifications/domain/notification_policy.dart';
import 'package:hermes/features/notifications/presentation/active_view_provider.dart';
import 'package:hermes/features/notifications/presentation/notification_center.dart';
import 'package:hermes/features/notifications/presentation/notification_providers.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/client/session_signals.dart';
import 'package:hermes/hermes/requests/server_request_router.dart';
import 'package:hermes/hermes/rpc/json_rpc_client.dart';

import '../../support/fake_channel.dart';
import '../../support/fixtures.dart';
import '../../support/memory_stores.dart';

final Map<String, dynamic> fx = fixtureMap('server_requests.json');

Map<String, dynamic> frame(String name) =>
    (fx['frames'] as Map<String, dynamic>)[name] as Map<String, dynamic>;

const session = 'a1b2c3d4';
const clarifyId = 'srq-3f9a1c2b7d10';

/// Records what the centre posts and retracts.
class FakeGateway implements NotificationGateway {
  final shown = <AppNotification>[];
  final cancelled = <String>[];
  int permissionRequests = 0;
  int settingsOpened = 0;

  /// What the OS says; flip it and resume to model a grant in system settings.
  bool granted = true;

  /// When set, `hasPermission` answers only once this completes: the grant is
  /// still loading.
  Completer<bool>? permissionGate;

  @override
  Future<void> initialize() async {}
  @override
  Future<bool> hasPermission() =>
      permissionGate?.future ?? Future.value(granted);
  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return granted;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }

  @override
  Future<void> show(AppNotification notification) async =>
      shown.add(notification);
  @override
  Future<void> cancel(String tag) async => cancelled.add(tag);

  /// How many times everything was cleared.
  int clearedAll = 0;
  @override
  Future<void> cancelAll() async => clearedAll++;
  @override
  Stream<String> get taps => const Stream.empty();
  @override
  Future<String?> launchRoute() async => null;
}

/// A service that records what it was asked, with the same "latest intent"
/// bookkeeping as the real one.
class FakeService implements ConnectionServiceController {
  final calls = <String>[];
  bool running = false;

  @override
  bool get isSupported => true;
  @override
  bool get isRunning => running;
  @override
  Future<void> start({required String title, required String body}) async {
    calls.add('start');
    running = true;
  }

  /// The words of the last [update].
  String? updatedBody;
  @override
  Future<void> update({required String title, required String body}) async {
    calls.add('update');
    updatedBody = body;
  }

  @override
  Future<void> stop() async {
    if (!running) return;
    calls.add('stop');
    running = false;
  }

  @override
  Future<void> resync() async => calls.add('resync');
}

class _FixedView extends ActiveViewNotifier {
  _FixedView(this._view);
  final ActiveView _view;
  @override
  ActiveView build() => _view;
}

final binding = TestWidgetsFlutterBinding.ensureInitialized();

late FakeChannel channel;

late JsonRpcClient rpc;

late ServerRequestRouter router;

late FakeGateway gateway;

late FakeService service;

late SessionSignals signals;

late MemoryKeyValueStore kv;

late MemoryAwayStore away;

late FakeCheckScheduler scheduler;

/// Walks the lifecycle the way the engine does: one step at a time.
void goBackground() {
  [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ].forEach(binding.handleAppLifecycleStateChanged);
}

void comeBack() {
  [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ].forEach(binding.handleAppLifecycleStateChanged);
}

Future<ProviderContainer> mount({
  ActiveView view = ActiveView.background,
  bool preloadPermission = true,
  Map<String, Object> prefs = const {},
  AuthCredential credential = const NoCredential(),
  Stream<HermesConnectionState>? connection,
}) async {
  kv.values.addAll(prefs);
  final container = ProviderContainer(
    overrides: [
      notificationGatewayProvider.overrideWithValue(gateway),
      serverRequestRouterProvider.overrideWithValue(router),
      hermesClientProvider.overrideWithValue(null),
      keyValueStoreProvider.overrideWithValue(kv),
      secretStoreProvider.overrideWithValue(MemorySecretStore()),
      initialCredentialProvider.overrideWithValue(credential),
      sessionSignalsProvider.overrideWith((ref) => signals),
      connectionServiceControllerProvider.overrideWithValue(service),
      awayStoreProvider.overrideWithValue(away),
      backgroundCheckSchedulerProvider.overrideWithValue(scheduler),
      activeViewProvider.overrideWith(() => _FixedView(view)),
      if (connection != null)
        connectionStateProvider.overrideWith((ref) => connection),
    ],
  );
  addTearDown(container.dispose);
  if (preloadPermission) {
    await container.read(notificationPermissionProvider.future);
  }
  // Watched, as the app root does: an unwatched provider is paused.
  container.listen(notificationCenterProvider, (_, _) {});
  await pumpEventQueue();
  return container;
}

/// Settings for a configured, un-gated gateway with the switch on.
const keepAliveOn = <String, Object>{
  PreferenceKeys.gatewayUrl: 'http://gw.lan:9119',
  PreferenceKeys.keepConnectionAlive: true,
};
