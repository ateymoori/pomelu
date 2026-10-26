import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/bot_details/presentation/bot_details_providers.dart';
import 'package:hermes/features/bot_details/presentation/widgets/bot_details_sheet.dart';
import 'package:hermes/features/bot_details/presentation/widgets/soul_editor_page.dart';
import 'package:hermes/features/bot_details/presentation/widgets/soul_tab.dart';
import 'package:hermes/features/chat/presentation/widgets/markdown_body.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/bot_soul.dart';

import '../../support/app_host.dart';
import '../../support/fake_bot_api.dart';
import '../../support/fixtures.dart';

BotSoul _fixture() => BotSoul.fromJson(fixtureMap('soul.json'));

Future<void> _openTab(WidgetTester tester, FakeBotApi api) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpApp(
    tester,
    const BotDetailsSheet(profile: 'atlas'),
    overrides: [hermesApiProvider.overrideWithValue(api)],
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Instructions'));
  await tester.pumpAndSettle();
}

Future<void> _openEditor(WidgetTester tester) async {
  await tester.tap(find.text('Edit'));
  await tester.pumpAndSettle();
  expect(find.byType(SoulEditorPage), findsOneWidget);
}

Finder get _saveButton => find.byTooltip('Save');

void main() {
  testWidgets('the third tab shows the instructions as formatted text', (
    tester,
  ) async {
    await _openTab(tester, FakeBotApi(remoteSoul: _fixture()));

    expect(find.text('SOUL.md'), findsOneWidget);
    expect(find.textContaining('careful research assistant'), findsOneWidget);
    expect(find.text('Cite sources.'), findsOneWidget, reason: 'a list item');
    expect(find.text('Edit'), findsOneWidget);
    expect(find.textContaining('standing instructions'), findsNothing);
    // Skills and tools are read only; the note does not belong on this tab.
    expect(find.textContaining('read only'), findsNothing);
  });

  testWidgets('a bot with no file offers to write one', (tester) async {
    final api = FakeBotApi();
    await _openTab(tester, api);

    expect(find.text('No instructions yet'), findsOneWidget);
    await tester.tap(find.text('Write instructions'));
    await tester.pumpAndSettle();
    expect(find.byType(SoulEditorPage), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Be brief.');
    await tester.pump();
    await tester.tap(_saveButton);
    await tester.pumpAndSettle();

    expect(api.saved, ['Be brief.']);
    expect(find.text('Saved. A new session uses it.'), findsOneWidget);
    expect(find.textContaining('Be brief.'), findsOneWidget);
  });

  testWidgets('save stays off until something changed, then sends the text', (
    tester,
  ) async {
    final api = FakeBotApi(remoteSoul: _fixture());
    await _openTab(tester, api);
    await _openEditor(tester);

    expect(
      tester
          .widget<IconButton>(
            find.descendant(of: _saveButton, matching: find.byType(IconButton)),
          )
          .onPressed,
      isNull,
    );

    final edited = '${_fixture().content}- Be kind.\n';
    await tester.enterText(find.byType(TextField), edited);
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(
            find.descendant(of: _saveButton, matching: find.byType(IconButton)),
          )
          .onPressed,
      isNotNull,
    );

    await tester.tap(_saveButton);
    await tester.pumpAndSettle();

    expect(api.saved, [edited], reason: 'exactly what was typed');
    expect(find.byType(SoulEditorPage), findsNothing);
    expect(find.text('Saved. A new session uses it.'), findsOneWidget);
    expect(find.text('Be kind.'), findsOneWidget, reason: 'the tab re-read it');
  });

  testWidgets('closing with unsaved work asks first', (tester) async {
    final api = FakeBotApi(remoteSoul: _fixture());
    await _openTab(tester, api);
    await _openEditor(tester);
    await tester.enterText(find.byType(TextField), 'something else');
    await tester.pump();

    await tester.tap(find.byIcon(CupertinoIcons.xmark));
    await tester.pumpAndSettle();
    expect(find.text('Discard your changes?'), findsOneWidget);

    // Keep editing.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(SoulEditorPage), findsOneWidget);
    expect(find.text('something else'), findsOneWidget);

    // Now drop it.
    await tester.tap(find.byIcon(CupertinoIcons.xmark));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.byType(SoulEditorPage), findsNothing);
    expect(api.saved, isEmpty);
  });

  testWidgets('a change made elsewhere is not overwritten unasked', (
    tester,
  ) async {
    final api = FakeBotApi(remoteSoul: _fixture());
    await _openTab(tester, api);
    await _openEditor(tester);
    await tester.enterText(find.byType(TextField), 'my version');
    await tester.pump();

    // The dashboard (or the agent) writes the file meanwhile.
    api.remoteSoul = const BotSoul(content: 'their version', exists: true);
    await tester.tap(_saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Changed on the gateway'), findsOneWidget);
    expect(api.saved, isEmpty);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(api.saved, isEmpty, reason: 'declined');
    expect(find.byType(SoulEditorPage), findsOneWidget);

    await tester.tap(_saveButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Replace'));
    await tester.pumpAndSettle();
    expect(api.saved, ['my version']);
    expect(find.byType(SoulEditorPage), findsNothing);
  });

  testWidgets('a failed save says so and keeps the text', (tester) async {
    final api = FakeBotApi(remoteSoul: _fixture())
      ..saveFailure = const NetworkFailure('gateway away');
    await _openTab(tester, api);
    await _openEditor(tester);
    await tester.enterText(find.byType(TextField), 'draft');
    await tester.pump();

    await tester.tap(_saveButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Could not save: Cannot reach the gateway'),
      findsOneWidget,
    );
    expect(find.byType(SoulEditorPage), findsOneWidget);
    expect(find.text('draft'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.descendant(of: _saveButton, matching: find.byType(IconButton)),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('emptying the instructions is confirmed', (tester) async {
    final api = FakeBotApi(remoteSoul: _fixture());
    await _openTab(tester, api);
    await _openEditor(tester);
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    await tester.tap(_saveButton);
    await tester.pumpAndSettle();
    expect(find.text('Save empty instructions?'), findsOneWidget);
    expect(api.saved, isEmpty);

    await tester.tap(find.text('Save empty'));
    await tester.pumpAndSettle();
    expect(api.saved, ['']);
  });

  testWidgets('the editor opens on the file as it is now, not as shown', (
    tester,
  ) async {
    final api = FakeBotApi(remoteSoul: _fixture());
    await _openTab(tester, api);

    // The file changed and the tab is reading it again: it still shows the
    // old text meanwhile.
    api
      ..remoteSoul = const BotSoul(content: 'Newer words.', exists: true)
      ..soulGate = Completer<void>();
    ProviderScope.containerOf(tester.element(find.byType(SoulTab)))
        .invalidate(botSoulProvider('atlas'));
    await tester.pump();
    expect(find.textContaining('careful research assistant'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pump();
    expect(find.byType(SoulEditorPage), findsNothing, reason: 'it waits');

    api.soulGate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(SoulEditorPage), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'Newer words.',
    );
  });

  testWidgets('a long file is shown in pieces, built as they scroll in', (
    tester,
  ) async {
    final long = [
      for (var i = 0; i < 400; i++) 'Paragraph $i of the instructions.',
    ].join('\n\n');
    await _openTab(
      tester,
      FakeBotApi(remoteSoul: BotSoul(content: long, exists: true)),
    );

    expect(find.textContaining('Paragraph 0 '), findsOneWidget);
    expect(find.textContaining('Paragraph 399 '), findsNothing);
    expect(find.byType(MarkdownBody), findsWidgets);
  });
}
