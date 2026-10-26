import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/models/bot_soul.dart';

import '../../support/fake_bot_api.dart';
import '../../support/fixtures.dart';
import 'bot_details_a11y_harness.dart';

void main() {
  group('instructions', () {
    testWidgets('the saved note is a live region', (tester) async {
      final handle = tester.ensureSemantics();
      final api = FakeBotApi(
        remoteSoul: BotSoul.fromJson(fixtureMap('soul.json')),
      );
      await open(tester, api, tab: 'Instructions');
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Be brief.');
      await tester.pump();
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(
          find.bySemanticsLabel(RegExp('Saved. A new session')),
        ),
        isSemantics(isLiveRegion: true),
      );
      handle.dispose();
    });

    testWidgets('the text direction settles once typing pauses', (
      tester,
    ) async {
      final api = FakeBotApi(
        remoteSoul: BotSoul.fromJson(fixtureMap('soul.json')),
      );
      await open(tester, api, tab: 'Instructions');
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      TextDirection? direction() =>
          tester.widget<TextField>(find.byType(TextField)).textDirection;
      expect(direction(), TextDirection.ltr);

      await tester.enterText(
        find.byType(TextField),
        'سلام دنیا، این یک آزمایش است',
      );
      await tester.pump();
      expect(
        direction(),
        TextDirection.ltr,
        reason: 'not worked out on every keystroke',
      );

      await tester.pump(tokens.motion.normal);
      expect(direction(), TextDirection.rtl);
    });
  });
}
