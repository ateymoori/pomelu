import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/chat/domain/clarify_draft.dart';
import 'package:hermes/features/chat/presentation/widgets/request_card.dart';
import 'package:hermes/hermes/requests/clarify_question.dart';
import 'package:hermes/hermes/requests/server_request.dart';

import '../../support/app_host.dart';

/// What each card sent, and what it should answer back.
class Calls {
  final List<Object?> sent = [];
  bool settles = true;

  bool record(Object? value) {
    sent.add(value);
    return settles;
  }
}

Future<Calls> pumpCard(
  WidgetTester tester,
  ServerRequest request, {
  bool settles = true,
}) async {
  final calls = Calls()..settles = settles;
  await pumpApp(
    tester,
    SingleChildScrollView(
      child: PendingRequestCard(
        request: request,
        onClarify: calls.record,
        onSkip: () => calls.record('skip'),
        onApproval: calls.record,
        onInput: calls.record,
      ),
    ),
  );
  return calls;
}

const _single = ClarifyQuestion(
  qid: 'q',
  question: 'Which one?',
  choices: ['Red (Recommended)', 'Blue'],
);

void main() {
  testWidgets('a lone single-choice question sends on tap', (tester) async {
    final calls = await pumpCard(
      tester,
      const ServerRequest.clarify(
        id: '1',
        sessionId: 's',
        questions: [_single],
      ),
    );
    expect(find.text('Recommended', findRichText: true), findsNothing);
    await tester.tap(find.textContaining('Blue', findRichText: true));
    await tester.pump();
    expect(calls.sent, [
      {'q': 'Blue'},
    ]);
  });

  testWidgets('several questions go together; an empty one is skipped', (
    tester,
  ) async {
    final calls = await pumpCard(
      tester,
      const ServerRequest.clarify(
        id: '1',
        sessionId: 's',
        questions: [
          ClarifyQuestion(
            qid: 'm',
            question: 'Which?',
            choices: ['A', 'B'],
            multiSelect: true,
          ),
          ClarifyQuestion(qid: 'f', question: 'Why?'),
        ],
      ),
    );
    await tester.tap(find.textContaining('B', findRichText: true).first);
    await tester.pump();
    await tester.tap(find.text('Send'));
    await tester.pump();
    expect(calls.sent, [
      {'m': '["B"]', 'f': null},
    ]);
  });

  test('a draft restores the answers the gateway already holds', () {
    const q = ClarifyQuestion(
      qid: 'm',
      question: '?',
      choices: ['A', 'B (Recommended)'],
      multiSelect: true,
    );
    final draft = ClarifyDraft.restore(const [q], const {'m': '["B","other"]'});
    expect(draft.isPicked(q, 'B (Recommended)'), isTrue);
    expect(draft.typedFor(q), 'other');
    expect(draft.answerFor(q), '["B (Recommended)","other"]');
  });

  testWidgets(
    'an approval offers the gateway choices; a dead socket re-enables',
    (tester) async {
      final calls = await pumpCard(
        tester,
        const ServerRequest.approval(
          id: '2',
          sessionId: 's',
          command: 'rm -rf /',
        ),
        settles: false,
      );
      expect(find.text('rm -rf /'), findsOneWidget);
      await tester.tap(find.text('Deny'));
      await tester.pump();
      await tester.tap(find.text('Deny'));
      await tester.pump();
      expect(calls.sent, [
        'deny',
        'deny',
      ], reason: 'not settled: it can go again');
    },
  );

  testWidgets('a masked input sends its value, and Skip sends nothing', (
    tester,
  ) async {
    final calls = await pumpCard(
      tester,
      const ServerRequest.input(id: '3', sessionId: 's', kind: InputKind.sudo),
      settles: false,
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect((field.obscureText, field.enableSuggestions), (true, false));
    await tester.enterText(find.byType(TextField), 'hunter2');
    await tester.pump();
    await tester.tap(find.text('Send'));
    await tester.pump();
    await tester.tap(find.text('Skip'));
    await tester.pump();
    expect(calls.sent, ['hunter2', '']);
  });
}
