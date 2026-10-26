import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hermes/app/routes.dart';
import 'package:hermes/core/storage/key_value_store.dart';
import 'package:hermes/core/storage/secret_store.dart';
import 'package:hermes/core/theme/app_theme.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/features/sidebar/domain/bot_group.dart';
import 'package:hermes/features/sidebar/presentation/sidebar_panel.dart';
import 'package:hermes/features/sidebar/presentation/sidebar_providers.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/models/profile.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';

import '../../support/memory_stores.dart';

const _atlas = BotGroup(
  profile: HermesProfile(
    name: 'atlas',
    isDefault: true,
    model: 'sonnet',
    description: 'Research bot',
  ),
);

const _hermes = BotGroup(
  profile: HermesProfile(name: 'hermes', model: 'haiku'),
);

Widget _app(GoRouter router, {bool configured = true}) {
  return ProviderScope(
    overrides: [
      keyValueStoreProvider.overrideWithValue(
        MemoryKeyValueStore({
          if (configured) PreferenceKeys.gatewayUrl: 'http://gw.test:9119',
        }),
      ),
      secretStoreProvider.overrideWithValue(MemorySecretStore()),
      sidebarGroupsProvider.overrideWithValue(
        const AsyncData([_atlas, _hermes]),
      ),
      connectionStateProvider.overrideWith(
        (ref) => Stream<HermesConnectionState>.value(
          const Connected(replayEpoch: 'x'),
        ),
      ),
      profileAvatarProvider.overrideWith((ref, name) => null),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light(),
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

GoRouter _router(Widget Function(BuildContext) build) => GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => Scaffold(body: build(context)),
      routes: [
        GoRoute(
          path: 'chat/:${Routes.profileParam}',
          builder: (context, state) => const Scaffold(body: Text('chat')),
        ),
      ],
    ),
  ],
);

void main() {
  testWidgets('the menu lists every bot, and no sessions', (tester) async {
    final router = _router((context) => const SidebarPanel());
    await tester.pumpWidget(_app(router));
    await tester.pump();

    expect(find.text('atlas'), findsOneWidget);
    expect(find.text('hermes'), findsOneWidget);
    expect(find.text('Research bot'), findsOneWidget);
    // One chat per bot: there is no Sessions tab any more.
    expect(find.text('Sessions'), findsNothing);
  });

  testWidgets('tapping a bot opens its chat and reports the navigation', (
    tester,
  ) async {
    var navigated = 0;
    final router = _router(
      (context) => SidebarPanel(onNavigate: () => navigated++),
    );
    await tester.pumpWidget(_app(router));
    await tester.pump();

    await tester.tap(find.text('atlas'));
    await tester.pumpAndSettle();

    expect(navigated, 1);
    expect(router.state.uri.toString(), Routes.chatPath('atlas'));
  });

  testWidgets('the collapse button asks the shell to shrink the menu', (
    tester,
  ) async {
    final router = _router((context) => const SidebarPanel(collapsible: true));
    await tester.pumpWidget(_app(router));
    await tester.pump();

    expect(find.byTooltip('Collapse menu'), findsOneWidget);
  });

  testWidgets('with no gateway, the drawer says so and the side pane stays '
      'quiet (the chat pane beside it says it)', (tester) async {
    await tester.pumpWidget(
      _app(_router((context) => const SidebarPanel()), configured: false),
    );
    await tester.pump();
    expect(find.text('No gateway'), findsOneWidget);

    await tester.pumpWidget(
      _app(
        _router((context) => const SidebarPanel(collapsible: true)),
        configured: false,
      ),
    );
    await tester.pump();
    expect(find.text('No gateway'), findsNothing);
    expect(find.text('Open settings'), findsNothing);
  });
}
