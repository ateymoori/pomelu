import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/platform/app_settings.dart';
import '../../../core/platform/platform_info.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/l10n_ext.dart';
import '../domain/app_notification.dart';

/// Posting and retracting system notifications, and the permission. A seam:
/// the plugin needs a real platform, so tests and other platforms swap it.
abstract interface class NotificationGateway {
  /// Channels and the tap handler. Safe to call more than once.
  Future<void> initialize();

  /// The OS shows what is posted (Android 13+: `POST_NOTIFICATIONS`).
  Future<bool> hasPermission();

  /// The OS prompt. Android shows it once per install; later calls give the
  /// standing answer, so the UI offers [openSettings] too.
  Future<bool> requestPermission();

  /// The app's notification settings; false when none could open.
  Future<bool> openSettings();

  /// Posts, or replaces by id.
  Future<void> show(AppNotification notification);

  /// Retracts the row posted with [tag].
  Future<void> cancel(String tag);

  /// Retracts every row the app posted, for a sign-out or another gateway.
  Future<void> cancelAll();

  /// In-app routes of notification taps.
  Stream<String> get taps;

  /// The route of the tap that cold-started the app, once.
  Future<String?> launchRoute();
}

/// A platform the app posts nothing on: nothing shows, nothing throws.
class NoopNotificationGateway implements NotificationGateway {
  const NoopNotificationGateway();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<bool> openSettings() async => false;

  @override
  Future<void> show(AppNotification notification) async {}

  @override
  Future<void> cancel(String tag) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Stream<String> get taps => const Stream.empty();

  @override
  Future<String?> launchRoute() async => null;
}

/// `flutter_local_notifications`: what the app posts from its socket or from
/// the periodic background check. Pushes are posted natively
/// (`PushService.kt`, the iOS notification extension).
class LocalNotificationGateway implements NotificationGateway {
  LocalNotificationGateway({
    FlutterLocalNotificationsPlugin? plugin,
    PlatformInfo? platform,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _platform = platform ?? PlatformInfo.host();

  final FlutterLocalNotificationsPlugin _plugin;
  final PlatformInfo _platform;
  final _taps = StreamController<String>.broadcast();
  bool _initialized = false;

  /// False once the platform side proved missing: everything is a no-op.
  bool _usable = true;
  String? _launchRoute;

  AndroidFlutterLocalNotificationsPlugin? get _android {
    if (!_usable) return null;
    try {
      return _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
    } on Object {
      _usable = false;
      return null;
    }
  }

  IOSFlutterLocalNotificationsPlugin? get _ios {
    if (!_usable) return null;
    try {
      return _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
    } on Object {
      _usable = false;
      return null;
    }
  }

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(
            NotificationChannels.smallIcon,
          ),
          // The prompt comes from the Notify me switch, not at launch.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) _taps.add(payload);
        },
      );
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        final payload = launch?.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) _launchRoute = payload;
      }
      await _createChannels();
    } on Object catch (error) {
      _usable = false;
      log.i('notifications: platform unavailable ($error)');
    }
  }

  /// Created up front: Android ignores importance changes after the first
  /// post.
  Future<void> _createChannels() async {
    final android = _android;
    if (android == null) return;
    final l10n = platformL10n();
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationChannels.alerts,
        l10n.notificationChannelAlerts,
        description: l10n.notificationChannelAlertsBody,
      ),
    );
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationChannels.messages,
        l10n.notificationChannelMessages,
        description: l10n.notificationChannelMessagesBody,
        importance: Importance.high,
      ),
    );
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationChannels.connection,
        l10n.notificationChannelConnection,
        description: l10n.notificationChannelConnectionBody,
        importance: Importance.low,
        showBadge: false,
      ),
    );
  }

  @override
  Future<bool> hasPermission() async {
    if (_platform.isIOS) {
      final options = await _ios?.checkPermissions();
      return options?.isEnabled ?? false;
    }
    if (!_platform.isAndroid) return true;
    return await _android?.areNotificationsEnabled() ?? false;
  }

  @override
  Future<bool> requestPermission() async {
    final bool granted;
    if (_platform.isIOS) {
      granted =
          await _ios?.requestPermissions(alert: true, sound: true) ?? false;
    } else if (_platform.isAndroid) {
      granted = await _android?.requestNotificationsPermission() ?? false;
    } else {
      return true;
    }
    if (!granted) log.i('notifications: permission not granted');
    return granted;
  }

  @override
  Future<bool> openSettings() async {
    // iOS has no page of its own for notifications: the app's page holds it.
    if (_platform.isIOS) return openAppSettings();
    try {
      return await _android?.openAppNotificationSettings() ?? false;
    } on Object catch (error) {
      log.w('notifications: could not open system settings', error: error);
      return false;
    }
  }

  @override
  Future<void> show(AppNotification n) async {
    await initialize();
    if (!_usable) return;
    final l10n = platformL10n();
    await _plugin.show(
      id: n.id,
      title: n.title,
      body: n.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          n.channelId,
          switch (n.channelId) {
            NotificationChannels.connection =>
              l10n.notificationChannelConnection,
            NotificationChannels.messages => l10n.notificationChannelMessages,
            _ => l10n.notificationChannelAlerts,
          },
          tag: n.tag.isEmpty ? null : n.tag,
          // A long answer needs the expanded style, not one cut line.
          styleInformation: BigTextStyleInformation(n.body),
          category: AndroidNotificationCategory.message,
        ),
        iOS: DarwinNotificationDetails(
          threadIdentifier: n.tag.isEmpty ? null : n.tag,
        ),
      ),
      payload: n.deepLink,
    );
  }

  @override
  Future<void> cancel(String tag) async {
    if (!_usable) return;
    await _plugin.cancel(id: AppNotification.idFor(tag), tag: tag);
  }

  @override
  Future<void> cancelAll() async {
    // Rows of an earlier process are in the shade too.
    await initialize();
    if (!_usable) return;
    try {
      await _plugin.cancelAll();
    } on Object catch (error) {
      log.w('notifications: could not clear', error: error);
    }
  }

  @override
  Future<String?> launchRoute() async {
    await initialize();
    final route = _launchRoute;
    _launchRoute = null;
    return route;
  }
}
