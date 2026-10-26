import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/notifications/domain/app_notification.dart';
import 'package:hermes/features/notifications/domain/notification_policy.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/client/session_signals.dart';
import 'package:hermes/hermes/events/gateway_event.dart';
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

  group('notifications', () {
    test('a question that arrives posts a notification', () async {
      await mount();

      channel.receive(frame('clarify'));
      await pumpEventQueue();

      expect(gateway.shown, hasLength(1));
      expect(gateway.shown.single.title, 'Your agent has a question');
      expect(
        gateway.shown.single.body,
        contains('What hurts your sleep most?'),
      );
      expect(
        gateway.shown.single.id,
        AppNotification.idFor(NotificationPolicy.requestTag(clarifyId)),
      );
    });

    test(
      'the first one is not lost while the permission is still loading',
      () async {
        gateway.permissionGate = Completer<bool>();
        await mount(preloadPermission: false);

        channel.receive(frame('clarify'));
        await pumpEventQueue();
        expect(gateway.shown, isEmpty, reason: 'waiting for the grant');

        gateway.permissionGate!.complete(true);
        await pumpEventQueue();

        expect(gateway.shown, hasLength(1));
      },
    );

    test('answering retracts it', () async {
      await mount();
      channel.receive(frame('clarify'));
      await pumpEventQueue();

      router.answerClarify(clarifyId, {'q0': 'Stress'});
      await pumpEventQueue();

      // By the tag it was posted with: Android needs tag and id together.
      expect(gateway.cancelled, [NotificationPolicy.requestTag(clarifyId)]);
    });

    test('a replay after a reconnect stays quiet', () async {
      await mount();

      router.replay(session, [
        (fx['openRequests'] as List).first as Map<String, dynamic>,
      ]);
      await pumpEventQueue();

      expect(gateway.shown, isEmpty);
    });

    test('nothing rings for the chat that is open', () async {
      signals.handle(
        const GatewayEvent(
          type: EventNames.sessionInfo,
          sessionId: session,
          payload: {'stored_session_id': 'stored-1', 'profile_name': 'default'},
        ),
      );
      await mount(
        view: const ActiveView(isForeground: true, profile: 'default'),
      );

      channel.receive(frame('clarify'));
      await pumpEventQueue();

      expect(gateway.shown, isEmpty);
    });

    test("opening a bot's chat takes its message row away", () async {
      await mount(
        view: const ActiveView(isForeground: true, profile: 'default'),
      );

      expect(gateway.cancelled, [NotificationPolicy.messageTag('default')]);
    });
  });

  group('the permission prompt', () {
    test('is not shown at launch, before anything is connected', () async {
      await mount();

      expect(gateway.permissionRequests, 0);
    });

    test('is shown once, after the first live connection', () async {
      final connection = StreamController<HermesConnectionState>();
      addTearDown(connection.close);
      await mount(connection: connection.stream);

      connection.add(const Connected(replayEpoch: 'e'));
      await pumpEventQueue();
      expect(gateway.permissionRequests, 1);

      connection
        ..add(const Reconnecting(attempt: 1))
        ..add(const Connected(replayEpoch: 'e'));
      await pumpEventQueue();
      expect(gateway.permissionRequests, 1, reason: 'asked once, not again');
      expect(kv.values[PreferenceKeys.notificationsPrompted], isTrue);
    });
  });
}
