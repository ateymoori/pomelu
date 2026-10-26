import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/notifications/presentation/notification_providers.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/client/session_signals.dart';
import 'package:hermes/hermes/requests/server_request_router.dart';
import 'package:hermes/hermes/rpc/json_rpc_client.dart';

import '../../support/fake_channel.dart';
import '../../support/memory_stores.dart';
import 'notification_center_harness.dart';

void main() {
  // The harness reads `binding` lazily; initialize it before the first test.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel = FakeChannel();
    rpc = JsonRpcClient(channel);
    router = ServerRequestRouter()..attach(rpc);
    gateway = FakeGateway();
    service = FakeService();
    signals = SessionSignals();
    kv = MemoryKeyValueStore();
    away = MemoryAwayStore();
    scheduler = FakeCheckScheduler();
  });

  tearDown(() async {
    if (binding.lifecycleState != AppLifecycleState.resumed) comeBack();
    await router.dispose();
    await rpc.close();
  });

  group('the foreground service', () {
    test('starts when the switch is on and a gateway is set up', () async {
      await mount(prefs: keepAliveOn);

      expect(service.calls, ['start']);
    });

    test('runs through a dropped connection: the socket is no input', () async {
      final connection = StreamController<HermesConnectionState>();
      addTearDown(connection.close);
      await mount(prefs: keepAliveOn, connection: connection.stream);

      connection
        ..add(const Connected(replayEpoch: 'e'))
        ..add(const Reconnecting(attempt: 1))
        ..add(const Connecting())
        ..add(const Disconnected());
      await pumpEventQueue();

      expect(service.calls, ['start'], reason: 'never stopped, never redone');
      expect(service.running, isTrue);
    });

    test('stops when the switch goes off', () async {
      final container = await mount(prefs: keepAliveOn);

      await container
          .read(keepConnectionAliveSettingProvider.notifier)
          .set(false);
      await pumpEventQueue();

      expect(service.calls, ['start', 'stop']);
    });

    test('stops on sign-out, and starts again on sign-in', () async {
      final container = await mount(
        prefs: {
          ...keepAliveOn,
          PreferenceKeys.gatewayAuthMode: 'basic',
          PreferenceKeys.gatewayUsername: 'ada',
        },
        credential: const BearerCredential(accessToken: 'at', username: 'ada'),
      );
      expect(service.calls, ['start']);

      await container
          .read(credentialProvider.notifier)
          .set(const NoCredential());
      await pumpEventQueue();
      expect(service.calls, ['start', 'stop']);

      await container
          .read(credentialProvider.notifier)
          .set(const BearerCredential(accessToken: 'at2', username: 'ada'));
      await pumpEventQueue();
      expect(service.calls, ['start', 'stop', 'start']);
    });

    test('starts without the notification permission: Android lists it in the '
        'Task Manager then', () async {
      gateway.granted = false;
      final container = await mount(prefs: keepAliveOn);
      expect(service.calls, ['start']);

      // A grant later changes nothing: it already runs.
      gateway.granted = true;
      await container.read(notificationPermissionProvider.notifier).refresh();
      await pumpEventQueue();

      expect(service.calls, ['start']);
    });

    test('waits for the foreground: a background start is not tried', () async {
      goBackground();
      await mount(prefs: keepAliveOn);
      expect(service.calls, isEmpty);

      comeBack();
      await pumpEventQueue();

      expect(service.calls, contains('start'));
    });

    test('is checked against the platform on every resume', () async {
      await mount(prefs: keepAliveOn);
      // The system ended it while the app was away.
      service.running = false;

      goBackground();
      comeBack();
      await pumpEventQueue();

      expect(service.calls, ['start', 'resync', 'start']);
    });
  });

  group('the check for bot messages while away', () {
    test(
      'is asked for once a gateway is set up, withdrawn with the toggle',
      () async {
        final container = await mount(
          prefs: {PreferenceKeys.gatewayUrl: 'http://gw.lan:9119'},
        );
        expect(scheduler.wanted, isTrue);

        await container
            .read(notificationsEnabledSettingProvider.notifier)
            .set(false);
        await pumpEventQueue();
        expect(scheduler.wanted, isFalse);
      },
    );

    test('leaving marks the app away; coming back clears it', () async {
      await mount(prefs: keepAliveOn);
      expect(away.away, isNull);

      goBackground();
      await pumpEventQueue();
      expect(away.away, isNotNull);

      comeBack();
      await pumpEventQueue();
      expect(away.away, isNull);
    });
  });
}
