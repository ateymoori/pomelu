import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/gestures.dart' show kSecondaryButton;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/chat/data/link_opener.dart';
import 'package:hermes/features/chat/presentation/read_aloud.dart';
import 'package:hermes/features/chat/presentation/widgets/context_meter.dart';
import 'package:hermes/features/chat/presentation/widgets/message_actions.dart';
import 'package:hermes/hermes/api/hermes_api.dart';
import 'package:hermes/hermes/events/gateway_event.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/context_breakdown.dart';
import 'package:hermes/hermes/models/session_message.dart';
import 'package:hermes/hermes/models/session_resume.dart';
import 'package:hermes/hermes/models/session_summary.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../support/scripted_api.dart';
import 'chat_harness.dart';

const _rows = [
  SessionMessage(role: 'user', text: 'what is hermes?', rowId: 1),
  SessionMessage(
    role: 'assistant',
    text: 'Hermes is the **gateway**.',
    rowId: 2,
  ),
];

Future<ChatRig> openChat(
  WidgetTester tester, {
  ScriptedApi? api,
  List<Override> overrides = const [],
}) async {
  final rig = bootChat(
    api: (api ?? ScriptedApi())..rows = _rows,
    overrides: overrides,
  );
  await pumpChat(tester, rig);
  return rig;
}

/// Opens the long-press menu of the row showing [text].
Future<void> longPress(WidgetTester tester, String text) async {
  await tester.longPress(find.text(text), warnIfMissed: false);
  await settle(tester);
}

/// Opens the menu of the saved reply. Its text is selectable; its menu is
/// the "More actions" of the selection bar and the row's accessibility
/// action.
Future<void> replyActions(WidgetTester tester) async {
  tester
      .widget<MessageActionsSemantics>(
        find
            .ancestor(
              of: find.textContaining('Hermes is the', findRichText: true),
              matching: find.byType(MessageActionsSemantics),
            )
            .first,
      )
      .onActions();
  await settle(tester);
}

/// Settles what can settle while a turn runs (its activity line animates).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Plays until stopped.
class _Speaker implements SpeechOutput {
  Completer<void>? playing;

  @override
  Future<void> play(SpeechAudio audio) => (playing = Completer<void>()).future;

  @override
  Future<void> stop() async => playing?.complete();
}

void main() {
  testWidgets('a streamed reply shows its thinking, tools and Markdown', (
    tester,
  ) async {
    final rig = await openChat(tester);
    rig.client
      ..emit(ev(EventNames.messageStart))
      ..emit(ev(EventNames.reasoningDelta, {'text': 'pondering deeply'}))
      ..emit(ev(EventNames.toolStart, {'tool_id': 't', 'name': 'search'}))
      ..emit(ev(EventNames.messageDelta, {'text': 'Found **it**'}));
    await tester.pump();
    await tester.pump();
    expect(find.text('Thinking'), findsWidgets);
    expect(find.textContaining('search'), findsOneWidget);
    expect(find.textContaining('Found', findRichText: true), findsOneWidget);
    expect(
      find.byIcon(CupertinoIcons.stop_fill),
      findsOneWidget,
      reason: 'send is stop',
    );
    await tester.tap(find.byIcon(CupertinoIcons.stop_fill));
    await tester.pump();
    expect(rig.api.interrupts, ['rt-1']);
    rig.client.emit(ev(EventNames.messageComplete, {'status': 'interrupted'}));
    await tester.pump();
    expect(find.byIcon(CupertinoIcons.stop_fill), findsNothing);
  });

  testWidgets('the plan docks while the turn runs and opens to its steps', (
    tester,
  ) async {
    final rig = await openChat(tester);
    rig.client
      ..emit(ev(EventNames.messageStart))
      ..emit(
        ev(EventNames.todoUpdated, {
          'revision': 1,
          'todos': [
            {'id': '1', 'content': 'Read the logs', 'status': 'completed'},
            {'id': '2', 'content': 'Fix the bug', 'status': 'in_progress'},
          ],
        }),
      );
    await settle(tester);
    expect(find.text('Plan · 1 of 2'), findsOneWidget);
    expect(find.text('Fix the bug'), findsOneWidget);
    expect(find.text('Read the logs'), findsNothing);
    await tester.tap(find.text('Plan · 1 of 2'));
    await settle(tester);
    expect(find.text('Read the logs'), findsOneWidget);
    rig.client.emit(ev(EventNames.messageComplete, {'status': 'complete'}));
    await settle(tester);
    expect(find.textContaining('Plan ·'), findsNothing);
  });

  testWidgets("a reply is read aloud in the bot's voice until stopped", (
    tester,
  ) async {
    final speaker = _Speaker();
    final api = ScriptedApi();
    await openChat(
      tester,
      api: api,
      overrides: [speechOutputProvider.overrideWithValue(speaker)],
    );
    await replyActions(tester);
    await tester.tap(find.text('Read aloud'));
    await settle(tester);
    expect(api.spoken, ['Hermes is the **gateway**.']);
    expect(speaker.playing?.isCompleted, isFalse);
    // The bar stays while it reads, past a snack bar's usual time.
    await tester.pump(const Duration(seconds: 6));
    expect(find.textContaining('Reading aloud'), findsOneWidget);
    await replyActions(tester);
    await tester.tap(find.text('Stop reading').last);
    await settle(tester);
    expect(speaker.playing!.isCompleted, isTrue);
    await tester.pumpAndSettle();
    expect(find.textContaining('Reading aloud'), findsNothing);
  });

  testWidgets('typing and sending puts the turn on the wire', (tester) async {
    final rig = await openChat(tester);
    await tester.enterText(find.byType(TextField), 'hello there');
    await tester.pump();
    await tester.tap(find.byIcon(CupertinoIcons.arrow_up));
    await settle(tester);
    expect(rig.api.prompts, ['hello there']);
    expect(find.text('hello there'), findsOneWidget);
  });

  testWidgets('a hardware keyboard: Return sends, Shift-Return starts a '
      'new line', (tester) async {
    final rig = await openChat(tester);
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'two');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    final draft = tester.widget<TextField>(find.byType(TextField)).controller!;
    expect(draft.text, 'two\n');
    expect(rig.api.prompts, isEmpty);
    await tester.enterText(find.byType(TextField), '${draft.text}lines');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await settle(tester);
    expect(rig.api.prompts, ['two\nlines']);
    expect(draft.text, isEmpty);
    // Where the keyboard's app types a plain Return (Gboard), Control sends.
    rig.client.emit(ev(EventNames.messageComplete, {'status': 'complete'}));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'three');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settle(tester);
    expect(rig.api.prompts, ['two\nlines', 'three']);
  });

  testWidgets('a right-click on a message opens its actions', (tester) async {
    await openChat(tester);
    await tester.tap(find.text('what is hermes?'), buttons: kSecondaryButton);
    await settle(tester);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('the slash palette runs /restart only after a confirm', (
    tester,
  ) async {
    final rig = await openChat(tester);
    await tester.enterText(find.byType(TextField), '/re');
    await tester.pump();
    expect(find.text('/restart'), findsOneWidget);
    expect(find.text('/new'), findsNothing);
    await tester.tap(find.text('/restart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('/re'), findsOneWidget, reason: 'the text stays');
    await tester.tap(find.text('/restart'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Restart'));
    await tester.pumpAndSettle();
    expect(find.text('/restart'), findsOneWidget, reason: 'the command row');
    expect(rig.api.prompts, isEmpty, reason: 'a command is not a prompt');
  });

  testWidgets('a turn refused because the chat is open elsewhere says so', (
    tester,
  ) async {
    final rig = await openChat(tester);
    rig.api.submitScript.add(
      const SessionBusyFailure(
        'open elsewhere',
        reason: HermesProtocol.sessionNotOwned,
      ),
    );
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    await tester.tap(find.byIcon(CupertinoIcons.arrow_up));
    await tester.pumpAndSettle();

    expect(find.text('Not sent · tap to retry'), findsOneWidget);
    expect(
      find.textContaining('open in another Hermes window'),
      findsOneWidget,
    );
  });

  testWidgets(
    'a failed turn offers retry, edit and discard; one going out none',
    (tester) async {
      final rig = await openChat(tester);
      rig.api.submitScript.add(const ServerFailure('rejected'));
      await tester.enterText(find.byType(TextField), 'refused one');
      await tester.pump();
      await tester.tap(find.byIcon(CupertinoIcons.arrow_up));
      await tester.pumpAndSettle();
      await longPress(tester, 'refused one');
      expect(find.text('Send again'), findsOneWidget);
      expect(find.text('Edit and resend'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.text('refused one'), findsNothing);

      rig.api.submitGate = Completer<void>();
      await tester.enterText(find.byType(TextField), 'in flight');
      await tester.pump();
      await tester.tap(find.byIcon(CupertinoIcons.arrow_up));
      await tester.pump();
      await longPress(tester, 'in flight');
      expect(find.text('Send again'), findsNothing);
      expect(find.text('Discard'), findsNothing);
      await tester.tapAt(Offset.zero);
      rig.api.submitGate!.complete();
      await settle(tester);
    },
  );

  testWidgets('copy, quote and delete from a saved turn', (tester) async {
    final rig = await openChat(tester);
    final copied = <String?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String?);
        }
        return null;
      },
    );
    await longPress(tester, 'what is hermes?');
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(copied, ['what is hermes?']);

    await longPress(tester, 'what is hermes?');
    await tester.tap(find.text('Quote reply'));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, '> what is hermes?\n\n');

    await longPress(tester, 'what is hermes?');
    await tester.tap(find.text('Delete from here'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(rig.api.undos, 1);
    expect(find.text('what is hermes?'), findsNothing);
  });

  testWidgets(
    'a reply can be reported to the developer by email, an own turn not',
    (tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'Pomelu',
        packageName: 'se.royan.pomelu',
        version: '1.2.3',
        buildNumber: '1',
        buildSignature: '',
      );
      final mailed = <Uri>[];
      await openChat(
        tester,
        overrides: [
          linkLauncherProvider.overrideWithValue((uri) async {
            mailed.add(uri);
            return true;
          }),
        ],
      );
      await longPress(tester, 'what is hermes?');
      expect(find.text('Report'), findsNothing);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      await replyActions(tester);
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('False or misleading'));
      await tester.pumpAndSettle();
      final mail = mailed.single;
      expect(mail.scheme, 'mailto');
      expect(mail.path, 'contact@royan.se');
      final body = Uri.decodeComponent(mail.query);
      expect(body, contains('Reason: misleading'));
      expect(body, contains('Pomelu 1.2.3'));
      expect(body, contains('Hermes is the **gateway**.'));
      expect(mail.query, isNot(contains('+')));
    },
  );

  testWidgets('find counts the hits and walks them', (tester) async {
    await openChat(tester);
    await tester.tap(find.byKey(const Key('chat-top-search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'hermes');
    await tester.pumpAndSettle();
    expect(find.text('1 of 2'), findsOneWidget);
    await tester.tap(find.byIcon(CupertinoIcons.chevron_down));
    await tester.pumpAndSettle();
    expect(find.text('2 of 2'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('2 of 2'), findsNothing);
  });

  testWidgets('the context meter opens what fills the window', (tester) async {
    final rig = await openChat(tester);
    rig.client.emit(
      ev(EventNames.sessionUsage, {
        'usage': {
          'input': 10,
          'output': 5,
          'context_max': 1000,
          'context_used': 500,
        },
      }),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('context-meter')));
    await tester.pumpAndSettle();
    expect(find.text('Context usage'), findsOneWidget);
    expect(find.text('50%'), findsNWidgets(2));
    await tester.tap(find.byKey(const Key('context-meter-compact')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('context-meter-compact-confirm')));
    await tester.pumpAndSettle();
    expect(
      find.text('Context usage'),
      findsNothing,
      reason: 'compacted, the sheet closes',
    );
  });

  testWidgets('usage without the window share shows the estimate; with '
      'none the meter shows no figure', (tester) async {
    final api = ScriptedApi();
    final rig = await openChat(tester, api: api);
    rig.client.emit(
      ev(EventNames.sessionUsage, {
        'usage': {'input': 10, 'output': 5},
      }),
    );
    // pumpAndSettle returns: nothing spins.
    await tester.pumpAndSettle();
    expect(find.byTooltip('Context usage unavailable'), findsOneWidget);

    api.breakdown = const ContextBreakdown(contextMax: 1000, contextUsed: 250);
    rig.container.invalidate(contextEstimateProvider(api.runtimeId));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Context window, 25 percent used'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
  });

  testWidgets('a short transcript loads the conversation before it', (
    tester,
  ) async {
    final api = ScriptedApi();
    api.chain['stored-1'] = const SessionSummary(
      id: 'stored-1',
      parentSessionId: 'old',
    );
    api.stored['old'] = const [SessionMessage(role: 'user', text: 'long ago')];
    await openChat(tester, api: api);
    expect(find.text('long ago'), findsOneWidget);
    expect(find.text('New conversation'), findsOneWidget);
  });

  testWidgets('the question the agent waits on docks above the composer', (
    tester,
  ) async {
    final api = ScriptedApi()
      ..resume = (id) => SessionResume(
        sessionId: 'rt-1',
        storedSessionId: id,
        openRequests: const [
          {
            'id': 'srq-1',
            'method': 'approval',
            'params': {'session_id': 'rt-1', 'command': 'rm -rf /tmp/x'},
          },
        ],
      );
    await openChat(tester, api: api);
    expect(find.text('rm -rf /tmp/x'), findsOneWidget);
    expect(find.text('Allow once'), findsOneWidget);
  });
}
