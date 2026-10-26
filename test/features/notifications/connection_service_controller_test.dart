import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/platform/platform_channels.dart';
import 'package:hermes/core/platform/platform_info.dart';
import 'package:hermes/features/notifications/data/connection_service_controller.dart';
import 'package:hermes/features/notifications/data/notification_gateway.dart';
import 'package:hermes/features/notifications/presentation/notification_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(PlatformChannels.connectionService);
  final calls = <MethodCall>[];
  var refuse = false;
  var platformRunning = false;
  Completer<void>? gate;

  setUp(() {
    calls.clear();
    refuse = false;
    platformRunning = false;
    gate = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          final pending = gate;
          gate = null;
          await pending?.future;
          if (refuse) throw PlatformException(code: 'not_allowed');
          return call.method != 'isRunning' || platformRunning;
        });
  });

  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  List<String> methods() => [for (final c in calls) c.method];
  AndroidConnectionServiceController controller() =>
      AndroidConnectionServiceController(channel: channel);

  test('start shows the row once; stop ends it', () async {
    final c = controller();
    await c.start(title: 'Pomelu', body: 'Connected');
    await c.start(title: 'Pomelu', body: 'Connected');
    expect(c.isRunning, isTrue);
    expect(calls.single.arguments, {'title': 'Pomelu', 'body': 'Connected'});

    await c.stop();
    await c.stop();
    expect(c.isRunning, isFalse);
    expect(methods(), ['start', 'stop']);
  });

  test('calls run in order and the latest intent wins', () async {
    final c = controller();
    await Future.wait([c.stop(), c.start(title: 'a', body: 'b'), c.stop()]);
    expect(calls, isEmpty);

    final release = Completer<void>();
    gate = release;
    final started = c.start(title: 'a', body: 'b');
    await pumpEventQueue();
    final stopped = c.stop();
    await pumpEventQueue();
    expect(methods(), ['start'], reason: 'stop waits its turn');
    release.complete();
    await Future.wait([started, stopped]);
    expect(methods(), ['start', 'stop']);
  });

  test('a refused start is not thrown and is tried again', () async {
    final c = controller();
    refuse = true;
    await c.start(title: 'a', body: 'b');
    expect(c.isRunning, isFalse);

    refuse = false;
    await c.start(title: 'a', body: 'b');
    expect(c.isRunning, isTrue);
  });

  test('an unexpected answer ends that call only, not the queue', () async {
    final c = controller();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return calls.length == 1 ? 'not a bool' : true;
        });
    await c.start(title: 'a', body: 'b');
    expect(c.isRunning, isFalse);

    await c.start(title: 'a', body: 'b');
    expect(c.isRunning, isTrue);
    expect(methods(), ['start', 'start']);
  });

  test(
    'resync takes the platform word, so a lost service starts again',
    () async {
      final c = controller();
      await c.start(title: 'a', body: 'b');
      await c.resync();
      expect(c.isRunning, isFalse);

      await c.start(title: 'a', body: 'b');
      expect(methods(), ['start', 'isRunning', 'start']);
    },
  );

  test('update rewords only a running service', () async {
    final c = controller();
    await c.update(title: 'a', body: 'Unreachable');
    expect(calls, isEmpty);

    await c.start(title: 'a', body: 'Connected');
    await c.update(title: 'a', body: 'Unreachable');
    expect(methods(), ['start', 'update']);
    expect(calls.last.arguments, {'title': 'a', 'body': 'Unreachable'});
  });

  test('only Android stays connected; only phones post notifications', () {
    final expected = {
      AppPlatform.android: (AndroidConnectionServiceController, true),
      AppPlatform.ios: (NoopConnectionServiceController, true),
      AppPlatform.other: (NoopConnectionServiceController, false),
    };
    for (final MapEntry(key: platform, value: (service, posts))
        in expected.entries) {
      final container = ProviderContainer(
        overrides: [
          platformInfoProvider.overrideWithValue(PlatformInfo(platform)),
        ],
      );
      addTearDown(container.dispose);
      expect(
        container.read(connectionServiceControllerProvider).runtimeType,
        service,
        reason: platform.name,
      );
      expect(
        container.read(notificationGatewayProvider),
        posts
            ? isA<LocalNotificationGateway>()
            : isA<NoopNotificationGateway>(),
        reason: platform.name,
      );
    }
  });
}
