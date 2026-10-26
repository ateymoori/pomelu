import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/bot_details/presentation/widgets/bot_details_sheet.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/bot_skill.dart';
import 'package:hermes/hermes/models/bot_toolset.dart';

import '../../support/app_host.dart';
import '../../support/fake_bot_api.dart';
import '../../support/fixtures.dart';

Widget _app(FakeBotApi api, Widget home) =>
    appHost(home, overrides: [hermesApiProvider.overrideWithValue(api)]);

Future<void> _open(WidgetTester tester, FakeBotApi api) async {
  // Tall enough for the whole list: rows below the fold are not built.
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(api, const BotDetailsSheet(profile: 'atlas')));
  await tester.pumpAndSettle();
}

/// A gateway that serves the fixtures, and can be made to fail.
FakeBotApi _api() => FakeBotApi(
  skillList: fixtureList('skills.json', BotSkill.fromJson),
  toolsetList: fixtureList('toolsets.json', BotToolset.fromJson),
);

void main() {
  testWidgets('skills: only what is on, grouped by category', (tester) async {
    final api = _api();
    await _open(tester, api);

    // Only the open tab asks the gateway.
    expect(api.calls, ['skills:atlas']);
    expect(find.text('Github'), findsOneWidget);
    expect(find.text('Software development'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('github-pr-workflow'), findsOneWidget);
    expect(find.text('github-issues'), findsNothing, reason: 'turned off');
    expect(find.text('apple-notes'), findsNothing, reason: 'turned off');
  });

  testWidgets('tools: every tool of every toolset that is on', (tester) async {
    final api = _api();
    await _open(tester, api);

    await tester.tap(find.text('Tools'));
    await tester.pumpAndSettle();
    expect(api.calls, contains('toolsets:atlas'));
    expect(find.text('Web Search & Scraping'), findsOneWidget);
    expect(find.text('web_search'), findsOneWidget);
    expect(find.text('read_file'), findsOneWidget);
    expect(find.text('Image Generation'), findsNothing, reason: 'turned off');
    expect(find.text('image_generate'), findsNothing);
  });

  testWidgets('a failed load can be retried', (tester) async {
    final api = _api()
      ..capabilitiesFailure = const NetworkFailure('gateway away');
    await _open(tester, api);

    expect(find.text('Could not load'), findsOneWidget);
    expect(find.text('Cannot reach the gateway'), findsOneWidget);

    api.capabilitiesFailure = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load'), findsNothing);
    expect(find.text('github-pr-workflow'), findsOneWidget);
  });

  testWidgets('with no gateway connection the sheet says so', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(
      tester,
      const BotDetailsSheet(profile: 'atlas'),
      overrides: [hermesApiProvider.overrideWithValue(null)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not load'), findsOneWidget);
    expect(find.text('Cannot reach the gateway'), findsOneWidget);
  });
}
