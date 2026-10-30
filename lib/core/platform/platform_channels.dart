import '../config/app_config.dart';

/// The app's own platform channels. The same names are spelled in
/// `android/.../MainActivity.kt` (share, service, shortcuts, push) and
/// `ios/Runner/` (`ShareBridge.swift`: the share pair; `AppDelegate.swift`:
/// reduce transparency, shortcuts; `PushBridge.swift`: the push pair); change
/// them together.
abstract final class PlatformChannels {
  /// Share sheet: `initial` (the share that launched the app).
  static const String share = '${AppConfig.appId}/share';

  /// Share sheet: shares that arrive while the app runs.
  static const String shareEvents = '${AppConfig.appId}/share/events';

  /// The "stay connected" service: `start`, `update`, `stop`, `isRunning`.
  static const String connectionService =
      '${AppConfig.appId}/connection_service';

  /// The bots for the system, `set {items: [{id, title, link?, icon?}]}`
  /// and `used {id}` (the user wrote to it): Android's app icon menu and
  /// Direct Share, iOS's share suggestions.
  static const String shortcuts = '${AppConfig.appId}/shortcuts';

  /// iOS's Reduce Transparency setting: `true`/`false` now and on change.
  static const String reduceTransparency =
      '${AppConfig.appId}/reduce_transparency';

  /// Push (`PushBridge`): `register {newKey}`, `launchBot`.
  static const String push = '${AppConfig.appId}/push';

  /// Push: `{type: token}` and `{type: tap, bot}`.
  static const String pushEvents = '${AppConfig.appId}/push/events';
}
