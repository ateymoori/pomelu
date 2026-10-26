import 'dart:async';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/client/hermes_client.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/gateway_status.dart';

import 'support/fake_ws.dart';
import 'support/loopback_gateway.dart' show RpcDeferred, RpcError, RpcSilence;

/// Connection lifecycle, liveness and refusals, on a fake clock and network.
void main() {
  const forbidden = WebSocketException(
    "Connection to 'http://gateway.test/api/ws?token=tok' was not upgraded to "
    'websocket, HTTP status code: 403',
  );
  late FakeWsNetwork net;
  late HermesClient client;
  late List<HermesConnectionState> states;

  void build({
    Duration interval = const Duration(milliseconds: 50),
    Duration silence = const Duration(milliseconds: 300),
    Duration ready = const Duration(seconds: 10),
    Duration stable = const Duration(seconds: 10),
    Future<GatewayStatus> Function()? status,
  }) {
    client = fakeClient(
      net,
      heartbeatInterval: interval,
      heartbeatDeadline: silence,
      readyTimeout: ready,
      stableAfter: stable,
      status: status,
    );
    states = [];
    client.states.listen(states.add);
  }

  void connect(FakeAsync async) {
    unawaited(client.connect());
    async.flushMicrotasks();
  }

  Object? failureOf(Future<Object?> call, FakeAsync async) {
    Object? failure;
    unawaited(call.then<void>((_) {}, onError: (Object e) => failure = e));
    async.flushMicrotasks();
    return failure;
  }

  setUp(() => net = FakeWsNetwork());

  group('connect', () {
    test('is Connected only once capabilities are answered, sent first', () {
      fakeAsync((async) {
        final answer = Completer<Object?>();
        net.rpc['client.capabilities'] = (_) => RpcDeferred(answer.future);
        build();
        connect(async);

        final socket = net.connections.single;
        expect(socket.methods.first, 'client.capabilities');
        expect(socket.callsTo('client.capabilities').single, {
          'server_requests': true,
        });
        expect(client.isConnected, isFalse);
        answer.complete(<String, dynamic>{});
        async.flushMicrotasks();
        expect(client.isConnected, isTrue);

        socket.serverClose();
        async.elapse(const Duration(seconds: 1));
        expect(net.connections.last.methods.first, 'client.capabilities');
      });
    });

    test('a gateway without capabilities still connects', () {
      fakeAsync((async) {
        net.rpc['client.capabilities'] = (_) => const RpcError(-32601, 'no');
        build();
        connect(async);
        expect(client.isConnected, isTrue);
      });
    });

    test('a socket that never says ready is redialled', () {
      fakeAsync((async) {
        net.autoReady = false;
        build(ready: const Duration(seconds: 2));
        connect(async);
        async.elapse(const Duration(seconds: 1));
        expect(net.connections, hasLength(1));

        async.elapse(const Duration(seconds: 2));
        expect(net.connections.first.closedByClient, isTrue);
        expect(net.connections.length, greaterThan(1));
      });
    });

    test('on a live client dials nothing and says nothing', () {
      fakeAsync((async) {
        build();
        connect(async);
        states.clear();
        connect(async);
        expect(net.connections, hasLength(1));
        expect(states, isEmpty);
      });
    });
  });

  group('heartbeat', () {
    test('a silent socket is dropped, one that answers stays', () {
      fakeAsync((async) {
        build();
        connect(async);
        async.elapse(const Duration(seconds: 3));
        expect(net.connections, hasLength(1));

        net.rpc['gateway.ping'] = (_) => const RpcSilence();
        async.elapse(const Duration(seconds: 1));
        expect(net.connections.first.closedByClient, isTrue);
        expect(net.connections.length, greaterThan(1));
      });
    });

    test('an upload is checked over HTTP: kept while it answers', () {
      fakeAsync((async) {
        net.rpc['gateway.ping'] = (_) => const RpcSilence();
        net.rpc['image.attach_bytes'] = (_) => const RpcSilence();
        build();
        connect(async);
        final socket = net.connections.single;
        unawaited(
          client
              .call('image.attach_bytes', {}, const Duration(minutes: 10))
              .then<void>((_) {}, onError: (Object _) {}),
        );
        async.flushMicrotasks();
        final pings = socket.callsTo('gateway.ping').length;

        async.elapse(const Duration(seconds: 3));
        expect(net.connections, hasLength(1));
        expect(socket.callsTo('gateway.ping'), hasLength(pings));

        socket.answer(socket.idOf('image.attach_bytes'), {});
        async.elapse(const Duration(seconds: 1));
        expect(net.connections.length, greaterThan(1), reason: 'pings again');
      });
    });

    test('an upload with HTTP gone too drops the socket', () {
      fakeAsync((async) {
        net.rpc['image.attach_bytes'] = (_) => const RpcSilence();
        build(
          interval: const Duration(seconds: 15),
          silence: const Duration(seconds: 45),
          status: () async => throw const NetworkFailure('unreachable'),
        );
        connect(async);
        unawaited(
          client
              .call('image.attach_bytes', {}, const Duration(minutes: 10))
              .then<void>((_) {}, onError: (Object _) {}),
        );
        async.elapse(
          HermesTimeouts.bulkLivenessDeadline - const Duration(seconds: 20),
        );
        expect(net.connections.single.closedByClient, isFalse);

        async.elapse(const Duration(seconds: 40));
        expect(net.connections.first.closedByClient, isTrue);
      });
    });
  });

  group('backoff', () {
    List<int> attempts() => [
      for (final s in states)
        if (s is Reconnecting) s.attempt,
    ];

    test('grows across instant drops, starts over after a stable link', () {
      fakeAsync((async) {
        var drops = 0;
        net.afterReady = (c) {
          if (drops++ < 3) c.serverClose();
        };
        build(stable: const Duration(seconds: 1));
        connect(async);
        async.elapse(const Duration(seconds: 30));
        expect(attempts(), [1, 2, 3]);

        async.elapse(const Duration(seconds: 2));
        states.clear();
        net.connections.last.serverClose();
        async.flushMicrotasks();
        expect(attempts(), [1]);
      });
    });
  });

  group('reconnectNow', () {
    test('works after the credential was refused', () {
      fakeAsync((async) {
        net.autoOpen = false;
        build();
        connect(async);
        net.connections.single.failUpgrade(forbidden);
        async.flushMicrotasks();
        expect(client.state, isA<AuthRequired>());
        expect(client.lastFailure, isA<UnauthorizedFailure>());
        async.elapse(const Duration(minutes: 5));
        expect(net.connections, hasLength(1), reason: 'no redial');

        net.autoOpen = true;
        unawaited(client.reconnectNow());
        async.flushMicrotasks();
        expect(client.isConnected, isTrue);
      });
    });

    test('after disconnect does nothing', () {
      fakeAsync((async) {
        build();
        connect(async);
        unawaited(client.disconnect());
        async.flushMicrotasks();
        unawaited(client.reconnectNow());
        async.flushMicrotasks();
        expect(net.connections, hasLength(1));
        expect(client.state, isA<Disconnected>());
      });
    });

    test('during a hung dial dials again at once; the old one is dropped', () {
      fakeAsync((async) {
        net.autoOpen = false;
        build();
        connect(async);
        final lands = net.connections.single;
        unawaited(client.reconnectNow());
        async.flushMicrotasks();
        final fails = net.connections.last;
        unawaited(client.reconnectNow());
        async.flushMicrotasks();
        expect(
          net.connections,
          hasLength(3),
          reason: 'no wait for a hung dial',
        );

        final fresh = net.connections.last..open();
        async.flushMicrotasks();
        fresh.sendEvent('gateway.ready', payload: {'replay_epoch': 'e'});
        async.flushMicrotasks();
        expect(client.isConnected, isTrue);

        lands.open();
        fails.failUpgrade(StateError('late'));
        async.elapse(const Duration(minutes: 1));
        expect(lands.closedByClient, isTrue);
        expect(fresh.closedByClient, isFalse);
        expect(client.isConnected, isTrue);
        expect(net.connections, hasLength(3), reason: 'no redial');
      });
    });
  });

  group('a call', () {
    test('in flight when the socket drops is of unknown outcome', () {
      fakeAsync((async) {
        net.rpc['slow'] = (_) => const RpcSilence();
        build();
        connect(async);
        Object? failure;
        unawaited(
          client
              .call('slow')
              .then<void>((_) {}, onError: (Object e) => failure = e),
        );
        async.flushMicrotasks();
        net.connections.single.serverClose();
        async.flushMicrotasks();
        expect(failure, isA<OutcomeUnknownFailure>());
      });
    });

    test('with no socket never left: a plain NetworkFailure', () {
      fakeAsync((async) {
        net.autoOpen = false;
        build();
        connect(async);
        final failure = failureOf(client.call('x'), async);
        expect(failure, isA<NetworkFailure>());
        expect(failure, isNot(isA<OutcomeUnknownFailure>()));
      });
    });
  });

  group('refusals that are not about the credential', () {
    test('a 403 from the Host guard is HostRefused, not AuthRequired', () {
      fakeAsync((async) {
        net.autoOpen = false;
        build(
          status: () async => throw const ServerFailure(
            'Invalid host header',
            httpStatus: HermesHttpStatus.badRequest,
          ),
        );
        connect(async);
        net.connections.single.failUpgrade(forbidden);
        async.flushMicrotasks();

        expect(states.whereType<AuthRequired>(), isEmpty);
        final state = client.state as Disconnected;
        expect(state.failure, isA<HostRefusedFailure>());
        expect(client.lastCloseReason, startsWith('host refused: HTTP 403'));
        expect(client.lastCloseReason, isNot(contains('token=tok')));
        async.elapse(const Duration(minutes: 5));
        expect(net.connections, hasLength(1), reason: 'no redial');
      });
    });

    test('a gateway too old is refused, an unreadable version is not', () {
      fakeAsync((async) {
        build(status: () async => const GatewayStatus(version: '0.20.1'));
        connect(async);
        final failure = (client.state as Disconnected).failure;
        expect(failure, isA<GatewayTooOldFailure>());
        expect(net.connections.single.closedByClient, isTrue);
        async.elapse(const Duration(minutes: 5));
        expect(net.connections, hasLength(1), reason: 'no redial');

        build(status: () async => throw const NetworkFailure('no status'));
        connect(async);
        expect(client.isConnected, isTrue);
      });
    });

    test('isGatewayTooOld compares number by number, never on a guess', () {
      final cases = {
        '0.22.2': false,
        HermesProtocol.minGatewayVersion: false,
        '0.21.4': true,
        '0.9.99': true,
        'v1.0.0-rc1': false,
        '0.21': true,
        '': false,
        'dev': false,
      };
      cases.forEach((v, old) => expect(isGatewayTooOld(v), old, reason: v));
    });
  });
}
