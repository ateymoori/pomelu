import 'dart:async';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/auth/hermes_auth.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/hermes_log.dart';
import 'package:hermes/hermes/transport/websocket_transport.dart';

import 'support/fake_ws.dart';

/// A token or a password never reaches a log line, a failure or a toString.
void main() {
  const secret = 'S3CR3T-token-value';

  test('redactSecrets hides secret values and user:password@', () {
    expect(
      redactSecrets('ws://h/api/ws?token=abc&x=1'),
      'ws://h/api/ws?token=***&x=1',
    );
    expect(
      redactSecrets('https://h/x?a=1&access_token=s3cret&b=2&password=pw'),
      'https://h/x?a=1&access_token=***&b=2&password=***',
    );
    expect(redactSecrets('https://ada:pw@gw.lan/a'), 'https://gw.lan/a');
    expect(redactSecrets('TOKEN=abc'), 'TOKEN=***');
    expect(
      redactSecrets('Authorization: Bearer ab.c-d'),
      contains('Bearer ***'),
    );
    expect(
      redactSecrets('hermes_session_at=abc; Path=/'),
      'hermes_session_at=***; Path=/',
    );
    expect(
      redactSecrets('[${HermesProtocol.wsTicketProtocolPrefix}abc]'),
      '[${HermesProtocol.wsTicketProtocolPrefix}***]',
    );
    for (final name in HermesProtocol.secretParams) {
      expect(redactSecrets('?$name=v'), '?$name=***');
    }
    for (final text in ['socket closed', 'tokenizer=on', 'mytoken=1']) {
      expect(redactSecrets(text), text);
    }
  });

  test('credentials, refreshes and closes print no token', () {
    final printed = [
      const BearerCredential(
        accessToken: 'a-$secret',
        refreshToken: 'r-$secret',
        provider: 'basic',
        username: 'ada',
      ),
      const SessionTokenCredential(secret),
      const TokenRefresh(accessToken: 'a-$secret', refreshToken: 'r-$secret'),
      const TransportClose(error: 'ws://h/api/ws?token=$secret failed'),
    ].map((o) => '$o');
    for (final text in printed) {
      expect(text, isNot(contains(secret)));
    }
    expect(printed.first, contains('ada'));
  });

  test('a close reads short, with no secret in it', () {
    const close = TransportClose(
      code: 1011,
      reason: 'going away',
      error: 'ws://gw/api/ws?token=$secret failed',
    );
    expect(close.describe(), startsWith('close 1011: going away'));
    expect(close.describe(), isNot(contains(secret)));
    expect(const TransportClose().describe(), isNull);
    expect(
      TransportClose(reason: 'x' * 500).describe(),
      hasLength(HermesLimits.closeReasonChars + 1),
    );
  });

  for (final (name, error, failed) in [
    (
      'a failed dial',
      const SocketException('refused, uri = ws://h/api/ws?token=$secret#'),
      isA<Disconnected>(),
    ),
    (
      'a refused upgrade',
      const WebSocketException(
        "Connection to 'http://h/api/ws?token=$secret#' was not upgraded to "
        'websocket, HTTP status code: 403',
      ),
      isA<AuthRequired>(),
    ),
  ]) {
    test('$name keeps the token out of the state and the log', () {
      fakeAsync((async) {
        final net = FakeWsNetwork()..autoOpen = false;
        final logs = <String>[];
        final client = fakeClient(net, log: (m, [e]) => logs.add('$m $e'));
        final states = <HermesConnectionState>[];
        client.states.listen(states.add);
        unawaited(client.connect());
        async.flushMicrotasks();

        net.connections.single.failUpgrade(error);
        async.flushMicrotasks();
        unawaited(client.disconnect());
        async.flushMicrotasks();

        final state = states.firstWhere(
          (s) => switch (s) {
            Disconnected(:final failure) ||
            AuthRequired(:final failure) => failure != null,
            _ => false,
          },
        );
        expect(state, failed);
        final failure = switch (state) {
          Disconnected(:final failure) ||
          AuthRequired(:final failure) => failure!,
          _ => throw StateError('no failure'),
        };
        expect('$failure', isNot(contains(secret)));
        expect(logs, isNotEmpty);
        expect(logs.join('\n'), isNot(contains(secret)));
      });
    });
  }
}
