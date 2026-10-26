import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/transport/hermes_http.dart';

import 'support/loopback_gateway.dart';

/// [HermesHttp]: where the credential goes, how a 401 is renewed, and how
/// failures read.
void main() {
  late LoopbackGateway gateway;
  late LoopbackGateway other;
  late Directory dir;

  setUp(() async {
    gateway = LoopbackGateway();
    other = LoopbackGateway();
    await gateway.start();
    await other.start();
    dir = await Directory.systemTemp.createTemp('hermes_http');
  });

  tearDown(() async {
    await gateway.stop();
    await other.stop();
    await dir.delete(recursive: true);
  });

  HermesHttp http({
    AuthCredential Function()? credential,
    Future<bool> Function()? onUnauthorized,
    Dio? dio,
  }) => HermesHttp(
    baseUrl: gateway.url,
    credential: credential ?? () => const SessionTokenCredential('tok'),
    onUnauthorized: onUnauthorized,
    dio: dio,
  );

  String? tokenOf(SeenRequest r) => r.headers.value('x-hermes-session-token');

  group('the credential', () {
    test(
      'goes with a request to its own gateway, or one bound to none',
      () async {
        gateway.routes['GET /api/x'] = (_) => reply({'ok': true});
        final origin = gatewayOrigin(gateway.url);

        expect(await http().json('GET', 'api/x'), {'ok': true});
        await http(
          credential: () => SessionTokenCredential('bound', origin: origin),
        ).json('GET', 'api/x');

        expect(gateway.requests.map(tokenOf), ['tok', 'bound']);
      },
    );

    test('bound to another gateway is never sent', () async {
      gateway.routes['GET /api/x'] = (_) => reply({});
      final h = http(
        credential: () =>
            const SessionTokenCredential('t', origin: 'https://elsewhere:443'),
      );

      await expectLater(
        h.json('GET', 'api/x'),
        throwsA(isA<UnauthorizedFailure>()),
      );
      expect(h.authHeaders(), isEmpty);
      expect(gateway.requests, isEmpty);
    });

    test('a source that throws is a cancelled request, not a crash', () async {
      final h = http(credential: () => throw StateError('disposed'));
      await expectLater(
        h.json('GET', 'api/x'),
        throwsA(isA<CancelledFailure>()),
      );
      expect(h.authHeaders(), isEmpty);
    });

    test('a download from another host gets none', () async {
      gateway.routes['GET /f'] = (_) => reply('a');
      other.routes['GET /f'] = (_) => reply('b');
      final h = http();

      await h.download(gateway.url.resolve('/f'), '${dir.path}/a');
      await h.download(other.url.resolve('/f'), '${dir.path}/b');

      expect(tokenOf(gateway.requests.single), 'tok');
      expect(tokenOf(other.requests.single), isNull);
    });
  });

  group('a 401', () {
    test('renews the credential and tries once more', () async {
      var token = 'old';
      gateway.routes['GET /api/x'] = (r) =>
          tokenOf(r) == 'new' ? reply({'ok': 1}) : reply({}, status: 401);
      var renewals = 0;
      final h = http(
        credential: () => SessionTokenCredential(token),
        onUnauthorized: () async {
          renewals++;
          token = 'new';
          return true;
        },
      );

      expect(await h.json('GET', 'api/x'), {'ok': 1});
      expect(renewals, 1);
      expect(gateway.requests, hasLength(2));
    });

    test('stands when the renewal is refused', () async {
      gateway.routes['GET /api/x'] = (_) => reply({}, status: 401);
      final h = http(onUnauthorized: () async => false);

      await expectLater(
        h.json('GET', 'api/x'),
        throwsA(isA<UnauthorizedFailure>()),
      );
      expect(gateway.requests, hasLength(1));
    });

    test('a renewal that throws something else is an auth failure', () async {
      gateway.routes['GET /api/x'] = (_) => reply({}, status: 401);
      final h = http(onUnauthorized: () => throw StateError('keystore'));

      await expectLater(
        h.json('GET', 'api/x'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test(
      'on a download renews once; a failed download leaves no file',
      () async {
        var token = 'old';
        gateway.routes['GET /f'] = (r) =>
            tokenOf(r) == 'new' ? reply('data') : reply({}, status: 401);
        final h = http(
          credential: () => SessionTokenCredential(token),
          onUnauthorized: () async {
            token = 'new';
            return true;
          },
        );

        await h.download(gateway.url.resolve('/f'), '${dir.path}/ok');
        expect(File('${dir.path}/ok').readAsStringSync(), 'data');

        gateway.routes['GET /f'] = (_) => reply({}, status: 404);
        await expectLater(
          h.download(gateway.url.resolve('/f'), '${dir.path}/gone'),
          throwsA(isA<ServerFailure>()),
        );
        expect(File('${dir.path}/gone').existsSync(), isFalse);
      },
    );
  });

  test(
    'a redirect is not followed: the target never sees the request',
    () async {
      other.routes['GET /api/x'] = (_) => reply({'leaked': true});
      gateway.routes['GET /api/x'] = (_) => reply(
        null,
        status: 302,
        headers: {'location': other.url.resolve('/api/x').toString()},
      );

      await expectLater(
        http().json('GET', 'api/x'),
        throwsA(
          isA<ServerFailure>().having((f) => f.httpStatus, 'status', 302),
        ),
      );
      expect(other.requests, isEmpty);
    },
  );

  group('failures', () {
    test('an error status keeps its code and the gateway reason', () async {
      gateway.routes['POST /api/x'] = (_) =>
          reply({'detail': 'too big'}, status: 413);
      gateway.routes['GET /api/y'] = (_) => reply({}, status: 403);

      await expectLater(
        http().json('POST', 'api/x', body: const {}),
        throwsA(
          isA<ServerFailure>()
              .having((f) => f.httpStatus, 'status', 413)
              .having((f) => f.message, 'message', 'too big'),
        ),
      );
      await expectLater(
        http().json('GET', 'api/y'),
        throwsA(isA<ForbiddenFailure>()),
      );
    });

    test('a closed client fails at once', () async {
      final h = http()..close();
      await expectLater(h.json('GET', 'api/x'), throwsA(isA<NetworkFailure>()));
      expect(gateway.requests, isEmpty);
    });

    test('a gateway that is not there is a plain network failure', () async {
      final port = gateway.url.port;
      await gateway.stop();
      final h = HermesHttp(
        baseUrl: Uri.parse('http://127.0.0.1:$port'),
        credential: () => const NoCredential(),
      );
      await expectLater(
        h.json('GET', 'api/x'),
        throwsA(
          isA<NetworkFailure>().having(
            (f) => f is OutcomeUnknownFailure,
            'unknown outcome',
            isFalse,
          ),
        ),
      );
      gateway = LoopbackGateway();
      await gateway.start();
    });

    test('an answer that never comes is of unknown outcome', () async {
      gateway.routes['GET /api/x'] = (_) async {
        await Future<void>.delayed(const Duration(seconds: 2));
        return reply({});
      };
      final h = http(
        dio: Dio(
          BaseOptions(
            receiveTimeout: const Duration(milliseconds: 200),
            validateStatus: (_) => true,
          ),
        ),
      );
      await expectLater(
        h.json('GET', 'api/x'),
        throwsA(isA<OutcomeUnknownFailure>()),
      );
    });
  });
}
