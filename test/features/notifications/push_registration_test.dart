import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/platform/push_bridge.dart';
import 'package:hermes/core/storage/key_value_store.dart';
import 'package:hermes/core/storage/secret_store.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/notifications/presentation/notification_center.dart';
import 'package:hermes/features/notifications/presentation/notification_providers.dart';
import 'package:hermes/features/notifications/presentation/push_registration.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/hermes/api/hermes_api.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/push_device.dart';
import 'package:hermes/hermes/requests/server_request_router.dart';

import '../../support/memory_stores.dart';
import 'notification_center_harness.dart'
    show FakeGateway, FakeService, binding, comeBack, goBackground;

const _phone = PushDevice(platform: 'android', token: 'tok-1', key: 'a2V5');

/// The gateway's Pomelu plugin, as far as the app sees it.
class _PluginApi extends Fake implements HermesApi {
  final registered = <String, PushDevice>{};
  final presence = <bool>[];
  final removed = <String>[];
  bool installed = true;

  @override
  Future<void> registerPushDevice(String id, PushDevice device) async {
    if (!installed) throw const NotSupportedFailure('push is not supported');
    registered[id] = device;
  }

  @override
  Future<void> removePushDevice(String id) async => removed.add(id);

  @override
  Future<void> setPushPresence(String id, {required bool visible}) async =>
      presence.add(visible);
}

class _Bridge implements PushBridge {
  PushDevice? device = _phone;
  final newKeys = <bool>[];
  // ignore: close_sinks, closed by the test's tear-down.
  final tokens = StreamController<void>.broadcast();

  @override
  Future<PushDevice?> register({bool newKey = false}) async {
    newKeys.add(newKey);
    return device;
  }

  @override
  Stream<void> get tokenChanges => tokens.stream;

  @override
  Stream<String> get taps => const Stream.empty();

  @override
  Future<String?> launchBot() async => null;
}

void main() {
  // The harness reads `binding` lazily; initialize it before the first test.
  TestWidgetsFlutterBinding.ensureInitialized();

  late _PluginApi api;
  late _Bridge bridge;
  late MemoryKeyValueStore kv;
  late FakeCheckScheduler scheduler;

  setUp(() {
    api = _PluginApi();
    bridge = _Bridge();
    addTearDown(bridge.tokens.close);
    kv = MemoryKeyValueStore({PreferenceKeys.gatewayUrl: 'http://gw.lan:9119'});
    scheduler = FakeCheckScheduler();
  });

  tearDown(() {
    if (binding.lifecycleState != AppLifecycleState.resumed) comeBack();
  });

  Future<ProviderContainer> mount({bool granted = true}) async {
    final container = ProviderContainer(
      overrides: [
        keyValueStoreProvider.overrideWithValue(kv),
        secretStoreProvider.overrideWithValue(MemorySecretStore()),
        initialCredentialProvider.overrideWithValue(const NoCredential()),
        hermesClientProvider.overrideWithValue(null),
        hermesApiProvider.overrideWithValue(api),
        connectionStateProvider.overrideWith(
          (ref) => Stream.value(const Connected(replayEpoch: 'e1')),
        ),
        pushBridgeProvider.overrideWithValue(bridge),
        notificationGatewayProvider.overrideWithValue(
          FakeGateway()..granted = granted,
        ),
        connectionServiceControllerProvider.overrideWithValue(FakeService()),
        awayStoreProvider.overrideWithValue(MemoryAwayStore()),
        backgroundCheckSchedulerProvider.overrideWithValue(scheduler),
        serverRequestRouterProvider.overrideWithValue(ServerRequestRouter()),
      ],
    );
    addTearDown(container.dispose);
    // Watched, as the app root does.
    container.listen(notificationCenterProvider, (_, _) {});
    container.listen(pushRegistrationProvider, (_, _) {});
    await pumpEventQueue();
    return container;
  }

  test(
    'on a connection the phone registers with the plugin, on screen',
    () async {
      final container = await mount();

      expect(container.read(pushRegistrationProvider), PushStatus.active);
      expect(api.registered.values.single, _phone);
      expect(api.presence, [true]);
    },
  );

  test(
    'the plugin learns when the app leaves the screen and comes back',
    () async {
      await mount();

      goBackground();
      await pumpEventQueue();
      comeBack();
      await pumpEventQueue();

      expect(api.presence, [true, false, true]);
    },
  );

  test('with push working, the periodic background check stops', () async {
    await mount();

    expect(scheduler.wanted, isFalse);
  });

  test('turning Notify me off removes the phone from the plugin', () async {
    final container = await mount();
    final id = api.registered.keys.single;

    await container
        .read(notificationsEnabledSettingProvider.notifier)
        .set(false);
    await pumpEventQueue();

    expect(api.removed, [id]);
    expect(container.read(pushRegistrationProvider), PushStatus.off);
    expect(scheduler.wanted, isFalse);
  });

  test('without notification permission nothing registers', () async {
    final container = await mount(granted: false);

    expect(api.registered, isEmpty);
    expect(container.read(pushRegistrationProvider), PushStatus.off);
  });

  test('a gateway without the plugin keeps the background check', () async {
    api.installed = false;
    final container = await mount();

    expect(container.read(pushRegistrationProvider), PushStatus.unavailable);
    expect(scheduler.wanted, isTrue);
  });

  test('a phone without a push service registers nothing', () async {
    bridge.device = null;
    final container = await mount();

    expect(api.registered, isEmpty);
    expect(container.read(pushRegistrationProvider), PushStatus.unavailable);
  });

  test('a renewed push token registers again under the same id', () async {
    await mount();
    final id = api.registered.keys.single;

    bridge.device = _phone.copyWith(token: 'tok-2');
    bridge.tokens.add(null);
    await pumpEventQueue();

    expect(api.registered, {id: _phone.copyWith(token: 'tok-2')});
  });

  test('another account gets a new phone id and a new key', () async {
    kv.values.addAll({
      PreferenceKeys.pushDeviceId: 'old-id',
      PreferenceKeys.pushAccount: 'http://other.lan:9119#',
    });
    await mount();

    expect(api.registered.keys.single, isNot('old-id'));
    expect(bridge.newKeys.where((renewed) => renewed), hasLength(1));
  });
}
