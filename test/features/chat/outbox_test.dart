import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/chat/domain/chat_message.dart';
import 'package:hermes/features/chat/domain/outbox.dart';
import 'package:hermes/hermes/models/local_attachment.dart';

import 'chat_harness.dart';

ChatMessage userRow(String text, {DateTime? at}) =>
    ChatMessage(id: 'r-$text', role: ChatRole.user, text: text, timestamp: at);

void main() {
  test('a full queue takes no new turn and drops none it has', () {
    var q = <OutboxEntry>[];
    for (var i = 0; i < Outbox.maxEntries; i++) {
      q = Outbox.enqueue(q, entry('$i', 'turn $i'));
    }
    expect(Outbox.enqueue(q, entry('x', 'one more')), same(q));
    expect(Outbox.enqueue(const [], entry('e', ' ')), isEmpty);
  });

  test(
    'only the head goes out: anything not waiting holds the ones behind',
    () {
      expect(Outbox.next([entry('a', 'a'), entry('b', 'b')])!.id, 'a');
      for (final status in [
        OutboxStatus.sending,
        OutboxStatus.submitted,
        OutboxStatus.failed,
      ]) {
        expect(
          Outbox.next([entry('a', 'a', status: status), entry('b', 'b')]),
          isNull,
        );
      }
    },
  );

  test('a network miss on the last attempt fails the entry for the user', () {
    final spent = Outbox.requeued(
      entry('a', 'a', attempts: Outbox.maxAutoAttempts),
    );
    expect(spent.status, OutboxStatus.failed);
    expect(Outbox.requeued(entry('a', 'a', attempts: 1)).isQueued, isTrue);
  });

  test(
    'after a kill an upload goes back in line, a submit stays to settle',
    () {
      final q = Outbox.rehydrate([
        entry('a', 'a', status: OutboxStatus.sending),
        entry('b', 'b', status: OutboxStatus.submitted),
      ]);
      expect(q.map((e) => e.status), [
        OutboxStatus.queued,
        OutboxStatus.submitted,
      ]);
    },
  );

  test('a fresh start forgets the budget, the error and what went out', () {
    final e = Outbox.fresh(
      entry(
        'a',
        'a',
        status: OutboxStatus.failed,
        attempts: 5,
      ).copyWith(error: OutboxFailure.local, sentText: 'a'),
      text: 'b',
    );
    expect(
      (e.status, e.attempts, e.error, e.sentText, e.text),
      (OutboxStatus.queued, 0, null, null, 'b'),
    );
  });

  test('the queue is drawn on the rows; an entry without a row gets one', () {
    final rows = Outbox.project(
      [
        userRow('sent').copyWith(delivery: DeliveryState.sending),
        const ChatMessage(id: 'q1', role: ChatRole.user, text: 'old'),
      ],
      [
        entry('q1', 'edited', status: OutboxStatus.failed),
        entry('q2', 'cold start'),
      ],
    );
    expect(rows.map((m) => (m.text, m.delivery)), [
      ('sent', DeliveryState.sent),
      ('edited', DeliveryState.failed),
      ('cold start', DeliveryState.queued),
    ]);
  });

  group('an unanswered submit is delivered when the gateway holds it', () {
    Set<String> delivered(OutboxEntry e, List<ChatMessage> rows) =>
        Outbox.delivered([e], rows);

    test('by its words, trimmed and whole', () {
      expect(delivered(entry('a', 'hi '), [userRow('hi')]), {'a'});
      expect(delivered(entry('a', 'hi'), [userRow('hi there')]), isEmpty);
    });

    test('one row settles one entry', () {
      expect(
        Outbox.delivered([entry('a', 'ok'), entry('b', 'ok')], [userRow('ok')]),
        {'a'},
      );
    });

    test('not by a row written long before it', () {
      final old = t0.subtract(const Duration(days: 1));
      expect(delivered(entry('a', 'ok'), [userRow('ok', at: old)]), isEmpty);
    });

    test('files put their references before the words', () {
      final e = entry('a', 'look').copyWith(
        attachments: const [
          LocalAttachment(
            id: 'f',
            path: '/f.pdf',
            name: 'f.pdf',
            mimeType: 'application/pdf',
            sizeBytes: 1,
          ),
        ],
      );
      expect(delivered(e, [userRow('@file:f.pdf\n\nlook')]), {'a'});
    });

    test('files alone by the prompt that went out, else the user decides', () {
      final e = entry('a', '').copyWith(sentText: '@file:x');
      expect(delivered(e, [userRow('@file:x')]), {'a'});
      expect(delivered(entry('a', ''), [userRow('@file:x')]), isEmpty);
    });
  });
}
