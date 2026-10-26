import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/storage/key_value_store.dart';
import 'package:hermes/core/storage/secret_store.dart';
import 'package:hermes/features/connection/data/connection_service.dart';
import 'package:hermes/features/connection/data/credential_storage.dart';
import 'package:hermes/features/connection/domain/connection_probe.dart';
import 'package:hermes/features/connection/domain/gateway_config.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/client/hermes_client.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:logger/logger.dart';

import '../../hermes/support/loopback_gateway.dart';
import '../../support/memory_stores.dart';

/// A client whose connection states the test plays out by hand.
class _ScriptedClient extends Fake implements HermesClient {
  _ScriptedClient(this.script, {this.lastFailure, this.lastCloseReason});

  final List<HermesConnectionState> script;
  final _states = StreamController<HermesConnectionState>.broadcast();
  bool disposed = false;

  @override
  final HermesFailure? lastFailure;

  @override
  final String? lastCloseReason;

  @override
  Stream<HermesConnectionState> get states => _states.stream;

  @override
  Future<void> connect() async => script.forEach(_states.add);

  @override
  Future<void> dispose() async {
    disposed = true;
    await _states.close();
  }
}

void main() {
  group('SecureCredentialStorage', () {
    late MemorySecretStore secrets;
    late SecureCredentialStorage storage;

    setUp(() {
      secrets = MemorySecretStore();
      storage = SecureCredentialStorage(secrets);
    });

    test(
      'round-trips both kinds bound to their gateway, and the password',
      () async {
        const token = SessionTokenCredential(
          'tok',
          origin: 'http://gw.lan:9119',
        );
        await storage.save(token);
        expect(await storage.load(), token);
        const bearer = BearerCredential(
          accessToken: 'at',
          username: 'ada',
          origin: 'https://gw.example.com:443',
        );
        await storage.save(bearer);
        expect(await storage.load(), bearer);
        await storage.savePassword('lovelace');
        expect(await storage.loadPassword(), 'lovelace');
        await storage.save(const NoCredential());
        await storage.savePassword('');
        expect(secrets.values, isEmpty);
      },
    );

    test('load never throws: anything unreadable is signed out', () async {
      final lines = <String>[];
      void listen(LogEvent e) => lines.add('${e.message} ${e.error ?? ''}');
      final level = Logger.level;
      Logger.level = Level.all;
      Logger.addLogListener(listen);
      addTearDown(() {
        Logger.removeLogListener(listen);
        Logger.level = level;
      });
      for (final raw in [
        '{"type": "bearer", "accessToken": "at-secret"',
        '[1, 2]',
        '{"type": "sessionToken", "token": 42}',
      ]) {
        secrets.values[PreferenceKeys.gatewayToken] = raw;
        expect(await storage.load(), isA<NoCredential>(), reason: raw);
      }
      secrets.readError = PlatformException(code: 'keystore');
      expect(await storage.load(), isA<NoCredential>());
      expect(lines.join(), isNot(contains('at-secret')), reason: 'type only');
    });
  });

  group('providers', () {
    late MemoryKeyValueStore kv;
    late MemorySecretStore secrets;

    ProviderContainer mount({AuthCredential cred = const NoCredential()}) {
      final container = ProviderContainer(
        overrides: [
          keyValueStoreProvider.overrideWithValue(kv),
          secretStoreProvider.overrideWithValue(secrets),
          initialCredentialProvider.overrideWithValue(cred),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    setUp(() {
      // Port 1 here: every dial is refused at once.
      kv = MemoryKeyValueStore({
        PreferenceKeys.gatewayUrl: 'http://127.0.0.1:1',
      });
      secrets = MemorySecretStore();
    });

    test('a saved config is normalized and survives a restart', () async {
      const ada = GatewayConfig(url: 'nas.local:9119/', username: 'ada');
      await mount().read(gatewayConfigProvider.notifier).save(ada);
      final reread = mount().read(gatewayConfigProvider);
      expect(reread, ada.copyWith(url: 'http://nas.local:9119'));
    });

    test('clear forgets the config, the token and the password', () async {
      secrets.values[PreferenceKeys.gatewayToken] = '{}';
      secrets.values[PreferenceKeys.gatewayPassword] = 'pw';
      final container = mount();
      await container.read(gatewayConfigProvider.notifier).clear();
      expect(container.read(gatewayConfigProvider), isNull);
      expect(kv.values[PreferenceKeys.gatewayUrl], isNull);
      expect(secrets.values, isEmpty);
    });

    test('the client is rebuilt for another address only', () async {
      final container = mount();
      final first = container.read(hermesClientProvider);
      final configs = container.read(gatewayConfigProvider.notifier);
      const mode = AuthMode.basic;
      await configs.save(
        const GatewayConfig(url: '127.0.0.1:1/', authMode: mode),
      );
      expect(container.read(hermesClientProvider), same(first));
      await configs.save(const GatewayConfig(url: 'http://127.0.0.1:2'));
      expect(container.read(hermesClientProvider), isNot(same(first)));
    });

    test('a renewed credential of another gateway is dropped', () async {
      const held = SessionTokenCredential('a', origin: 'http://gw.lan:9119');
      final container = mount(cred: held);
      final notifier = container.read(credentialProvider.notifier);
      await notifier.rotate(
        const SessionTokenCredential('x', origin: 'http://old:80'),
      );
      expect(container.read(credentialProvider), held);
      const renewed = SessionTokenCredential('b', origin: 'http://gw.lan:9119');
      await notifier.rotate(renewed);
      expect(container.read(credentialProvider), renewed);
    });
  });

  group('GatewayConnectionService.test', () {
    late LoopbackGateway gateway;

    setUp(() async {
      gateway = LoopbackGateway();
      await gateway.start();
      gateway.routes['GET /api/status'] = (_) => reply({'version': '9.9'});
    });

    tearDown(() => gateway.stop());

    Future<(TestResult, _ScriptedClient?)> run(
      List<HermesConnectionState> script, {
      HermesFailure? failure,
      String? reason,
    }) async {
      _ScriptedClient? client;
      final result = await GatewayConnectionService(
        clientFactory: (_, _) => client = _ScriptedClient(
          script,
          lastFailure: failure,
          lastCloseReason: reason,
        ),
      ).test(gateway.url, const SessionTokenCredential('tok'));
      return (result, client);
    }

    test('a socket that reaches ready passes, with the version', () async {
      final (r, client) = await run(const [Connected(replayEpoch: 'e')]);
      expect((r.ok, r.version, client?.disposed), (true, '9.9', true));
    });

    test('a refused credential is an auth failure on the socket leg', () async {
      final (r, _) = await run(const [AuthRequired()]);
      expect((r.httpOk, r.wsOk), (true, false));
      expect(r.failure, isA<UnauthorizedFailure>());
    });

    test('a failed first dial says what the socket reported', () async {
      final (r, client) = await run(
        const [Reconnecting(attempt: 1)],
        failure: const HostRefusedFailure('guard'),
        reason: 'host refused: HTTP 403',
      );
      expect(r.failure, isA<HostRefusedFailure>());
      expect(r.detail, 'host refused: HTTP 403');
      expect(client?.disposed, isTrue);
    });

    test('an unreachable gateway fails the HTTP leg, with no socket', () async {
      gateway.routes['GET /api/status'] = (_) => reply('down', status: 503);
      final (r, client) = await run(const []);
      expect(r.httpOk, isFalse);
      expect(r.failure, isA<ServerFailure>());
      expect(client, isNull);
    });
  });
}
