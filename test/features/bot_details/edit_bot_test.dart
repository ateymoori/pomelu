import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hermes/app/routes.dart';
import 'package:hermes/core/theme/app_theme.dart';
import 'package:hermes/features/bot_details/presentation/widgets/bot_details_sheet.dart';
import 'package:hermes/features/bot_details/presentation/widgets/edit_bot_page.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/sidebar/presentation/sidebar_providers.dart';
import 'package:hermes/features/sidebar/presentation/widgets/new_bot_button.dart';
import 'package:hermes/hermes/models/profile.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';

import '../../support/app_host.dart';
import '../../support/fake_bot_api.dart';

/// The roster as [api] has it.
class _Roster extends Profiles {
  _Roster(this.api);

  final FakeBotApi api;

  @override
  Future<List<HermesProfile>> build() => api.listProfiles();
}

List<Override> _overrides(FakeBotApi api) => [
  hermesApiProvider.overrideWithValue(api),
  profilesProvider.overrideWith(() => _Roster(api)),
  profileAvatarProvider.overrideWith((ref, name) => null),
];

FakeBotApi _api() => FakeBotApi(
  bots: const [
    HermesProfile(name: 'atlas'),
    HermesProfile(name: 'default', isDefault: true),
  ],
);

void main() {
  testWidgets('the edit page saves a new name; the sheet shows it', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(800, 1600);
    addTearDown(tester.view.reset);
    final api = _api();
    await pumpApp(
      tester,
      const BotDetailsSheet(profile: 'atlas'),
      overrides: _overrides(api),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit bot'));
    await tester.pumpAndSettle();
    final save = find.byTooltip('Save');
    expect(
      tester
          .widget<IconButton>(
            find.descendant(of: save, matching: find.byType(IconButton)),
          )
          .onPressed,
      isNull,
    );

    await tester.enterText(
      find.descendant(
        of: find.byType(EditBotPage),
        matching: find.byType(TextField),
      ),
      'Atlas Prime',
    );
    await tester.pump();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(api.calls, contains('title:atlas:Atlas Prime'));
    expect(find.byType(EditBotPage), findsNothing);
    expect(find.text('Atlas Prime'), findsOneWidget);
  });

  testWidgets('delete asks first; the default bot offers no delete', (
    tester,
  ) async {
    final api = _api();
    BotEditResult? result;
    await pumpApp(
      tester,
      Builder(
        builder: (context) => Column(
          children: [
            for (final name in ['atlas', 'default'])
              TextButton(
                onPressed: () async => result = await Navigator.of(context)
                    .push<BotEditResult>(
                      MaterialPageRoute(
                        builder: (_) => EditBotPage(profile: name),
                      ),
                    ),
                child: Text('open $name'),
              ),
          ],
        ),
      ),
      overrides: _overrides(api),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open default'));
    await tester.pumpAndSettle();
    expect(find.text('Delete bot'), findsNothing);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('open atlas'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete bot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete bot'));
    await tester.pumpAndSettle();
    expect(find.text('Delete atlas?'), findsOneWidget);
    expect(api.calls, isNot(contains('deleteBot:atlas')));

    await tester.tap(find.text('Delete bot').last);
    await tester.pumpAndSettle();
    expect(api.calls, contains('deleteBot:atlas'));
    expect(result, BotEditResult.deleted);
  });

  testWidgets('New bot asks for a name, creates it and opens its chat', (
    tester,
  ) async {
    final api = _api();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (_, _) =>
              const Scaffold(body: Center(child: NewBotButton())),
        ),
        GoRoute(
          path: Routes.chat,
          builder: (_, state) =>
              Text('chat ${state.pathParameters[Routes.profileParam]}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(api),
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('New bot'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'My Work');
    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();

    expect(api.calls, ['create:my-work', 'title:my-work:My Work']);
    expect(find.text('chat my-work'), findsOneWidget);
  });

  testWidgets('the form offers characters; a picked one is saved', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    final api = _api();
    await pumpApp(
      tester,
      const EditBotPage(profile: 'atlas'),
      overrides: _overrides(api),
    );
    await tester.pumpAndSettle();
    expect(find.text('Remove photo'), findsNothing, reason: 'none yet');

    await tester.tap(find.bySemanticsLabel('Character 2'));
    await tester.pumpAndSettle();
    expect(find.text('Remove photo'), findsOneWidget);

    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();
    expect(api.calls, contains('avatar:atlas:set'));
  });
}
