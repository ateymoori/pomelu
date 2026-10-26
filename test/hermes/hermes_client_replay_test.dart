import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/client/hermes_client.dart';
import 'package:hermes/hermes/events/gateway_event.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/requests/server_request.dart';

import '../support/fixtures.dart';
import 'support/fake_ws.dart';
import 'support/loopback_gateway.dart' show RpcError, RpcResult, RpcSilence;

/// What a reconnect does for the watched sessions: watermark, catch-up,
/// rebind, open questions, and the failures of each. Fake clock and network.
void main() {
  const session = 's1';
  const probe = 0x7fffffff;
  late FakeWsNetwork net;
  late HermesClient client;
  late List<GatewayEvent> seen;

  void connect(FakeAsync async, {bool watch = true}) {
    client = fakeClient(net);
    seen = [];
    client.events.where((e) => e.sessionId == session).listen(seen.add);
    if (watch) client.watchSession(session);
    unawaited(client.connect());
    async.flushMicrotasks();
  }

  void live(int seq) => net.connections.last.sendEvent(
    EventNames.messageDelta,
    sessionId: session,
    seq: seq,
  );

  void reconnect(FakeAsync async) {
    net.connections.last.serverClose();
    async.elapse(const Duration(seconds: 2));
  }

  List<int?> seqs() => [
    for (final e in seen)
      if (e.type == EventNames.messageDelta) e.seq,
  ];
  List<String> types() => [for (final e in seen) e.type];

  setUp(() => net = FakeWsNetwork());

  test('a watched session counts from the newest number, drops repeats', () {
    fakeAsync((async) {
      net.rpc['session.events.since'] = (_) =>
          const RpcResult({'events': <Object?>[], 'latest_seq': 42});
      connect(async);

      expect(net.connections.single.callsTo('session.events.since'), [
        {'session_id': session, 'last_seen': probe},
      ]);
      [40, 42, 43, 44, 43].forEach(live);
      async.flushMicrotasks();
      expect(seqs(), [43, 44]);
    });
  });

  test('a session watched while connected is replayed after an outage', () {
    fakeAsync((async) {
      net.rpc['session.events.since'] = (p) => RpcResult({
        'events': p['last_seen'] == 42
            ? [
                {
                  'type': EventNames.messageDelta,
                  'session_id': session,
                  'seq': 43,
                },
              ]
            : <Object?>[],
        'latest_seq': 42,
      });
      connect(async, watch: false);
      client.watchSession(session);
      async.flushMicrotasks();

      reconnect(async);

      expect(net.connections.last.callsTo('session.events.since').single, {
        'session_id': session,
        'last_seen': 42,
      });
      expect(seqs(), [43]);
      expect(net.connections.last.methods, contains('session.activate'));
    });
  });

  test('an unwatched session keeps every frame and is not replayed', () {
    fakeAsync((async) {
      connect(async, watch: false);
      live(5);
      live(5);
      reconnect(async);
      expect(seqs(), [5, 5]);
      expect(net.connections.last.methods, isNot(contains('session.activate')));
    });
  });

  test('live frames wait for the replay and keep their order', () {
    fakeAsync((async) {
      connect(async);
      live(1);
      net.rpc['session.events.since'] = (_) => const RpcSilence();
      reconnect(async);
      final socket = net.connections.last;
      live(4);
      live(5);
      async.flushMicrotasks();
      expect(seqs(), [1]);

      socket.answer(socket.idOf('session.events.since'), {
        'events': [
          {'type': EventNames.messageDelta, 'session_id': session, 'seq': 2},
        ],
      });
      async.flushMicrotasks();
      expect(seqs(), [1, 2, 4, 5]);
    });
  });

  test('too many held frames ask the chat to reload', () {
    fakeAsync((async) {
      net.rpc['session.events.since'] = (_) => const RpcSilence();
      connect(async);
      final socket = net.connections.single;
      for (var seq = 1; seq <= HermesLimits.heldEventsMax + 5; seq++) {
        live(seq);
      }
      async.flushMicrotasks();
      socket.answer(socket.idOf('session.events.since'), {
        'events': <Object?>[],
      });
      async.flushMicrotasks();

      expect(seqs(), hasLength(HermesLimits.heldEventsMax));
      expect(types(), contains(SyntheticEvents.replayTruncated));
    });
  });

  for (final (name, answer) in [
    (
      'a truncated replay',
      const RpcResult({'events': <Object?>[], 'truncated': true}),
    ),
    ('a refused replay', const RpcError(4001, 'session not found')),
  ]) {
    test('$name asks the chat to reload', () {
      fakeAsync((async) {
        net.rpc['session.events.since'] = (_) => answer;
        connect(async);
        expect(types(), contains(SyntheticEvents.replayTruncated));
        expect(client.isConnected, isTrue);
      });
    });
  }

  test('a new epoch reloads instead of replaying', () {
    fakeAsync((async) {
      connect(async);
      live(9);
      net.epoch = 'epoch-2';
      reconnect(async);

      expect(types(), contains(SyntheticEvents.replayTruncated));
      expect(
        net.connections.last.methods,
        isNot(contains('session.events.since')),
      );
      live(1);
      async.flushMicrotasks();
      expect(seqs(), [9, 1], reason: 'numbers start over');
    });
  });

  test('a failed link is tried once more on the same socket', () {
    fakeAsync((async) {
      var calls = 0;
      net.rpc['session.events.since'] = (_) => ++calls == 1
          ? const RpcSilence()
          : const RpcResult({'events': <Object?>[]});
      connect(async);
      async.elapse(HermesTimeouts.rpcReplay + const Duration(seconds: 1));

      final socket = net.connections.single;
      expect(socket.callsTo('session.events.since'), hasLength(2));
      expect(socket.methods, contains('session.activate'));
      expect(types(), isNot(contains(SyntheticEvents.replayTruncated)));
    });
  });

  test('two replay timeouts reload the transcript, no redial', () {
    fakeAsync((async) {
      net.rpc['session.events.since'] = (_) => const RpcSilence();
      connect(async);
      async.elapse(HermesTimeouts.rpcReplay * 2 + const Duration(seconds: 5));

      expect(net.connections, hasLength(1));
      expect(net.connections.single.closedByClient, isFalse);
      expect(types(), contains(SyntheticEvents.replayTruncated));
      expect(net.connections.single.methods, contains('session.activate'));
    });
  });

  test('a session the gateway lost is reported', () {
    fakeAsync((async) {
      net.rpc['session.activate'] = (_) => const RpcError(4001, 'not found');
      connect(async);
      final lost = seen.singleWhere(
        (e) => e.type == SyntheticEvents.sessionLost,
      );
      expect(lost['code'], 4001);
    });
  });

  group('open questions', () {
    final fx = fixtureMap('server_requests.json');
    final frames = fx['frames'] as Map<String, dynamic>;
    final clarify = (fx['openRequests'] as List).first as Map<String, dynamic>;
    const asked = 'a1b2c3d4';
    var open = <Object?>[];

    void connectAsked(FakeAsync async) {
      net.rpc['session.activate'] = (_) =>
          RpcResult({'session_id': asked, 'open_requests': open});
      client = fakeClient(net)..watchSession(asked);
      unawaited(client.connect());
      async.flushMicrotasks();
    }

    test('come back after a reconnect, and go when no longer listed', () {
      fakeAsync((async) {
        open = [clarify];
        connectAsked(async);
        final request = client.requests.pendingFor(asked);
        expect(request, isA<ClarifyRequest>());
        expect(
          (request! as ClarifyRequest).lockedAnswers['q0'],
          'Caffeine timing',
        );

        open = [];
        reconnect(async);
        expect(client.requests.pendingFor(asked), isNull);
      });
    });

    test('of an unwatched session are forgotten on reconnect', () {
      fakeAsync((async) {
        open = [];
        connectAsked(async);
        client.unwatchSession(asked);
        net.connections.last.serverSends(
          frames['clarify'] as Map<String, dynamic>,
        );
        async.flushMicrotasks();
        expect(client.requests.pendingFor(asked), isNotNull);

        reconnect(async);
        expect(client.requests.pendingFor(asked), isNull);
      });
    });

    test('a window bridge is declined with 4404', () {
      fakeAsync((async) {
        connectAsked(async);
        final bridge = frames['previewAct'] as Map<String, dynamic>;
        net.connections.last.serverSends(bridge);
        async.flushMicrotasks();

        final reply = net.connections.last.replyTo(bridge['id'] as Object);
        expect((reply!['error'] as Map)['code'], HermesProtocol.errNotShown);
      });
    });
  });
}
