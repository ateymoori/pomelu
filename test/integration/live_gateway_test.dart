// ignore_for_file: avoid_print
// Live check against a running gateway; read only. Skipped unless run with
//   flutter test test/integration --dart-define=HERMES_URL=http://127.0.0.1:PORT
//   [--dart-define=HERMES_TOKEN=...] [HERMES_USER / HERMES_PASSWORD]
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/api/hermes_api.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/client/hermes_client.dart';
import 'package:hermes/hermes/events/gateway_event.dart';
import 'package:hermes/hermes/hermes_constants.dart';

const String url = String.fromEnvironment('HERMES_URL');
const String token = String.fromEnvironment('HERMES_TOKEN');
const String username = String.fromEnvironment('HERMES_USER');
const String password = String.fromEnvironment('HERMES_PASSWORD');

void main() {
  if (url.isEmpty) {
    test('live gateway (skipped: set HERMES_URL)', () {}, skip: true);
    return;
  }

  test('connect, roster, resume, history', () async {
    AuthCredential cred = token.isEmpty
        ? const NoCredential()
        : const SessionTokenCredential(token);
    final client = HermesClient(
      baseUrl: Uri.parse(url),
      credential: () => cred,
      onCredentialRotated: (c) async => cred = c,
      log: (m, [e]) => print('[hermes] $m ${e ?? ''}'),
    );
    final status = await client.auth.status();
    if (status.authRequired) {
      expect(username, isNotEmpty, reason: 'set HERMES_USER/HERMES_PASSWORD');
      final providers = await client.auth.providers();
      cred = await client.auth.passwordLogin(
        provider: providers.firstWhere((p) => p.supportsPassword).name,
        username: username,
        password: password,
      );
    }

    final ready = client.events.firstWhere(
      (e) => e.type == EventNames.gatewayReady,
    );
    unawaited(client.connect());
    final readyEv = await ready.timeout(const Duration(seconds: 15));
    expect(client.state, isA<Connected>());
    expect(readyEv.text('replay_epoch'), isNotEmpty);

    final api = HermesApi(client);
    final profiles = await api.listProfiles();
    expect(profiles, isNotEmpty);

    final bot = await api.findByTitle(
      profiles.first.name,
      HermesProtocol.botChatTitle,
    );
    if (bot != null) {
      final r = await api.resumeSession(
        storedId: bot.openId,
        profile: profiles.first.name,
      );
      client.watchSession(r.sessionId);
      print(
        'resumed ${r.storedId}: ${(await api.history(r.sessionId)).length}',
      );
    }

    expect(await client.probeAlive(), isTrue);
    await client.dispose();
  }, timeout: const Timeout(Duration(minutes: 2)));
}
