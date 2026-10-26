import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/notifications/data/notification_gateway.dart';
import 'package:hermes/features/notifications/domain/app_notification.dart';

import '../../support/throwing.dart';

/// The Android half of the plugin: the channels the app creates, and the
/// screen it opens.
class _Android extends Fake implements AndroidFlutterLocalNotificationsPlugin {
  final List<AndroidNotificationChannel> channels = [];
  Object? settingsError;
  bool? settingsAnswer = true;

  @override
  Future<void> createNotificationChannel(
    AndroidNotificationChannel notificationChannel,
  ) async => channels.add(notificationChannel);

  @override
  Future<bool?> openAppNotificationSettings() async {
    final error = settingsError;
    if (error != null) throwInjected(error);
    return settingsAnswer;
  }
}

/// `flutter_local_notifications` with no platform channel behind it.
class _Plugin extends Fake implements FlutterLocalNotificationsPlugin {
  _Plugin({this.android});

  /// Null: the host has no Android implementation (the VM, a widget test).
  final _Android? android;
  Object? initializeError;
  NotificationAppLaunchDetails? launch;

  int initializes = 0;
  InitializationSettings? settings;
  DidReceiveNotificationResponseCallback? onTap;
  final List<
    ({
      int id,
      String? title,
      String? body,
      NotificationDetails? details,
      String? payload,
    })
  >
  shown = [];
  final List<({int id, String? tag})> cancelled = [];

  @override
  T? resolvePlatformSpecificImplementation<
    T extends FlutterLocalNotificationsPlatform
  >() {
    final Object? a = android;
    return a is T ? a : null;
  }

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async {
    final error = initializeError;
    if (error != null) throwInjected(error);
    initializes++;
    this.settings = settings;
    onTap = onDidReceiveNotificationResponse;
    return true;
  }

  @override
  Future<NotificationAppLaunchDetails?>
  getNotificationAppLaunchDetails() async => launch;

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) async => shown.add((
    id: id,
    title: title,
    body: body,
    details: notificationDetails,
    payload: payload,
  ));

  @override
  Future<void> cancel({required int id, String? tag}) async =>
      cancelled.add((id: id, tag: tag));

  int clearedAll = 0;

  @override
  Future<void> cancelAll() async => clearedAll++;
}

NotificationResponse _tap(String? payload) => NotificationResponse(
  notificationResponseType: NotificationResponseType.selectedNotification,
  payload: payload,
);

const _note = AppNotification(
  id: 7,
  title: 'Atlas',
  body: 'The long answer is ready',
  channelId: NotificationChannels.alerts,
  deepLink: '/chat/atlas',
  tag: 'bg/1',
);

void main() {
  test('initialize wires the taps and the channels, once', () async {
    final android = _Android();
    final plugin = _Plugin(android: android);
    final gateway = LocalNotificationGateway(plugin: plugin);

    await gateway.initialize();
    await gateway.initialize();

    expect(plugin.initializes, 1);
    expect(android.channels.map((c) => (c.id, c.importance)), [
      (NotificationChannels.alerts, Importance.defaultImportance),
      (NotificationChannels.messages, Importance.high),
      (NotificationChannels.connection, Importance.low),
    ]);
  });

  test(
    'a platform without the plugin does nothing, and never throws',
    () async {
      final plugin = _Plugin()..initializeError = UnimplementedError('host');
      final gateway = LocalNotificationGateway(plugin: plugin);

      await gateway.show(_note);
      await gateway.cancel('bg/1');
      await gateway.cancelAll();

      expect(plugin.shown, isEmpty);
      expect(plugin.cancelled, isEmpty);
      expect(plugin.clearedAll, 0);
      expect(await gateway.launchRoute(), isNull);
      expect(await gateway.openSettings(), isFalse);
    },
  );

  test(
    'taps with a route reach the stream; a cold start hands its over once',
    () async {
      final plugin = _Plugin(android: _Android())
        ..launch = NotificationAppLaunchDetails(
          true,
          notificationResponse: _tap('/chat/nova'),
        );
      final gateway = LocalNotificationGateway(plugin: plugin);
      final routes = <String>[];
      gateway.taps.listen(routes.add);

      expect(await gateway.launchRoute(), '/chat/nova');
      expect(await gateway.launchRoute(), isNull);
      plugin.onTap?.call(_tap('/chat/atlas'));
      plugin.onTap?.call(_tap(''));
      await pumpEventQueue();
      expect(routes, ['/chat/atlas']);
    },
  );

  test(
    'show posts under the id, the tag and the route; cancel by tag',
    () async {
      final plugin = _Plugin(android: _Android());
      final gateway = LocalNotificationGateway(plugin: plugin);

      await gateway.show(_note);
      await gateway.cancel('bg/1');

      final post = plugin.shown.single;
      expect(post.id, 7);
      expect(post.payload, '/chat/atlas');
      final android = post.details!.android!;
      expect(android.channelId, NotificationChannels.alerts);
      expect(android.tag, 'bg/1');
      expect(
        (android.styleInformation! as BigTextStyleInformation).bigText,
        'The long answer is ready',
      );
      expect(plugin.cancelled.single, (
        id: AppNotification.idFor('bg/1'),
        tag: 'bg/1',
      ));
    },
  );

  test('a refused settings screen says no instead of throwing', () async {
    final android = _Android()..settingsError = StateError('no activity');
    final gateway = LocalNotificationGateway(plugin: _Plugin(android: android));

    expect(await gateway.openSettings(), isFalse);
  });
}
