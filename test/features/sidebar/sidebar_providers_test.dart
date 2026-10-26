import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/config/app_config.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/sidebar/presentation/sidebar_providers.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/events/gateway_event.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/profile.dart';

import '../../support/fake_gateway.dart';

class _CountingApi extends FakeApi {
  int profileLists = 0;

  @override
  Future<List<HermesProfile>> listProfiles() async {
    profileLists++;
    // A fresh list every time, as the wire gives: the bot list "changes".
    return [const HermesProfile(name: 'atlas')];
  }
}

/// A client whose connection state the test sets.
class _Client extends FakeClient {
  _Client(this._now);

  final StreamController<HermesConnectionState> _stateStream =
      StreamController<HermesConnectionState>.broadcast();
  HermesConnectionState _now;

  @override
  Stream<HermesConnectionState> get states => _stateStream.stream;

  @override
  HermesConnectionState get state => _now;

  @override
  bool get isConnected => _now is Connected;

  void emitState(HermesConnectionState s) {
    _now = s;
    _stateStream.add(s);
  }

  @override
  Future<void> close() async {
    await _stateStream.close();
    await super.close();
  }
}

class _AvatarApi extends _CountingApi {
  int avatarFetches = 0;

  /// The next fetch fails on the link.
  bool failNext = false;

  @override
  Future<String?> profileAvatar(String name) async {
    avatarFetches++;
    if (failNext) {
      failNext = false;
      throw const NetworkFailure('link dropped');
    }
    return 'data:image/png;base64,AA==';
  }
}

/// Lists only when the test lets it.
class _SlowApi extends _CountingApi {
  Completer<void>? gate;

  @override
  Future<List<HermesProfile>> listProfiles() async {
    await gate?.future;
    return super.listProfiles();
  }
}

void main() {
  /// A container over [client] with no automatic retry (it would leave a
  /// timer behind) and the given [api].
  ProviderContainer boot(FakeClient client, FakeApi api) => ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      hermesClientProvider.overrideWithValue(client),
      hermesApiProvider.overrideWithValue(api),
    ],
  );

  /// The provider scheduler works in zero-length timers: one pump is not a
  /// settled state.
  Future<void> settle(
    WidgetTester tester, [
    Duration by = Duration.zero,
  ]) async {
    if (by > Duration.zero) await tester.pump(by);
    for (var round = 0; round < 3; round++) {
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      // The fake client's streams complete on the real clock.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
    }
  }

  /// Closes the container and lets its disposal timers run out.
  Future<void> end(WidgetTester tester, ProviderContainer container) async {
    container.dispose();
    await tester.pump(const Duration(seconds: 1));
  }

  group('the first load', () {
    testWidgets(
      'a gateway that never connects ends in an error, not a spinner',
      (tester) async {
        final client = _Client(const Disconnected());
        addTearDown(client.close);
        final container = boot(client, _CountingApi());
        container.listen(sidebarGroupsProvider, (_, _) {});
        await settle(tester);
        expect(container.read(profilesProvider).isLoading, isTrue);

        await settle(
          tester,
          AppConfig.rosterConnectTimeout + const Duration(seconds: 1),
        );

        expect(container.read(profilesProvider).error, isA<NetworkFailure>());
        expect(container.read(sidebarGroupsProvider).hasError, isTrue);
        await end(tester, container);
      },
    );

    testWidgets('a gateway that wants a sign-in ends in an error at once', (
      tester,
    ) async {
      final client = _Client(const AuthRequired());
      addTearDown(client.close);
      final container = boot(client, _CountingApi());
      container.listen(profilesProvider, (_, _) {});

      await settle(tester);

      expect(
        container.read(profilesProvider).error,
        isA<UnauthorizedFailure>(),
      );
      await end(tester, container);
    });

    testWidgets('one that connects within the budget loads the bots', (
      tester,
    ) async {
      final client = _Client(const Disconnected());
      addTearDown(client.close);
      final container = boot(client, _CountingApi());
      container.listen(profilesProvider, (_, _) {});
      await settle(tester, const Duration(seconds: 5));

      client.emitState(const Connected(replayEpoch: 'e'));
      await settle(tester);

      expect(container.read(profilesProvider).value?.single.name, 'atlas');
      await end(tester, container);
    });
  });

  test(
    'a refresh that answers after the sidebar is gone writes nothing',
    () async {
      final client = FakeClient();
      final api = _SlowApi();
      final container = boot(client, api);
      addTearDown(client.close);
      await container.read(profilesProvider.future);
      final gate = Completer<void>();
      api.gate = gate;

      final pending = container.read(profilesProvider.notifier).refresh();
      await pumpEventQueue();
      container.dispose();
      gate.complete();

      // Riverpod would throw on a write to a disposed notifier.
      await pending;
    },
  );

  group('avatars', () {
    testWidgets('are fetched once per client, not again on each reconnect', (
      tester,
    ) async {
      final client = _Client(const Connected(replayEpoch: 'e1'));
      addTearDown(client.close);
      final api = _AvatarApi();
      final container = boot(client, api);
      container
        // The header watches the state in the app, so it is always listened to.
        ..listen(connectionStateProvider, (_, _) {})
        ..listen(profileAvatarProvider('atlas'), (_, _) {});
      await settle(tester);
      expect(api.avatarFetches, 1);

      client.emitState(const Reconnecting(attempt: 1));
      await settle(tester);
      client.emitState(const Connected(replayEpoch: 'e2'));
      await settle(tester);

      expect(api.avatarFetches, 1, reason: 'a redial changes no picture');
      expect(
        container.read(profileAvatarProvider('atlas')).value,
        'data:image/png;base64,AA==',
      );
      await end(tester, container);
    });

    testWidgets('a failed fetch is tried again on the next connection', (
      tester,
    ) async {
      final client = _Client(const Connected(replayEpoch: 'e1'));
      addTearDown(client.close);
      final api = _AvatarApi()..failNext = true;
      final container = boot(client, api)
        ..listen(profileAvatarProvider('atlas'), (_, _) {});
      await settle(tester);
      expect(api.avatarFetches, 1);
      expect(container.read(profileAvatarProvider('atlas')).value, isNull);

      client
        ..emitState(const Reconnecting(attempt: 1))
        ..emitState(const Connected(replayEpoch: 'e2'));
      await settle(tester);
      expect(api.avatarFetches, 2);
      expect(
        container.read(profileAvatarProvider('atlas')).value,
        'data:image/png;base64,AA==',
      );
      await end(tester, container);
    });
  });

  test('a burst of sessions.changed refreshes the bots once', () async {
    final client = FakeClient();
    final api = _CountingApi();
    final container = ProviderContainer(
      overrides: [
        hermesClientProvider.overrideWithValue(client),
        hermesApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await client.close();
    });
    container.listen(sidebarGroupsProvider, (_, _) {}, fireImmediately: true);
    await pumpEventQueue();
    expect(api.profileLists, 1);

    for (var i = 0; i < 3; i++) {
      client.emit(
        const GatewayEvent(type: EventNames.sessionsChanged, sessionId: ''),
      );
    }
    await Future<void>.delayed(
      AppConfig.sidebarRefreshDebounce + const Duration(milliseconds: 100),
    );
    await pumpEventQueue();

    expect(api.profileLists, 2);
    expect(container.read(sidebarGroupsProvider).value?.single.name, 'atlas');
  });
}
