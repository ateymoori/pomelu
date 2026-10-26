import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/platform/platform_info.dart';
import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/stored_preference.dart';
import '../../../hermes/client/session_signals.dart';
import '../../connection/presentation/connection_providers.dart';
import '../../settings/domain/preference_keys.dart';
import '../data/away_store.dart';
import '../data/background_check.dart';
import '../data/connection_service_controller.dart';
import '../data/notification_gateway.dart';

part 'notification_providers.g.dart';

/// System notifications on Android and iOS, silence elsewhere.
@Riverpod(keepAlive: true)
NotificationGateway notificationGateway(Ref ref) {
  final platform = ref.watch(platformInfoProvider);
  if (!platform.isMobile) return const NoopNotificationGateway();
  final gateway = LocalNotificationGateway(platform: platform);
  unawaited(gateway.initialize());
  return gateway;
}

/// Since when the app is away, and what was notified, shared with the
/// background check.
@Riverpod(keepAlive: true)
AwayStore awayStore(Ref ref) => PrefsAwayStore();

/// The periodic check for bot messages; a no-op off Android and iOS.
@Riverpod(keepAlive: true)
BackgroundCheckScheduler backgroundCheckScheduler(Ref ref) =>
    ref.watch(platformInfoProvider).isMobile
    ? WorkmanagerCheckScheduler()
    : const NoopBackgroundCheckScheduler();

/// The "stay connected" service; a no-op off Android.
@Riverpod(keepAlive: true)
ConnectionServiceController connectionServiceController(Ref ref) =>
    ref.watch(platformInfoProvider).canStayConnected
    ? AndroidConnectionServiceController()
    : NoopConnectionServiceController();

/// The non-transcript gateway events (session refs, notices, background
/// results), once per connection.
@Riverpod(keepAlive: true)
SessionSignals sessionSignals(Ref ref) {
  final signals = SessionSignals();
  final client = ref.watch(hermesClientProvider);
  if (client != null) signals.attach(client.events);
  ref.onDispose(() => unawaited(signals.dispose()));
  return signals;
}

/// "Notify me", on by default: the OS permission is the real gate.
@Riverpod(keepAlive: true)
class NotificationsEnabledSetting extends _$NotificationsEnabledSetting
    with StoredFlag {
  @override
  String get key => PreferenceKeys.notificationsEnabled;

  @override
  bool get fallback => true;

  @override
  bool build() => load();
}

/// "Stay connected", on by default: Android cuts a background app off the
/// network within seconds, so without it replies wait until the app is
/// opened again. It costs an ongoing row; the user can turn it off.
@Riverpod(keepAlive: true)
class KeepConnectionAliveSetting extends _$KeepConnectionAliveSetting
    with StoredFlag {
  @override
  String get key => PreferenceKeys.keepConnectionAlive;

  @override
  bool get fallback => true;

  @override
  bool build() => load();
}

/// Whether notifications are allowed, read again on every resume: the
/// user can change it in system settings.
@Riverpod(keepAlive: true)
class NotificationPermission extends _$NotificationPermission {
  @override
  Future<bool> build() {
    final lifecycle = AppLifecycleListener(
      onResume: () => unawaited(refresh()),
    );
    ref.onDispose(lifecycle.dispose);
    return ref.watch(notificationGatewayProvider).hasPermission();
  }

  /// Whether the app has shown the system prompt. Before that, a missing
  /// grant is no refusal: nothing says "Blocked" yet.
  bool wasPrompted() =>
      ref
          .read(keyValueStoreProvider)
          .getBool(PreferenceKeys.notificationsPrompted) ??
      false;

  /// The system prompt; once refused, the standing answer.
  Future<bool> request() async {
    await ref
        .read(keyValueStoreProvider)
        .setBool(PreferenceKeys.notificationsPrompted, true);
    final gateway = ref.read(notificationGatewayProvider);
    await gateway.initialize();
    final granted = await gateway.requestPermission();
    if (ref.mounted) state = AsyncData(granted);
    return granted;
  }

  /// The grant, waited for while it loads: the first read of a process is
  /// no refusal.
  Future<bool> isGranted() async =>
      state.hasValue ? state.requireValue : future;

  Future<void> refresh() async {
    final granted = await ref.read(notificationGatewayProvider).hasPermission();
    if (ref.mounted) state = AsyncData(granted);
  }

  /// The way back after a refused prompt.
  Future<bool> openSystemSettings() =>
      ref.read(notificationGatewayProvider).openSettings();
}
