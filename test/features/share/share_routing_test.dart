import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hermes/app/route_observer.dart';
import 'package:hermes/app/routes.dart';
import 'package:hermes/core/storage/key_value_store.dart';
import 'package:hermes/core/storage/secret_store.dart';
import 'package:hermes/core/theme/app_theme.dart';
import 'package:hermes/features/chat/domain/chat_target.dart';
import 'package:hermes/features/chat/presentation/chat_shell_screen.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/features/share/data/share_intake_service.dart';
import 'package:hermes/features/share/domain/incoming_share.dart';
import 'package:hermes/features/share/presentation/composer_seeds_provider.dart';
import 'package:hermes/features/share/presentation/incoming_share_provider.dart';
import 'package:hermes/features/share/presentation/share_target_screen.dart';
import 'package:hermes/features/sidebar/presentation/sidebar_providers.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/models/profile.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';

import '../../support/memory_stores.dart';

/// Hands the test the shares an app would get from the OS.
class _Intake extends Fake implements ShareIntakeService {
  final StreamController<IncomingShare> controller =
      StreamController<IncomingShare>.broadcast();

  @override
  Stream<IncomingShare> get shares => controller.stream;

  @override
  Future<IncomingShare?> initial() async => null;

  @override
  Future<void> dispose() => controller.close();
}

/// A roster the test settles when it wants to.
class _Roster extends Profiles {
  _Roster(this.result);

  final Future<List<HermesProfile>> result;

  @override
  Future<List<HermesProfile>> build() => result;
}

class _SettingsStub extends StatelessWidget {
  const _SettingsStub();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: TextButton(
      onPressed: context.pop,
      child: const Text('close settings'),
    ),
  );
}

const _atlas = HermesProfile(name: 'atlas', isDefault: true);
const _nova = HermesProfile(name: 'nova', description: 'Writes things');

void main() {
  late _Intake intake;

  /// Null settles the roster at once; a test that wants it to wait sets one.
  Completer<List<HermesProfile>>? slowRoster;
  late GoRouter router;
  late ProviderContainer container;
  late List<String> visited;

  setUp(() {
    intake = _Intake();
    slowRoster = null;
  });

  tearDown(() async {
    await intake.dispose();
  });

  String location() =>
      router.routerDelegate.currentConfiguration.uri.toString();

  /// Lets routes finish: the router resolves a location over a few turns and
  /// a page then slides in, so one pump is not enough.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    String initial = '/chat/atlas',
  }) async {
    visited = [];
    // Made here, in the test's own zone: a future completed outside it would
    // not run its callbacks while the clock is faked.
    final roster =
        slowRoster ??
        (Completer<List<HermesProfile>>()..complete(const [_atlas, _nova]));
    router = GoRouter(
      initialLocation: initial,
      observers: [appRouteObserver],
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const ChatShellScreen(),
        ),
        GoRoute(
          path: Routes.chat,
          builder: (context, state) => ChatShellScreen(
            profile: state.pathParameters[Routes.profileParam],
          ),
        ),
        GoRoute(
          path: Routes.settings,
          pageBuilder: (context, state) => const MaterialPage<void>(
            fullscreenDialog: true,
            child: _SettingsStub(),
          ),
        ),
        GoRoute(
          path: Routes.share,
          pageBuilder: (context, state) => const MaterialPage<void>(
            fullscreenDialog: true,
            child: ShareTargetScreen(),
          ),
        ),
      ],
    )..routerDelegate.addListener(() => visited.add(location()));
    addTearDown(router.dispose);

    container = ProviderContainer(
      overrides: [
        keyValueStoreProvider.overrideWithValue(
          MemoryKeyValueStore({
            PreferenceKeys.gatewayUrl: 'http://gw.test:9119',
          }),
        ),
        secretStoreProvider.overrideWithValue(MemorySecretStore()),
        shareIntakeServiceProvider.overrideWithValue(intake),
        profilesProvider.overrideWith(() => _Roster(roster.future)),
        connectionStateProvider.overrideWith(
          (ref) => Stream<HermesConnectionState>.value(
            const Connected(replayEpoch: 'x'),
          ),
        ),
        profileAvatarProvider.overrideWith((ref, name) => null),
        hermesApiProvider.overrideWithValue(null),
        hermesClientProvider.overrideWithValue(null),
      ],
    );
    // The chat controller touches `state` from `onDispose`; these tests are
    // about routing, so the container outlives the tree (as in the fold tests).
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> receive(WidgetTester tester, IncomingShare share) async {
    intake.controller.add(share);
    await settle(tester);
  }

  testWidgets('a link to a bot on the roster opens its chat and seeds it', (
    tester,
  ) async {
    await pumpApp(tester);
    final seeds = <Map<String, ComposerSeed>>[];
    container.listen(composerSeedsProvider, (_, next) => seeds.add(next));

    await receive(
      tester,
      const IncomingShare(id: '1', profile: 'nova', text: 'hello there'),
    );

    expect(location(), Routes.chatPath('nova'));
    expect(container.read(pendingShareProvider), isNull);
    final seeded = [
      for (final map in seeds)
        for (final entry in map.entries) (entry.key, entry.value.text),
    ];
    expect(seeded, contains((const ChatTarget.bot('nova').key, 'hello there')));
    expect(find.byType(ShareTargetScreen), findsNothing);
  });

  testWidgets('a bot the gateway does not have never gets a chat: the picker '
      'opens instead', (tester) async {
    await pumpApp(tester);

    await receive(
      tester,
      const IncomingShare(id: '1', profile: 'ghost', text: 'boo'),
    );

    expect(find.byType(ShareTargetScreen), findsOneWidget);
    expect(visited.any((l) => l.contains('ghost')), isFalse);
    expect(find.text('Writes things'), findsOneWidget, reason: 'the roster');
  });

  testWidgets('and from the picker the user can send it to a real bot', (
    tester,
  ) async {
    await pumpApp(tester);
    await receive(
      tester,
      const IncomingShare(id: '1', profile: 'ghost', text: 'boo'),
    );

    await tester.tap(find.text('nova'));
    await settle(tester);

    expect(location(), Routes.chatPath('nova'));
    expect(visited.any((l) => l.contains('ghost')), isFalse);
  });

  testWidgets('a second share, after the first went to a bot, opens the '
      'picker again', (tester) async {
    await pumpApp(tester);
    await receive(tester, const IncomingShare(id: '1', text: 'first'));
    await tester.tap(find.text('nova'));
    await settle(tester);
    expect(find.byType(ShareTargetScreen), findsNothing);

    await receive(tester, const IncomingShare(id: '2', text: 'second'));

    expect(find.byType(ShareTargetScreen), findsOneWidget);
  });

  testWidgets('a link to an unknown bot with nothing to send does nothing', (
    tester,
  ) async {
    await pumpApp(tester);

    await receive(tester, const IncomingShare(id: '1', profile: 'ghost'));

    expect(find.byType(ShareTargetScreen), findsNothing);
    expect(container.read(pendingShareProvider), isNull);
    expect(visited.any((l) => l.contains('ghost')), isFalse);
  });

  testWidgets('a share whose files were all left out still opens the picker, '
      'which says so', (tester) async {
    await pumpApp(tester);

    await receive(tester, const IncomingShare(id: '1', skipped: 2));

    expect(find.byType(ShareTargetScreen), findsOneWidget);
    expect(find.text('Nothing to send'), findsOneWidget);
    expect(
      find.text('2 files were left out because they are over the limit'),
      findsOneWidget,
    );
  });

  testWidgets('while the roster loads the link waits, then opens its bot, not '
      'the last-used one', (tester) async {
    final slow = slowRoster = Completer<List<HermesProfile>>();
    await pumpApp(tester, initial: Routes.home);

    await receive(
      tester,
      const IncomingShare(id: '1', profile: 'nova', text: 'wait for me'),
    );
    expect(location(), Routes.home, reason: 'nothing to check it against yet');
    expect(container.read(pendingShareProvider), isNotNull);

    slow.complete(const [_atlas, _nova]);
    await settle(tester);

    expect(location(), Routes.chatPath('nova'));
    expect(visited.any((l) => l == Routes.chatPath('atlas')), isFalse);
  });

  testWidgets('a share that comes in while Settings is open is shown when it '
      'closes', (tester) async {
    await pumpApp(tester);
    unawaited(router.push<void>(Routes.settings));
    await settle(tester);
    expect(find.text('close settings'), findsOneWidget);

    await receive(tester, const IncomingShare(id: '1', text: 'late'));
    expect(find.byType(ShareTargetScreen), findsNothing);
    expect(container.read(pendingShareProvider), isNotNull);

    await tester.tap(find.text('close settings'));
    await settle(tester);

    expect(find.byType(ShareTargetScreen), findsOneWidget);
    expect(find.text('late'), findsOneWidget);
  });

  testWidgets('backing out of the picker drops the share and does not reopen '
      'it', (tester) async {
    await pumpApp(tester);
    await receive(tester, const IncomingShare(id: '1', text: 'once'));
    expect(find.byType(ShareTargetScreen), findsOneWidget);

    router.pop();
    await settle(tester);

    expect(find.byType(ShareTargetScreen), findsNothing);
    expect(container.read(pendingShareProvider), isNull);
  });
}
