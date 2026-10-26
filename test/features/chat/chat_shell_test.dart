import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hermes/app/routes.dart';
import 'package:hermes/core/storage/key_value_store.dart';
import 'package:hermes/core/storage/secret_store.dart';
import 'package:hermes/core/theme/app_theme.dart';
import 'package:hermes/features/bot_details/presentation/widgets/bot_details_sheet.dart';
import 'package:hermes/features/chat/domain/chat_target.dart';
import 'package:hermes/features/chat/presentation/chat_shell_screen.dart';
import 'package:hermes/features/chat/presentation/chat_view.dart';
import 'package:hermes/features/chat/presentation/widgets/composer.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/features/share/presentation/composer_seeds_provider.dart';
import 'package:hermes/features/sidebar/domain/bot_group.dart';
import 'package:hermes/features/sidebar/presentation/sidebar_panel.dart';
import 'package:hermes/features/sidebar/presentation/sidebar_providers.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/models/profile.dart';
import 'package:hermes/hermes/models/session_message.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';

import '../../support/memory_stores.dart';
import '../../support/scripted_api.dart';
import 'chat_harness.dart';

const _atlas = BotGroup(
  profile: HermesProfile(name: 'atlas', isDefault: true, model: 'sonnet'),
);
const _byte = BotGroup(
  profile: HermesProfile(name: 'byte', model: 'sonnet'),
);
const _owl = BotGroup(
  profile: HermesProfile(name: 'owl', model: 'sonnet'),
);

/// The Fold 6 inner screen, a seamless fold down its middle.
void useUnfolded(WidgetTester tester) {
  const size = Size(2160, 1856);
  const dpr = 2.625;
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = dpr
    ..displayFeatures = [
      DisplayFeature(
        bounds: Rect.fromLTWH(size.width / dpr / 2, 0, 0, size.height / dpr),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureFlat,
      ),
    ];
}

/// The cover screen.
void useFolded(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(968, 2376)
    ..devicePixelRatio = 2.8125
    ..displayFeatures = const [];
}

Widget _app(GoRouter router, {List<BotGroup> bots = const [_atlas]}) {
  final container = ProviderContainer(
    overrides: [
      keyValueStoreProvider.overrideWithValue(
        MemoryKeyValueStore({PreferenceKeys.gatewayUrl: 'http://gw.test:9119'}),
      ),
      secretStoreProvider.overrideWithValue(MemorySecretStore()),
      sidebarGroupsProvider.overrideWithValue(AsyncData(bots)),
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
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      theme: AppTheme.light(),
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

GoRouter _chatRouter() => GoRouter(
  initialLocation: Routes.chatPath('atlas'),
  routes: [
    GoRoute(
      path: Routes.chat,
      builder: (context, state) =>
          ChatShellScreen(profile: state.pathParameters[Routes.profileParam]),
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const Text('settings page'),
    ),
  ],
);

void main() {
  testWidgets('folding and unfolding keeps one chat: its text and scroller', (
    tester,
  ) async {
    useFolded(tester);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(_chatRouter()));
    await tester.pump();
    ProviderScope.containerOf(tester.element(find.byType(ChatView)))
        .read(composerSeedsProvider.notifier)
        .put(
          const BotTarget('atlas').key,
          const ComposerSeed(text: 'survive the fold'),
        );
    await tester.pumpAndSettle();
    expect(find.byType(SidebarPanel), findsNothing, reason: 'a drawer');
    final chat = tester.state<State>(find.byType(ChatView));
    final composer = tester.state<State>(find.byType(Composer));

    useUnfolded(tester);
    await tester.pumpAndSettle();
    expect(find.byType(SidebarPanel), findsOneWidget, reason: 'a side pane');
    expect(tester.state<State>(find.byType(ChatView)), same(chat));
    expect(tester.state<State>(find.byType(Composer)), same(composer));
    expect(find.text('survive the fold'), findsOneWidget);

    useFolded(tester);
    await tester.pumpAndSettle();
    expect(tester.state<State>(find.byType(ChatView)), same(chat));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('iPhone Duo: a drawer closed, a side pane open either way', (
    tester,
  ) async {
    // Xcode 27.1 profile, 3x. iOS reports no fold to Flutter.
    void use(Size px) => tester.view
      ..physicalSize = px
      ..devicePixelRatio = 3
      ..displayFeatures = const [];
    use(const Size(1398, 2034));
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(_chatRouter()));
    await tester.pumpAndSettle();
    expect(find.byType(SidebarPanel), findsNothing, reason: 'closed: drawer');

    for (final open in const [Size(2007, 2853), Size(2853, 2007)]) {
      use(open);
      await tester.pumpAndSettle();
      expect(find.byType(SidebarPanel), findsOneWidget, reason: '$open');
      expect(tester.takeException(), isNull);
    }
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('two panes: the side pane and the chat bar start on one line, '
      'clear of the screen edge', (tester) async {
    addTearDown(tester.view.reset);
    tester.view
      ..physicalSize = const Size(2853, 2007)
      ..devicePixelRatio = 3
      ..displayFeatures = const [];
    // The open iPhone Duo (no top inset), then a screen with a status bar.
    for (final (i, top) in const [0.0, 72.0].indexed) {
      tester.view.padding = FakeViewPadding(top: top);
      if (i == 0) await tester.pumpWidget(_app(_chatRouter()));
      await tester.pumpAndSettle();
      final side = tester.getTopLeft(find.byTooltip('Collapse menu')).dy;
      final chat = tester.getTopLeft(find.byTooltip('Find in conversation')).dy;
      expect(side, chat, reason: 'top inset $top');
      expect(side, greaterThanOrEqualTo(math.max(top / 3, 8)));
    }
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a tablet window gives the side pane room for more of each '
      "bot's last line", (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    for (final (i, (window, side)) in const [
      (Size(900, 700), 280.0), // a Fold open, on its side
      (Size(1024, 1366), 320.0), // iPad 13" upright
      (Size(1280, 800), 320.0), // Android tablet on its side
    ].indexed) {
      tester.view.physicalSize = window;
      if (i == 0) await tester.pumpWidget(_app(_chatRouter()));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(SidebarPanel)).width,
        side,
        reason: '$window',
      );
    }
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a hardware keyboard steps through the bots, opens one by its '
      'place and opens the settings', (tester) async {
    addTearDown(tester.view.reset);
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    final router = _chatRouter();
    await tester.pumpWidget(_app(router, bots: const [_atlas, _byte, _owl]));
    await tester.pumpAndSettle();
    String at() => router.routerDelegate.currentConfiguration.uri.path;

    Future<void> press(LogicalKeyboardKey key, {bool shift = false}) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(key);
      if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
    }

    await press(LogicalKeyboardKey.tab);
    expect(at(), Routes.chatPath('byte'));
    await press(LogicalKeyboardKey.digit3);
    expect(at(), Routes.chatPath('owl'));
    await press(LogicalKeyboardKey.tab);
    expect(at(), Routes.chatPath('atlas'), reason: 'round to the first');
    await press(LogicalKeyboardKey.tab, shift: true);
    expect(at(), Routes.chatPath('owl'));
    await press(LogicalKeyboardKey.comma);
    expect(find.text('settings page'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('the header folds hidden messages into ⋯ on a narrow pane; '
      'with nothing to fold there is no ⋯', (tester) async {
    final rig = bootChat(
      api: ScriptedApi()
        ..rows = const [SessionMessage(role: 'user', text: 'hi', rowId: 1)],
    );
    await pumpChat(tester, rig, width: 360);
    expect(find.byKey(const Key('chat-top-more')), findsNothing);

    await chatOf(rig).hide('row-1');
    await pumpChat(tester, rig, width: 360);
    expect(find.byKey(const Key('chat-top-more')), findsOneWidget);
    expect(find.byKey(const Key('chat-top-hidden')), findsNothing);
    await pumpChat(tester, rig, width: 840);
    expect(find.byKey(const Key('chat-top-more')), findsNothing);
    expect(find.byKey(const Key('chat-top-hidden')), findsOneWidget);
  });

  testWidgets("the title capsule opens the bot's details", (tester) async {
    await pumpChat(tester, bootChat(), width: 360);
    await tester.tap(find.byKey(const Key('chat-top-title')));
    await tester.pumpAndSettle();
    expect(find.byType(BotDetailsSheet), findsOneWidget);
  });
}
