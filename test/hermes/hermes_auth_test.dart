import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/auth/hermes_auth.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/transport/hermes_http.dart';

import 'support/loopback_gateway.dart';

/// A Hermes access token: base64url `{"exp": ...}` plus a signature tail.
String _token(int exp) => base64Url.encode([
  ...utf8.encode('{"sub":"u","kind":"access","exp":$exp}'),
  0x76,
  0x00,
  0xff,
]);

DateTime _at(int s) =>
    DateTime.fromMillisecondsSinceEpoch(s * 1000, isUtc: true);

void main() {
  late LoopbackGateway gateway;
  late HermesAuth auth;
  AuthCredential credential = const NoCredential();

  setUp(() async {
    gateway = LoopbackGateway();
    await gateway.start();
    credential = const NoCredential();
    auth = HermesAuth(
      HermesHttp(baseUrl: gateway.url, credential: () => credential),
    );
  });

  tearDown(() => gateway.stop());

  test('expiry reads Hermes blob tokens and JWTs', () {
    expect(HermesAuth.expiryFromToken(_token(1788398111)), _at(1788398111));
    final jwt =
        '${base64Url.encode(utf8.encode('{"alg":"HS256"}'))}.'
        '${base64Url.encode(utf8.encode('{"exp":1700000000}'))}.sig';
    expect(HermesAuth.expiryFromToken(jwt), _at(1700000000));
    expect(HermesAuth.expiryFromToken('not-base64!!'), isNull);
  });

  group('password login', () {
    test('keeps the session cookies, prefixed or quoted', () async {
      final access = _token(1788398111);
      gateway.routes['POST /auth/password-login'] = (_) => reply(
        {'ok': true},
        cookies: [
          '__Host-hermes_session_at=$access; Path=/; HttpOnly; Secure',
          '__Secure-hermes_session_rt="rt-1"; Path=/; HttpOnly; Secure',
          'hermes_session_provider=basic; Path=/',
        ],
      );

      final cred = await auth.passwordLogin(
        provider: 'basic',
        username: 'ada',
        password: 'secret',
      );

      expect(cred.accessToken, access);
      expect(cred.refreshToken, 'rt-1');
      expect(cred.provider, 'basic');
      expect(cred.username, 'ada');
      expect(cred.expiresAt, _at(1788398111));
      expect(cred.origin, gatewayOrigin(gateway.url));
      final sent = gateway.requests.single;
      expect(sent.body, {
        'provider': 'basic',
        'username': 'ada',
        'password': 'secret',
        'next': '',
      });
      expect(sent.headers.value('authorization'), isNull);
    });

    test('without the access cookie is a protocol failure', () async {
      gateway.routes['POST /auth/password-login'] = (_) => reply({'ok': true});
      await expectLater(
        auth.passwordLogin(provider: 'basic', username: 'a', password: 'b'),
        throwsA(isA<ProtocolFailure>()),
      );
    });

    test('with wrong credentials is a 401', () async {
      gateway.routes['POST /auth/password-login'] = (_) =>
          reply({'detail': 'Invalid credentials'}, status: 401);
      await expectLater(
        auth.passwordLogin(provider: 'basic', username: 'a', password: 'b'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });
  });

  group('refresh', () {
    const old = BearerCredential(
      accessToken: 'at-1',
      refreshToken: 'rt-1',
      provider: 'basic',
      username: 'ada',
    );

    test('rotates the pair and keeps who signed in', () async {
      gateway.routes['POST /auth/native/refresh'] = (_) => reply({
        'access_token': 'at-2',
        'refresh_token': 'rt-2',
        'expires_at': 1788398111,
      });

      final cred = await auth.refresh(old);

      expect(cred.accessToken, 'at-2');
      expect(cred.refreshToken, 'rt-2');
      expect(cred.expiresAt, _at(1788398111));
      expect(cred.username, 'ada');
      expect(gateway.requests.single.body, {
        'refresh_token': 'rt-1',
        'provider': 'basic',
      });
    });

    test('a refused refresh token means sign in again', () async {
      gateway.routes['POST /auth/native/refresh'] = (_) =>
          reply({}, status: 401);
      await expectLater(auth.refresh(old), throwsA(isA<UnauthorizedFailure>()));
    });
  });

  test('a ws ticket is minted with the bearer token', () async {
    credential = const BearerCredential(accessToken: 'at');
    gateway.routes['POST /api/auth/ws-ticket'] = (_) =>
        reply({'ticket': 'T-1'});

    expect(await auth.mintTicket(), 'T-1');
    expect(gateway.requests.single.headers.value('authorization'), 'Bearer at');
  });

  test('the session token is read off the index page, bound to it', () async {
    gateway.routes['GET /'] = (_) =>
        reply('<script>window.__HERMES_SESSION_TOKEN__ = "tok-42";</script>');
    final found = await auth.discoverSessionCredential();
    expect(
      found,
      SessionTokenCredential('tok-42', origin: gatewayOrigin(gateway.url)),
    );

    gateway.routes['GET /'] = (_) => reply('<html>sign in</html>');
    expect(await auth.discoverSessionCredential(), isNull);
  });

  group('a stored bearer credential', () {
    test('keeps the keys the app has always stored', () {
      final cred = BearerCredential(
        accessToken: 'at',
        refreshToken: 'rt',
        provider: 'basic',
        expiresAt: DateTime.utc(2026, 10, 3, 12),
        username: 'ada',
      );
      expect(cred.toJson(), {
        'accessToken': 'at',
        'refreshToken': 'rt',
        'provider': 'basic',
        'expiresAt': '2026-10-03T12:00:00.000Z',
        'username': 'ada',
        'origin': '',
      });
      expect(BearerCredential.fromJson(cred.toJson()), cred);
    });

    test('needs a refresh within a minute of expiry, never without one', () {
      final cred = BearerCredential(
        accessToken: 'at',
        expiresAt: DateTime.utc(2026, 10, 3, 12),
      );
      expect(cred.needsRefresh(DateTime.utc(2026, 10, 3, 11, 58)), isFalse);
      expect(cred.needsRefresh(DateTime.utc(2026, 10, 3, 11, 59, 30)), isTrue);
      expect(
        const BearerCredential(accessToken: 'at').needsRefresh(DateTime(3000)),
        isFalse,
      );
    });
  });
}
