import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/api/hermes_api.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/client/hermes_client.dart';
import 'package:hermes/hermes/hermes_failure.dart';

import 'support/fake_ws.dart';
import 'support/loopback_gateway.dart';

/// Token renewal: which answers mean "sign in again" and which "try later".
/// HTTP goes to a loopback gateway; the socket is fake.
void main() {
  const wait = Duration(seconds: 5);
  late LoopbackGateway gateway;
  late FakeWsNetwork net;
  late HermesClient client;
  late List<HermesConnectionState> states;
  late AuthCredential cred;
  var refreshes = 0;

  HermesClient build() {
    final c = HermesClient(
      baseUrl: gateway.url,
      credential: () => cred,
      onCredentialRotated: (c) async => cred = c,
      connector: net.connector,
    );
    states = [];
    c.states.listen(states.add);
    return c;
  }

  setUp(() async {
    gateway = LoopbackGateway();
    await gateway.start();
    net = FakeWsNetwork();
    refreshes = 0;
    cred = BearerCredential(
      accessToken: 'old',
      refreshToken: 'rt',
      provider: 'basic',
      expiresAt: DateTime.utc(2020),
    );
    gateway.routes['POST /api/auth/ws-ticket'] = (r) =>
        r.headers.value('authorization') == 'Bearer old'
        ? reply({}, status: 401)
        : reply({'ticket': 't1'});
    client = build();
  });

  tearDown(() async {
    await client.dispose();
    await gateway.stop();
  });

  void refreshAnswers(int status, [Object? body = const {}]) =>
      gateway.routes['POST /auth/native/refresh'] = (_) {
        refreshes++;
        return reply(body, status: status);
      };

  Future<HermesConnectionState> connectUntil(bool Function(Object) done) {
    final reached = client.states.firstWhere(done).timeout(wait);
    unawaited(client.connect());
    return reached;
  }

  test('a token near expiry is refreshed before the dial', () async {
    refreshAnswers(200, {'access_token': 'new', 'refresh_token': 'rt2'});

    await connectUntil((s) => s is Connected);

    expect((cred as BearerCredential).accessToken, 'new');
    expect(
      net.connections.single.dial.protocols,
      contains('hermes-gateway-ticket.t1'),
    );
  });

  for (final status in [401, 403]) {
    test('a $status refresh means sign in again, offered once', () async {
      refreshAnswers(status, {'error': 'session_expired'});

      await connectUntil((s) => s is AuthRequired);

      expect(net.connections, isEmpty);
      expect(refreshes, 1, reason: 'a refused token is not offered again');
    });
  }

  test('a refresh that fails otherwise is no sign-out', () async {
    refreshAnswers(503);

    await connectUntil((s) => s is Reconnecting);
    expect(states.whereType<AuthRequired>(), isEmpty);

    gateway.routes['GET /api/skills'] = (_) => reply({}, status: 401);
    await expectLater(
      HermesApi(client).skills('a'),
      throwsA(isA<ServerFailure>().having((f) => f.httpStatus, 'http', 503)),
    );
  });

  test('two requests that hit a 401 at once share one refresh', () async {
    cred = const BearerCredential(accessToken: 'old', refreshToken: 'rt');
    var expired = 0;
    final bothExpired = Completer<void>();
    gateway.routes['POST /auth/native/refresh'] = (_) async {
      refreshes++;
      await bothExpired.future;
      return reply({'access_token': 'new', 'refresh_token': 'rt-2'});
    };
    gateway.routes['GET /api/skills'] = (r) {
      if (r.headers.value('authorization') == 'Bearer new') {
        return reply(<Object?>[]);
      }
      if (++expired == 2) bothExpired.complete();
      return reply({}, status: 401);
    };
    final api = HermesApi(client);

    await Future.wait([api.skills('a'), api.skills('b')]);

    expect(refreshes, 1);
    expect((cred as BearerCredential).refreshToken, 'rt-2');
  });

  test('a refused refresh leaves the request its 401', () async {
    cred = const BearerCredential(accessToken: 'old', refreshToken: 'rt');
    gateway.routes['GET /api/skills'] = (_) => reply({}, status: 401);
    refreshAnswers(401);

    await expectLater(
      HermesApi(client).skills('a'),
      throwsA(isA<UnauthorizedFailure>()),
    );
  });

  test('a session token is found again after a dashboard restart', () async {
    cred = SessionTokenCredential('stale', origin: gatewayOrigin(gateway.url));
    gateway.routes['GET /'] = (_) =>
        reply('<script>window.__HERMES_SESSION_TOKEN__ = "fresh";</script>');
    gateway.routes['GET /api/skills'] = (r) =>
        r.headers.value('x-hermes-session-token') == 'fresh'
        ? reply(<Object?>[])
        : reply({}, status: 401);

    await HermesApi(client).skills('a');

    expect((cred as SessionTokenCredential).token, 'fresh');
  });

  test('a credential of another gateway is never sent', () async {
    cred = const SessionTokenCredential('tok', origin: 'https://other:443');

    await connectUntil((s) => s is AuthRequired);

    expect(net.connections, isEmpty);
    expect(gateway.requests, isEmpty);
  });
}
