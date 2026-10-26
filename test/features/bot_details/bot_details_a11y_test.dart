import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/bot_skill.dart';
import 'package:hermes/hermes/models/bot_soul.dart';
import 'package:hermes/hermes/models/bot_toolset.dart';

import '../../support/fake_bot_api.dart';
import '../../support/fixtures.dart';
import 'bot_details_a11y_harness.dart';

void main() {
  group('the sheet', () {
    testWidgets("a section header starts where its rows' text does", (
      tester,
    ) async {
      await open(tester, capabilities());

      final category = tester.getTopLeft(find.text('Github')).dx;
      final skill = tester.getTopLeft(find.text('github-pr-workflow')).dx;

      expect(category, closeTo(skill, 0.5));
    });
  });

  group('large text and narrow windows', () {
    for (final (width, height) in [(344.0, 640.0), (840.0, 700.0)]) {
      testWidgets('every tab fits $width dp at 2x text', (tester) async {
        final api = FakeBotApi(
          skillList: fixtureList('skills.json', BotSkill.fromJson),
          toolsetList: fixtureList('toolsets.json', BotToolset.fromJson),
          jobs: [
            job('daily-news'),
            job('weekly-mail', status: 'error'),
          ],
          remoteSoul: BotSoul.fromJson(fixtureMap('soul.json')),
        );
        await open(tester, api, window: Size(width, height), textScale: 2);
        expect(tester.takeException(), isNull);

        for (final tab in ['Tools', 'Instructions', 'Cron', 'Skills']) {
          await tester.tap(find.text(tab));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'the $tab tab');
        }
      });
    }

    testWidgets('a failed load scrolls in a short sheet at 2x text', (
      tester,
    ) async {
      final api = capabilities()
        ..capabilitiesFailure = const NetworkFailure('gateway away');
      await open(tester, api, window: const Size(344, 360), textScale: 2);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('Retry'),
        60,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('skills and tools', () {
    testWidgets('categories and toolsets are announced as headings', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await open(tester, capabilities());

      expect(
        tester.getSemantics(find.text('Github')),
        isSemantics(label: 'Github', isHeader: true),
      );

      await tester.tap(find.text('Tools'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('Web Search & Scraping')),
        isSemantics(label: 'Web Search & Scraping', isHeader: true),
      );
      handle.dispose();
    });
  });
}
