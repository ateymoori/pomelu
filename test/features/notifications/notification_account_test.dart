import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/notifications/presentation/notification_center.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/client/session_signals.dart';
import 'package:hermes/hermes/requests/server_request_router.dart';
import 'package:hermes/hermes/rpc/json_rpc_client.dart';

import '../../support/fake_channel.dart';
import '../../support/memory_stores.dart';
import 'notification_center_harness.dart';

/// What is in the shade belongs to the account it came from.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel = FakeChannel();
    rpc = JsonRpcClient(channel);
    router = ServerRequestRouter()..attach(rpc);
    gateway = FakeGateway();
    service = FakeService();
    signals = SessionSignals();
    kv = MemoryKeyValueStore();
    away = MemoryAwayStore();
    scheduler = FakeCheckScheduler();
  });

  tearDown(() async {
    if (binding.lifecycleState != AppLifecycleState.resumed) comeBack();
    await router.dispose();
    await rpc.close();
  });

  const signedIn = <String, Object>{
    PreferenceKeys.gatewayUrl: 'http://gw.lan:9119',
    PreferenceKeys.gatewayAuthMode: 'basic',
    PreferenceKeys.gatewayUsername: 'ada',
  };
  const ada = BearerCredential(accessToken: 'at', username: 'ada');

  test('a sign-out clears every notification', () async {
    final container = await mount(prefs: signedIn, credential: ada);

    await container.read(credentialProvider.notifier).set(const NoCredential());
    await pumpEventQueue();

    expect(gateway.clearedAll, 1);
  });

  test('another gateway clears them', () async {
    final container = await mount(prefs: signedIn, credential: ada);
    final config = container.read(gatewayConfigProvider)!;

    await container
        .read(gatewayConfigProvider.notifier)
        .save(config.copyWith(url: 'http://other.lan:9119'));
    await pumpEventQueue();

    expect(gateway.clearedAll, 1);
  });

  test('the same address written another way is the same gateway', () async {
    final container = await mount(prefs: signedIn, credential: ada);
    final config = container.read(gatewayConfigProvider)!;

    expect(
      sameAccount(config, config.copyWith(url: 'http://GW.lan:9119/')),
      isTrue,
    );
    expect(sameAccount(config, null), isFalse);
    expect(sameAccount(null, null), isTrue);
  });
}
