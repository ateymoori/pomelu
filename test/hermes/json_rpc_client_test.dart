import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/rpc/json_offload.dart';
import 'package:hermes/hermes/rpc/json_rpc_client.dart';
import 'package:hermes/hermes/rpc/json_rpc_error.dart';

import '../support/fake_channel.dart';

void main() {
  late FakeChannel channel;
  late JsonRpcClient client;
  late List<String> logs;

  setUp(() {
    channel = FakeChannel();
    logs = [];
    client = JsonRpcClient(channel, log: (m, [_]) => logs.add(m));
  });

  tearDown(() => client.close());

  Future<void> tick() => Future<void>.delayed(Duration.zero);

  Object idOf(int i) => channel.sent[i]['id'] as Object;

  group('calls', () {
    test('are matched to their answer by id', () async {
      final a = client.callMap('a', {'x': 1});
      final b = client.callMap('b');
      await tick();
      expect(channel.sent.first['params'], {'x': 1});
      channel
        ..receive({
          'jsonrpc': '2.0',
          'id': idOf(1),
          'result': {'b': 1},
        })
        ..receive({'jsonrpc': '2.0', 'id': idOf(0), 'result': null});
      expect(await b, {'b': 1});
      expect(await a, isEmpty);
    });

    test('an error answer is a ServerFailure with its code', () async {
      final call = client.call('boom');
      await tick();
      channel.receive({
        'jsonrpc': '2.0',
        'id': idOf(0),
        'error': {'code': 4001, 'message': 'nope'},
      });
      await expectLater(
        call,
        throwsA(
          isA<ServerFailure>()
              .having((f) => f.rpcCode, 'rpcCode', 4001)
              .having((f) => f.message, 'message', 'nope'),
        ),
      );
    });

    test('a timeout after the frame went out is of unknown outcome', () async {
      await expectLater(
        client.call('slow', const {}, const Duration(milliseconds: 10)),
        throwsA(isA<OutcomeUnknownFailure>()),
      );
    });

    test('a frame that never left is a plain network failure', () async {
      channel.down = true;
      await expectLater(
        client.call('x'),
        throwsA(
          isA<NetworkFailure>().having(
            (f) => f is OutcomeUnknownFailure,
            'unknown outcome',
            isFalse,
          ),
        ),
      );
    });

    test('a drop or a channel error fails what is in flight', () async {
      final dropped = client.call('upload');
      await tick();
      expect(client.hasPending({'upload'}), isTrue);
      expect(client.hasPending({'other'}), isFalse);
      client.failAllPending(const OutcomeUnknownFailure('socket dropped'));
      await expectLater(dropped, throwsA(isA<OutcomeUnknownFailure>()));

      final errored = client.call('x');
      await tick();
      channel.controller.addError(StateError('boom'));
      await expectLater(errored, throwsA(isA<OutcomeUnknownFailure>()));
    });

    test('large base64 params are encoded apart, to the same frame', () async {
      final bytes = List<int>.filled(HermesLimits.offloadJsonBytes, 7);
      final params = {'data': Base64Bytes(bytes, prefix: 'data:x;base64,')};
      expect(encodesApart(params), isTrue);
      client.call('file.attach', params).ignore();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(channel.sent.single['params'], {
        'data': 'data:x;base64,${base64Encode(bytes)}',
      });
    });
  });

  group('incoming', () {
    test('notifications stream, garbage is dropped and logged', () async {
      final seen = <String>[];
      final sub = client.notifications.listen((n) => seen.add(n.method));
      channel.controller
        ..add('not json')
        ..add('[1, 2]');
      channel.receive({
        'jsonrpc': '2.0',
        'method': 'event',
        'params': <String, dynamic>{},
      });
      await tick();
      expect(seen, ['event']);
      expect(logs, isNotEmpty);
      await sub.cancel();
    });

    test('a bad entry of a batch drops only itself', () async {
      final seen = <Object?>[];
      final sub = client.notifications.listen((n) => seen.add(n.params['n']));
      channel.controller.add(
        jsonEncode([
          {
            'jsonrpc': '2.0',
            'method': 'event',
            'params': {'n': 1},
          },
          7,
          {
            'jsonrpc': '2.0',
            'method': 'event',
            'params': {'n': 2},
          },
        ]),
      );
      await tick();
      expect(seen, [1, 2]);
      await sub.cancel();
    });

    test('a large frame decoded apart keeps its place in the order', () async {
      final seen = <Object?>[];
      final sub = client.notifications.listen((n) => seen.add(n.params['n']));
      channel.controller
        ..add(
          jsonEncode({
            'jsonrpc': '2.0',
            'method': 'event',
            'params': {'n': 1, 'pad': 'x' * HermesLimits.offloadJsonBytes},
          }),
        )
        ..add(
          jsonEncode({
            'jsonrpc': '2.0',
            'method': 'event',
            'params': {'n': 2},
          }),
        );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(seen, [1, 2]);
      await sub.cancel();
    });
  });

  group('server requests', () {
    void request(String method, [Object id = 'srq-1']) => channel.receive({
      'jsonrpc': '2.0',
      'id': id,
      'method': method,
      'params': {'a': 1},
    });

    Map<String, dynamic> error() =>
        channel.sent.last['error'] as Map<String, dynamic>;

    test('without a handler are answered -32601', () async {
      request('nobody');
      await tick();
      expect(error()['code'], HermesProtocol.errMethodNotFound);
    });

    test(
      'a thrown JsonRpcError keeps its code, anything else is -32000',
      () async {
        client
          ..registerDeferredHandler(
            'typed',
            (_, _) => throw const JsonRpcError(code: 4404, message: 'no'),
          )
          ..registerDeferredHandler('crash', (_, _) => throw StateError('x'));
        request('typed');
        await tick();
        expect(error()['code'], 4404);
        request('crash');
        await tick();
        expect(error()['code'], -32000);
      },
    );

    test('a deferred handler answers later, under the request id', () async {
      Object? got;
      client.registerDeferredHandler('ask', (id, params) => got = id);
      request('ask', 7);
      await tick();
      expect(channel.sent, isEmpty);

      expect(client.tryRespond(got!, {'ok': true}), isTrue);
      expect(channel.sent.single, {
        'jsonrpc': '2.0',
        'id': 7,
        'result': {'ok': true},
      });
      channel.down = true;
      expect(client.tryRespond(7, null), isFalse);
      expect(() => client.respond(7, null), throwsA(isA<NetworkFailure>()));
    });
  });
}
