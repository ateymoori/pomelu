import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/config/app_config.dart';
import 'package:hermes/core/storage/key_value_store.dart';
import 'package:hermes/core/storage/secret_store.dart';
import 'package:hermes/features/connection/data/connection_service.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/hermes_failure.dart';

import '../../support/fake_gateway.dart';
import '../../support/memory_stores.dart';
import '../../support/throwing.dart';

/// A client whose state the test sets, and whose dials it counts.
class _Client extends FakeClient {
  final _stateStream = StreamController<HermesConnectionState>.broadcast();
  HermesConnectionState _now = const Connected(replayEpoch: 'e');
  int redials = 0;
  int connects = 0;
  int probes = 0;
  bool alive = true;

  /// After a `connect`, the gateway refuses the new credential again.
  bool rejectAfterConnect = false;

  /// Whether the dashboard shows a new session token.
  bool newToken = false;
  int discoveries = 0;

  @override
  Future<bool> rediscoverSessionToken() async {
    discoveries++;
    return newToken;
  }

  @override
  Stream<HermesConnectionState> get states => _stateStream.stream;

  @override
  HermesConnectionState get state => _now;

  @override
  bool get isConnected => _now is Connected;

  void emitState(HermesConnectionState s) => _stateStream.add(_now = s);

  @override
  Future<void> reconnectNow() async => redials++;

  @override
  Future<bool> probeAlive() async {
    probes++;
    return alive;
  }

  @override
  Future<void> connect() async {
    connects++;
    if (rejectAfterConnect) {
      unawaited(Future(() => emitState(const AuthRequired())));
    }
  }
}

class _Service extends Fake implements ConnectionService {
  int signIns = 0;
  Object? signInError;

  @override
  Future<BearerCredential> signInBasic({
    required Uri base,
    required String provider,
    required String username,
    required String password,
  }) async {
    signIns++;
    if (signInError case final e?) throwInjected(e);
    return BearerCredential(accessToken: 'at-$signIns', username: username);
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late _Client client;
  late _Service service;
  late StreamController<List<ConnectivityResult>> network;
  late MemorySecretStore secrets;

  setUp(() {
    client = _Client();
    service = _Service();
    network = StreamController.broadcast();
    secrets = MemorySecretStore()
      ..values[PreferenceKeys.gatewayPassword] = 'lovelace';
  });

  tearDown(() async {
    await network.close();
    await client.close();
  });

  /// A gated gateway, signed in as ada, the supervisor mounted as at the
  /// app root.
  ProviderContainer mount({
    String authMode = 'basic',
    AuthCredential credential = const BearerCredential(accessToken: 'stale'),
  }) {
    final container = ProviderContainer(
      overrides: [
        keyValueStoreProvider.overrideWithValue(
          MemoryKeyValueStore({
            PreferenceKeys.gatewayUrl: 'http://gw.lan:9119',
            PreferenceKeys.gatewayAuthMode: authMode,
            PreferenceKeys.gatewayUsername: 'ada',
          }),
        ),
        secretStoreProvider.overrideWithValue(secrets),
        initialCredentialProvider.overrideWithValue(credential),
        connectionServiceProvider.overrideWithValue(service),
        hermesClientProvider.overrideWithValue(client),
        connectivityChangesProvider.overrideWithValue(network.stream),
      ],
    );
    addTearDown(container.dispose);
    container.listen(connectionSupervisorProvider, (_, _) {});
    return container;
  }

  ConnectionSupervisor supervisor(ProviderContainer c) =>
      c.read(connectionSupervisorProvider.notifier);

  group('a network change', () {
    Future<void> change(WidgetTester tester, List<ConnectivityResult> n) async {
      network.add(n);
      await tester.pump();
    }

    testWidgets('the report on subscribe and repeats are no change', (
      tester,
    ) async {
      mount();
      client.emitState(const Reconnecting(attempt: 2));
      const both = [ConnectivityResult.wifi, ConnectivityResult.mobile];
      await change(tester, both);
      await change(tester, both.reversed.toList());
      expect((client.redials, client.probes), (0, 0));
    });

    testWidgets('while connected probes, and redials only a dead socket', (
      tester,
    ) async {
      mount();
      await change(tester, [ConnectivityResult.wifi]);
      await change(tester, [ConnectivityResult.mobile]);
      expect((client.probes, client.redials), (1, 0));
      client.alive = false;
      await change(tester, [ConnectivityResult.ethernet]);
      expect((client.probes, client.redials), (2, 1));
    });

    testWidgets('during a dial or a sign-in is left alone', (tester) async {
      mount();
      await change(tester, [ConnectivityResult.wifi]);
      client.emitState(const Connecting());
      await change(tester, [ConnectivityResult.mobile]);
      client.emitState(const AuthRequired());
      await change(tester, [ConnectivityResult.ethernet]);
      expect(client.redials, 0, reason: 'it would tear the new socket down');
    });

    testWidgets('while waiting to redial dials at once, unless offline', (
      tester,
    ) async {
      mount();
      client.emitState(const Disconnected());
      await change(tester, [ConnectivityResult.wifi]);
      await change(tester, [ConnectivityResult.none]);
      expect(client.redials, 0);
      client.emitState(const Reconnecting(attempt: 2));
      await change(tester, [ConnectivityResult.mobile]);
      expect(client.redials, 1);
    });
  });

  testWidgets('resume probes a socket that looks open, redials a dead one', (
    tester,
  ) async {
    void cycle() => [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ].forEach(binding.handleAppLifecycleStateChanged);
    mount();
    cycle();
    await tester.pump();
    expect((client.probes, client.redials), (1, 0));
    client.alive = false;
    cycle();
    await tester.pump();
    expect((client.probes, client.redials), (2, 1));
    client.emitState(const Disconnected());
    cycle();
    await tester.pump();
    expect((client.probes, client.redials), (2, 2), reason: 'no probe');
  });

  group('silent re-sign-in', () {
    testWidgets('replaces a refused token with the saved password, if any', (
      tester,
    ) async {
      final container = mount();
      final saved = secrets.values.remove(PreferenceKeys.gatewayPassword)!;
      client.emitState(const AuthRequired());
      await tester.pump();
      expect(service.signIns, 0, reason: 'no password: the user signs in');
      secrets.values[PreferenceKeys.gatewayPassword] = saved;
      await supervisor(container).reconnect();
      expect((service.signIns, client.connects), (1, 1));
      expect(
        container.read(credentialProvider),
        isA<BearerCredential>().having((c) => c.accessToken, 'at', 'at-1'),
      );
    });

    testWidgets('is capped and backs off; a manual retry or a connection '
        'starts it over', (tester) async {
      client.rejectAfterConnect = true;
      final container = mount();
      client.emitState(const AuthRequired());
      await tester.pump();
      expect(service.signIns, 1, reason: 'the first is at once');
      await tester.pump(AppConfig.reauthBackoff * 0.9);
      expect(service.signIns, 1);
      await tester.pump(AppConfig.reauthBackoff * 0.2);
      expect(service.signIns, 2);
      await tester.pump(const Duration(minutes: 5));
      const cap = AppConfig.reauthMaxAttempts;
      expect(service.signIns, cap);

      client.rejectAfterConnect = false;
      await supervisor(container).reconnect();
      expect(service.signIns, cap + 1);
      client
        ..emitState(const Connected(replayEpoch: 'e'))
        ..emitState(const AuthRequired());
      await tester.pump();
      expect(service.signIns, cap + 2);
    });

    testWidgets('a delayed attempt for a recovered client does nothing', (
      tester,
    ) async {
      service.signInError = const UnauthorizedFailure('not yet');
      mount();
      client.emitState(const AuthRequired());
      await tester.pump();
      client.emitState(const AuthRequired());
      await tester.pump();
      client.emitState(const Connected(replayEpoch: 'e'));
      await tester.pump(AppConfig.reauthBackoff * 4);
      expect(service.signIns, 1);
    });

    testWidgets('an un-gated gateway gets its new token, a pasted one is '
        'dialled first', (tester) async {
      client.newToken = true;
      final container = mount(
        authMode: 'none',
        credential: const SessionTokenCredential('stale'),
      );
      client.emitState(const AuthRequired());
      await tester.pump();
      expect((client.discoveries, client.connects), (1, 1));

      await container
          .read(credentialProvider.notifier)
          .set(const SessionTokenCredential('pasted'));
      final connects = client.connects;
      await supervisor(container).reconnect();
      expect(client.connects, connects + 1);
      expect(client.discoveries, 1, reason: 'no discovery for a new token');
    });
  });

  test('after Save, a new credential cycles a live socket', () async {
    final container = mount();
    await supervisor(container).reconnect();
    expect((client.connects, client.redials), (1, 0));
    await supervisor(container).reconnect(cycle: true);
    expect(client.redials, 1, reason: 'the socket runs on the old login');
  });
}
