import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_config.dart';
import '../../../core/platform/app_visibility.dart';
import '../../../core/platform/push_bridge.dart';
import '../../../core/storage/key_value_store.dart';
import '../../../core/utils/app_logger.dart';
import '../../../hermes/client/connection_state.dart';
import '../../../hermes/hermes_failure.dart';
import '../../../hermes/models/push_device.dart';
import '../../connection/presentation/connection_providers.dart';
import '../../settings/domain/preference_keys.dart';
import 'notification_providers.dart';

part 'push_registration.g.dart';

/// Whether the bots' messages reach this phone by push.
enum PushStatus {
  /// Notifications are off, or nothing is set up yet.
  off,

  /// The gateway has no Pomelu plugin, or the phone no push service.
  unavailable,

  /// Registered: a bot's Bot Chat reply rings the phone while the app is
  /// away, without the app running.
  active,
}

/// This phone with the gateway's Pomelu plugin: registered on each
/// connection while notifications are on and allowed, removed when they are
/// turned off. On screen and away are told to the plugin, which pushes only
/// while the app is away.
@Riverpod(keepAlive: true)
class PushRegistration extends _$PushRegistration {
  Future<void>? _running;
  bool _again = false;
  Timer? _beat;

  /// What the plugin has from this phone on this connection; a new
  /// connection registers again (the plugin then also turns itself on for
  /// new bots).
  ({String account, String id, PushDevice device})? _sent;

  @override
  PushStatus build() {
    final bridge = ref.watch(pushBridgeProvider);
    ref.listen(connectionStateProvider, (_, next) {
      if (next.value is! Connected) return;
      _sent = null;
      _syncSoon();
    }, fireImmediately: true);
    ref.listen(notificationsEnabledSettingProvider, (_, _) => _syncSoon());
    ref.listen(notificationPermissionProvider, (_, _) => _syncSoon());
    final tokens = bridge.tokenChanges.listen((_) => _syncSoon());
    final lifecycle = AppLifecycleListener(
      onShow: () => unawaited(_tellPresence()),
      onHide: () => unawaited(_tellPresence()),
    );
    ref.onDispose(() {
      _beat?.cancel();
      lifecycle.dispose();
      unawaited(tokens.cancel());
    });
    return PushStatus.off;
  }

  KeyValueStore get _kv => ref.read(keyValueStoreProvider);

  /// One sync at a time; a change during one runs one more after it.
  void _syncSoon() {
    if (_running != null) {
      _again = true;
      return;
    }
    _running = _sync().whenComplete(() {
      _running = null;
      if (_again && ref.mounted) {
        _again = false;
        _syncSoon();
      }
    });
  }

  Future<void> _sync() async {
    final api = ref.read(hermesApiProvider);
    final account = ref.read(gatewayConfigProvider)?.accountKey;
    if (api == null || account == null) return;
    if (ref.read(connectionStateProvider).value is! Connected) return;
    final wanted =
        ref.read(notificationsEnabledSettingProvider) &&
        await _permissionGranted();
    if (!ref.mounted) return;
    final id = _kv.getString(PreferenceKeys.pushDeviceId);
    final registeredWith = _kv.getString(PreferenceKeys.pushAccount);
    if (!wanted) {
      if (id != null && registeredWith == account) {
        try {
          await api.removePushDevice(id);
        } on HermesFailure catch (e) {
          log.w('push: could not remove this phone', error: e);
        }
        await _kv.remove(PreferenceKeys.pushAccount);
      }
      _sent = null;
      _set(PushStatus.off);
      return;
    }
    // Another account gets a new id and a new key: the old gateway may still
    // send, and must not reach this phone.
    final newAccount = registeredWith != null && registeredWith != account;
    final device = await ref
        .read(pushBridgeProvider)
        .register(newKey: newAccount);
    if (!ref.mounted) return;
    if (device == null) return _set(PushStatus.unavailable);
    final deviceId = (id == null || newAccount) ? const Uuid().v4() : id;
    final sending = (account: account, id: deviceId, device: device);
    if (sending == _sent) return;
    try {
      await api.registerPushDevice(deviceId, device);
    } on NotSupportedFailure {
      log.i('push: the gateway has no Pomelu plugin');
      return _set(PushStatus.unavailable);
    } on HermesFailure catch (e) {
      log.w('push: registration failed', error: e);
      return;
    }
    await _kv.setString(PreferenceKeys.pushDeviceId, deviceId);
    await _kv.setString(PreferenceKeys.pushAccount, account);
    _sent = sending;
    _set(PushStatus.active);
    await _tellPresence();
  }

  void _set(PushStatus status) {
    if (!ref.mounted) return;
    state = status;
    if (status != PushStatus.active) _beat?.cancel();
  }

  /// On screen or away, now; repeated while on screen.
  Future<void> _tellPresence() async {
    _beat?.cancel();
    if (state != PushStatus.active) return;
    final api = ref.read(hermesApiProvider);
    final id = _kv.getString(PreferenceKeys.pushDeviceId);
    if (api == null || id == null) return;
    final visible = appIsVisible;
    if (visible) {
      _beat = Timer(
        AppConfig.pushPresenceBeat,
        () => unawaited(_tellPresence()),
      );
    }
    try {
      await api.setPushPresence(id, visible: visible);
    } on NotSupportedFailure {
      // The plugin forgot this phone (or went): register again.
      _syncSoon();
    } on HermesFailure catch (e) {
      log.w('push: presence not sent', error: e);
    }
  }

  Future<bool> _permissionGranted() async {
    try {
      return await ref
          .read(notificationPermissionProvider.notifier)
          .isGranted();
    } on Object catch (e, st) {
      log.w('notification permission unreadable', error: e, stackTrace: st);
      return false;
    }
  }
}
