import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/chat/domain/chat_message.dart';
import 'package:hermes/features/chat/domain/chat_reducer.dart';
import 'package:hermes/features/chat/domain/chat_state.dart';
import 'package:hermes/features/chat/domain/transcript.dart';
import 'package:hermes/hermes/events/gateway_event.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/local_attachment.dart';
import 'package:hermes/hermes/models/session_message.dart';
import 'package:hermes/hermes/models/session_resume.dart';

import 'chat_harness.dart';

const base = ChatState(runtimeId: 'rt-1', storedId: 'st', profile: 'atlas');

ChatState run(List<(String, Map<String, dynamic>)> events) =>
    events.fold(base, (s, e) => ChatReducer.apply(s, ev(e.$1, e.$2), t0));

void main() {
  test('a streamed reply grows, and the complete frame has the last word', () {
    var s = run([
      (EventNames.messageStart, {}),
      (EventNames.reasoningDelta, {'text': 'let me '}),
      (EventNames.reasoningDelta, {'text': 'think'}),
      (EventNames.messageDelta, {'text': 'Hel'}),
      (EventNames.messageDelta, {'text': 'lo'}),
    ]);
    expect(s.running, isTrue);
    expect(s.streamingMessage!.text, 'Hello');
    expect(s.streamingMessage!.reasoning, 'let me think');
    s = ChatReducer.apply(
      s,
      ev(EventNames.messageComplete, {
        'text': 'Hello!\nMEDIA: /out/chart.png',
        'status': 'complete',
      }),
      t0,
    );
    final m = s.messages.single;
    expect(s.running, isFalse);
    expect(m.text, 'Hello!');
    expect(m.media.single.kind, AttachmentKind.image);
    expect(m.streaming, isFalse);
  });

  test('tools upsert by id, or by name while running', () {
    final s = run([
      (EventNames.toolStart, {'tool_id': 'c1', 'name': 'read', 'context': 'a'}),
      (
        EventNames.toolComplete,
        {'tool_id': 'c1', 'result': 'ok', 'duration_s': 0.4},
      ),
      (EventNames.toolStart, {'name': 'bash'}),
      (EventNames.toolComplete, {'name': 'bash', 'error': true}),
    ]);
    final tools = s.streamingMessage!.tools;
    expect(tools.map((t) => t.state), [ToolState.done, ToolState.failed]);
    expect(tools.first.name, 'read');
    expect(tools.first.context, 'a');
    expect(tools.first.resultText, 'ok');
    expect(tools.first.durationSeconds, 0.4);
  });

  test('activity labels: thinking, a tool being written, the status line', () {
    var s = run([
      (EventNames.thinkingDelta, {'text': 'Pondering'}),
    ]);
    expect(s.thinkingLabel, 'Pondering');
    expect(s.streamingMessage, isNull, reason: 'thinking is not reasoning');
    s = ChatReducer.apply(
      s,
      ev(EventNames.toolGenerating, {'name': 'grep'}),
      t0,
    );
    expect(s.thinkingLabel, 'grep');
    s = ChatReducer.apply(s, ev(EventNames.messageDelta, {'text': 'x'}), t0);
    expect(s.thinkingLabel, isEmpty);
    s = ChatReducer.apply(s, ev(EventNames.statusUpdate, {'text': 'busy'}), t0);
    expect(s.statusLine, 'busy');
  });

  test('reasoning that repeats the reply is not shown twice', () {
    final s = run([
      (EventNames.reasoningAvailable, {'text': 'The answer is 4.'}),
      (EventNames.messageDelta, {'text': 'The answer is 4.'}),
    ]);
    expect(s.streamingMessage!.visibleReasoning, isEmpty);
  });

  test('an interim message seals its bubble; the next delta starts anew', () {
    final s = run([
      (EventNames.messageInterim, {'text': 'step one'}),
      (EventNames.messageDelta, {'text': 'step two'}),
    ]);
    expect(s.messages.map((m) => (m.text, m.interim)), [
      ('step one', true),
      ('step two', false),
    ]);
  });

  test('an interrupted turn ends, and an empty reply row goes', () {
    final s = run([
      (EventNames.messageStart, {}),
      (EventNames.messageComplete, {'status': TurnStatus.interrupted}),
    ]);
    expect(s.messages, isEmpty);
    expect(s.running, isFalse);
    expect(s.statusLine, TurnStatus.interrupted);
  });

  test(
    'a failed turn keeps its row with the error; an error event says why',
    () {
      var s = run([
        (EventNames.messageDelta, {'text': 'half'}),
        (EventNames.messageComplete, {'status': 'error', 'error': 'quota'}),
      ]);
      expect(s.messages.single.error, 'quota');
      s = ChatReducer.apply(s, ev(EventNames.error, {'message': 'boom'}), t0);
      expect(s.error, isA<ServerFailure>());
    },
  );

  test('a stale message.start after a stop does not revive the turn', () {
    final s = ChatReducer.apply(
      base.copyWith(stopRequested: true),
      ev(EventNames.messageStart),
      t0,
    );
    expect(s.running, isFalse);
    expect(s.messages, isEmpty);
  });

  test('the plan follows its newest revision and goes when the turn ends', () {
    Map<String, dynamic> plan(int revision, String status) => {
      'revision': revision,
      'todos': [
        {'id': '1', 'content': 'Read the logs', 'status': 'completed'},
        {'id': '2', 'content': 'Fix the bug', 'status': status},
        {'id': '3', 'content': '', 'status': 'pending'},
      ],
    };
    var s = run([
      (EventNames.messageStart, {}),
      (EventNames.todoUpdated, plan(2, 'in_progress')),
      (EventNames.todoUpdated, plan(1, 'pending')),
    ]);
    expect(s.plan!.items, hasLength(2));
    expect(s.plan!.current!.content, 'Fix the bug');
    expect((s.plan!.done, s.plan!.total), (1, 2));
    s = ChatReducer.apply(
      s,
      ev(EventNames.messageComplete, {'status': 'complete'}),
      t0,
    );
    expect(s.plan, isNull);
  });

  test('session.info running=false seals the stream and names the model', () {
    final s = ChatReducer.apply(
      run([
        (EventNames.messageDelta, {'text': 'x'}),
      ]),
      ev(EventNames.sessionInfo, {'running': false, 'model': 'gpt-x'}),
      t0,
    );
    expect(s.streamingMessage, isNull);
    expect(s.model, 'gpt-x');
    expect(s.running, isFalse);
  });

  group('history', () {
    test('a turn saved as one row per tool call reads as one turn', () {
      final rows = Transcript.fromHistory(const [
        SessionMessage(role: 'user', text: 'go'),
        SessionMessage(role: 'assistant'),
        SessionMessage(role: 'tool', name: 'grep'),
        SessionMessage(role: 'assistant'),
        SessionMessage(role: 'tool', name: 'read'),
        SessionMessage(role: 'assistant', text: 'done\nMEDIA: "/a b.mp4"'),
      ]);
      expect(rows, hasLength(2));
      expect(rows.last.tools.map((t) => t.name), ['grep', 'read']);
      expect(rows.last.text, 'done');
      expect(rows.last.media.single.kind, AttachmentKind.video);
    });

    test('command rows go back among the reloaded rows by time', () {
      final at = DateTime.utc(2026);
      final note = ChatMessage(
        id: 'n',
        role: ChatRole.system,
        command: '/compact',
        timestamp: at.add(const Duration(minutes: 1)),
      );
      final merged = Transcript.withCommands(
        [
          ChatMessage(id: 'a', role: ChatRole.user, timestamp: at),
          ChatMessage(
            id: 'b',
            role: ChatRole.user,
            timestamp: at.add(const Duration(minutes: 2)),
          ),
        ],
        [note],
      );
      expect(merged.map((m) => m.id), ['a', 'n', 'b']);
    });

    test(
      'a resume mid-turn shows its question, its words and the queued one',
      () {
        final s = Transcript.restoreInflight(
          base,
          const SessionResume(
            sessionId: 'rt-1',
            running: true,
            inflight: Inflight(user: 'q', assistant: 'partial'),
            queued: QueuedPrompt(user: 'next'),
          ),
          t0,
        );
        expect(s.messages.map((m) => m.text), ['q', 'partial', 'next']);
        expect(s.running, isTrue);
        // A second restore replaces, never doubles.
        final again = Transcript.restoreInflight(
          s,
          const SessionResume(
            sessionId: 'rt-1',
            inflight: Inflight(user: 'q', assistant: 'partial', error: 'x'),
          ),
          t0,
        );
        expect(again.messages.map((m) => m.text), ['q', 'partial']);
        expect(again.messages.last.error, 'x');
      },
    );
  });
}
