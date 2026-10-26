import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/config/app_config.dart';
import 'package:hermes/core/storage/key_value_store.dart';
import 'package:hermes/core/storage/secret_store.dart';
import 'package:hermes/features/connection/domain/connection_probe.dart';
import 'package:hermes/features/connection/domain/gateway_config.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/features/settings/domain/settings_form_state.dart';
import 'package:hermes/features/settings/presentation/settings_controller.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/hermes_failure.dart';

import '../../support/memory_stores.dart';
import 'settings_harness.dart';

const _gw = 'http://gw.lan:9119';
const _stored = BearerCredential(accessToken: 'at-old', username: 'ada');

void main() {
  late MemoryKeyValueStore kv;
  late MemorySecretStore secrets;
  late FakeConnectionService service;
  late FakeSupervisor supervisor;
  late RecordingClient client;

  setUp(() {
    kv = MemoryKeyValueStore();
    secrets = MemorySecretStore();
    service = FakeConnectionService();
    supervisor = FakeSupervisor();
    client = RecordingClient();
  });

  /// The page; close the subscription to close it.
  (ProviderContainer, ProviderSubscription<SettingsFormState>) mount({
    AuthCredential credential = const NoCredential(),
  }) {
    final container = ProviderContainer(
      overrides: [
        keyValueStoreProvider.overrideWithValue(kv),
        secretStoreProvider.overrideWithValue(secrets),
        initialCredentialProvider.overrideWithValue(credential),
        connectionServiceProvider.overrideWithValue(service),
        connectionSupervisorProvider.overrideWith(() => supervisor),
        hermesClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(container.dispose);
    return (container, container.listen(settingsControllerProvider, (_, _) {}));
  }

  SettingsController ctl(ProviderContainer c) =>
      c.read(settingsControllerProvider.notifier);
  SettingsFormState form(ProviderContainer c) =>
      c.read(settingsControllerProvider);

  /// A fresh install where the user typed [_gw].
  ProviderContainer typed() {
    final c = mount().$1;
    ctl(c).setUrl(_gw);
    return c;
  }

  /// A gated gateway and a user typed in.
  Future<ProviderContainer> gated() async {
    service.probeResult = gatedProbe;
    final c = typed();
    await ctl(c).probe();
    ctl(c)
      ..setUsername('ada')
      ..setPassword('lovelace');
    return c;
  }

  /// [_gw] saved, signed in as ada with a saved password.
  ProviderContainer saved() {
    kv.values
      ..[PreferenceKeys.gatewayUrl] = _gw
      ..[PreferenceKeys.gatewayAuthMode] = 'basic'
      ..[PreferenceKeys.gatewayUsername] = 'ada';
    secrets.values[PreferenceKeys.gatewayPassword] = 'lovelace';
    return mount(credential: _stored).$1;
  }

  testWidgets('probes on open, and once per debounced URL edit', (
    tester,
  ) async {
    final c = mount().$1;
    await tester.pump();
    expect(form(c).url, isEmpty, reason: 'no gateway is assumed');
    final before = service.probeCalls;
    ctl(c).setUrl('http://gw.lan:1');
    await tester.pump(AppConfig.urlProbeDebounce ~/ 2);
    ctl(c).setUrl('gw.lan:12');
    await tester.pump(AppConfig.urlProbeDebounce ~/ 2);
    expect(service.probeCalls, before);
    await tester.pump(AppConfig.urlProbeDebounce);
    expect(service.probeCalls, before + 1);
    expect('${service.lastProbeUri}', 'http://gw.lan:12', reason: 'scheme');
  });

  test('sign-in holds the account in the form; nothing is stored', () async {
    final c = await gated();
    await ctl(c).signIn();
    expect(
      (form(c).signedInAs, form(c).credentialKind),
      ('ada', CredentialKind.user),
    );
    expect(secrets.values, isEmpty);
    expect(c.read(credentialProvider), isA<NoCredential>());
  });

  test('a failure of any kind clears the busy flag and reports', () async {
    final c = await gated();
    service.signInError = StateError('keystore on fire');
    await ctl(c).signIn();
    expect(form(c).busy, isFalse);
    expect(form(c).error, isA<StateError>());
    service.testError = const UnauthorizedFailure('no');
    await ctl(c).test();
    expect(form(c).busy, isFalse);
    expect(form(c).error, isA<UnauthorizedFailure>());
  });

  test('a page closed while a sign-in waits is not written to', () async {
    service.probeResult = gatedProbe;
    final (c, page) = mount();
    ctl(c).setUrl(_gw);
    service.signInGate = Completer<void>();
    final pending = ctl(c).signIn();
    page.close();
    await pumpEventQueue();
    service.signInGate!.complete();
    await pending;
  });

  test('answers for an address the user left are dropped', () async {
    Future<void> leave(
      ProviderContainer c,
      Completer<void> gate,
      Future<void> pending,
    ) async {
      ctl(c).setUrl('http://other.lan:9119');
      gate.complete();
      await pending;
    }

    var c = typed();
    await pumpEventQueue();
    await leave(c, service.probeGate = Completer(), ctl(c).probe());
    expect((form(c).probe, form(c).probing), (null, false));

    c = await gated();
    await leave(c, service.signInGate = Completer(), ctl(c).signIn());
    expect((form(c).pendingCredential, form(c).signingIn), (null, false));

    service
      ..probeResult = const ProbeResult(reachable: true)
      ..discovered = const SessionTokenCredential('tok-a');
    c = typed();
    await ctl(c).probe();
    await leave(c, service.discoverGate = Completer(), ctl(c).test());
    expect((form(c).pendingCredential, form(c).testResult), (null, null));
  });

  test('a test on an un-gated gateway discovers its token, or asks for '
      'one', () async {
    var c = typed();
    await ctl(c).probe();
    service.testResult = const TestResult(httpOk: false, wsOk: false);
    await ctl(c).test();
    expect(form(c).needsManualToken, isTrue);

    service
      ..discovered = const SessionTokenCredential('tok-1')
      ..testResult = const TestResult(httpOk: true, wsOk: true);
    c = typed();
    await ctl(c).probe();
    await ctl(c).test();
    expect(form(c).credentialKind, CredentialKind.token);
    expect(form(c).needsManualToken, isFalse);
  });

  test('a pasted token is bound to the address it was pasted for', () {
    final c = typed();
    ctl(c)
      ..setToken('pasted')
      ..useToken();
    expect(form(c).pendingCredential?.origin, 'http://gw.lan:9119');
  });

  group('save', () {
    test('writes the credential before the config, the password with a '
        'bearer only', () async {
      final order = <String>[];
      kv = LoggingKeyValueStore(order);
      secrets = SpySecretStore(order: order);
      final c = await gated();
      await ctl(c).signIn();
      order.clear();
      expect(await ctl(c).saveAndConnect(), isTrue);
      expect(
        order.indexOf('secret:${PreferenceKeys.gatewayToken}'),
        lessThan(order.indexOf('kv:${PreferenceKeys.gatewayUrl}')),
        reason: 'the config rebuilds the client; the credential must be in',
      );
      expect(secrets.values[PreferenceKeys.gatewayPassword], 'lovelace');
      expect(c.read(gatewayConfigProvider)?.authMode, AuthMode.basic);
      expect(supervisor.reconnects, 1);
    });

    test('a token instead of a user drops the stored password', () async {
      secrets.values[PreferenceKeys.gatewayPassword] = 'old-account';
      service.discovered = const SessionTokenCredential('tok-1');
      final c = typed();
      await ctl(c).probe();
      await ctl(c).test();
      await ctl(c).saveAndConnect();
      expect(secrets.values.containsKey(PreferenceKeys.gatewayPassword), false);
    });

    test(
      'while the gateway is down never deletes the stored sign-in',
      () async {
        service.probeResult = const ProbeResult(
          reachable: false,
          failure: NetworkFailure('refused'),
        );
        final c = saved();
        await ctl(c).probe();
        expect(c.read(settingsDirtyProvider), isFalse);
        expect(await ctl(c).saveAndConnect(), isTrue);
        expect(c.read(credentialProvider), _stored);
        expect(c.read(gatewayConfigProvider)?.authMode, AuthMode.basic);
        expect(secrets.values[PreferenceKeys.gatewayPassword], 'lovelace');
      },
    );

    test(
      'to a new address stops the old client before the new credential',
      () async {
        final seen = <String>[];
        secrets = SpySecretStore(
          beforeToken: () => seen.addAll(client.socketCalls),
        );
        final c = await gated();
        await ctl(c).signIn();
        await ctl(c).saveAndConnect();
        expect(seen, contains('disconnect'));
      },
    );

    test('that fails reports, and the old client goes on', () async {
      secrets = SpySecretStore(fail: true);
      final c = await gated();
      await ctl(c).signIn();
      expect(await ctl(c).saveAndConnect(), isFalse);
      await pumpEventQueue();
      expect(form(c).saving, isFalse);
      expect(form(c).error, isA<StateError>());
      expect(c.read(gatewayConfigProvider), isNull);
      expect(client.socketCalls, ['disconnect', 'connect']);
    });

    test('a new credential for the same address cycles the socket', () async {
      service.probeResult = gatedProbe;
      final c = saved();
      await ctl(c).saveAndConnect();
      expect(supervisor.cycles, 0);
      expect(client.socketCalls, isEmpty);
      await ctl(c).probe();
      ctl(c).setPassword('lovelace');
      await ctl(c).signIn();
      await ctl(c).saveAndConnect();
      expect(supervisor.cycles, 1, reason: 'it still runs on the old login');
    });

    test('refuses an address with user:password@ in it', () async {
      final c = mount().$1;
      ctl(c).setUrl('http://ada:lovelace@gw.lan:9119');
      expect(await ctl(c).saveAndConnect(), isFalse);
      expect(kv.values, isEmpty);
    });
  });

  group('sign-out', () {
    test('of the stored sign-in clears it and cycles the socket', () async {
      final c = saved();
      await ctl(c).signOut();
      expect(c.read(credentialProvider), isA<NoCredential>());
      expect(secrets.values, isEmpty);
      expect(form(c).url, _gw);
      expect(client.socketCalls, ['disconnect', 'connect']);
    });

    test('of a sign-in nobody saved only clears the form', () async {
      service.probeResult = gatedProbe;
      final c = saved();
      ctl(c)
        ..setUrl('http://other.lan:9119')
        ..setUsername('bob')
        ..setPassword('builder');
      await ctl(c).probe();
      await ctl(c).signIn();
      await ctl(c).signOut();
      expect(c.read(credentialProvider), _stored);
      expect(secrets.values[PreferenceKeys.gatewayPassword], 'lovelace');
      expect(client.socketCalls, isEmpty);
      expect((form(c).pendingCredential, form(c).password), (null, ''));
    });
  });

  test('the held credential counts only where it fits the gateway', () {
    const token = SessionTokenCredential('t');
    const bearer = BearerCredential(accessToken: 'a');
    const down = ProbeResult(reachable: false);
    const open = ProbeResult(reachable: true);
    SettingsFormState s(AuthCredential c, ProbeResult? p) =>
        SettingsFormState(url: _gw, pendingCredential: c, probe: p);
    expect(s(token, gatedProbe).effectiveCredential, isNull);
    expect(s(bearer, open).effectiveCredential, isNull);
    expect(s(token, open).authMode, AuthMode.token);
    expect(s(token, gatedProbe).authMode, AuthMode.basic);
    expect(s(bearer, down).authMode, AuthMode.basic, reason: 'stands');
    expect(
      const SettingsFormState(savedAuthMode: AuthMode.basic).authMode,
      AuthMode.basic,
    );
  });

  test('the form is dirty only for what Save would change', () async {
    kv.values[PreferenceKeys.gatewayUrl] = 'http://gw.lan:9119/';
    var c = mount().$1;
    expect(c.read(settingsDirtyProvider), isFalse);
    ctl(c).setUrl('http://gw.lan:1');
    expect(c.read(settingsDirtyProvider), isTrue);
    ctl(c).setUrl(_gw);
    expect(c.read(settingsDirtyProvider), isFalse);
    kv.values.clear();
    c = await gated();
    expect(c.read(settingsDirtyProvider), isTrue);
    await ctl(c).signIn();
    await ctl(c).saveAndConnect();
    ctl(c).setPassword('');
    expect(c.read(settingsDirtyProvider), isFalse);
  });

  test('the form text never shows the password or the token', () {
    const s = SettingsFormState(url: _gw, password: 'p4ss', token: 't0ken');
    expect('$s', allOf(isNot(contains('p4ss')), isNot(contains('t0ken'))));
  });
}
