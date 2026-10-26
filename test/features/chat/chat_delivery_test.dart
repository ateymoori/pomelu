import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/chat/data/chat_store.dart';
import 'package:hermes/features/chat/domain/chat_message.dart';
import 'package:hermes/features/chat/domain/outbox.dart';
import 'package:hermes/features/chat/presentation/outbox_drainer.dart';
import 'package:hermes/hermes/events/gateway_event.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/local_attachment.dart';
import 'package:hermes/hermes/models/session_message.dart';

import '../../support/memory_stores.dart';
import '../../support/scripted_api.dart';
import 'chat_harness.dart';

List<OutboxStatus> statuses(ChatRig rig) => [
  for (final e in stateOf(rig).outbox) e.status,
];

void main() {
  test('a turn sent online reaches the gateway and leaves the queue', () async {
    final rig = bootChat();
    await pumpEventQueue();
    expect(await chatOf(rig).send('hello'), isTrue);
    await pumpEventQueue();
    expect(rig.api.prompts, ['hello']);
    expect(stateOf(rig).outbox, isEmpty);
    expect(rig.store.outbox(rig.target.key), isEmpty);
    expect(stateOf(rig).messages.single.delivery, DeliveryState.sent);
  });

  test('offline turns are kept, then sent oldest first on reconnect', () async {
    final rig = bootChat();
    await pumpEventQueue();
    rig.client.goOffline();
    await pumpEventQueue();
    await chatOf(rig).send('one');
    await chatOf(rig).send('two');
    await pumpEventQueue();
    expect(rig.api.prompts, isEmpty);
    expect(statuses(rig), [OutboxStatus.queued, OutboxStatus.queued]);
    expect(rig.store.outbox(rig.target.key), hasLength(2), reason: 'on disk');
    rig.client.goOnline();
    await pumpEventQueue();
    expect(rig.api.prompts, ['one'], reason: 'two waits for the reply to one');
    rig.client.emit(ev(EventNames.messageComplete, {'text': 'done'}));
    await pumpEventQueue();
    expect(rig.api.prompts, ['one', 'two']);
  });

  test('a turn typed while a reply streams waits for its end', () async {
    final rig = bootChat();
    await pumpEventQueue();
    rig.client.emit(ev(EventNames.messageStart));
    await pumpEventQueue();
    await chatOf(rig).send('next');
    expect(rig.api.prompts, isEmpty);
    rig.client.emit(ev(EventNames.messageComplete, {'status': 'complete'}));
    await pumpEventQueue();
    expect(rig.api.prompts, ['next']);
  });

  group('a submit that went out unanswered is never sent again', () {
    test('the gateway holds it: it leaves the queue on reconnect', () async {
      final rig = bootChat();
      await pumpEventQueue();
      rig.api.submitGate = Completer<void>();
      rig.api.submitScript.add(lost);
      unawaited(chatOf(rig).send('are you there'));
      await pumpEventQueue();
      rig.client.goOffline();
      rig.api.rows = const [
        SessionMessage(role: 'user', text: 'are you there'),
      ];
      rig.api.submitGate!.complete();
      await pumpEventQueue();
      expect(statuses(rig), [OutboxStatus.submitted]);
      rig.client.goOnline();
      await pumpEventQueue();
      expect(rig.api.submits, 1);
      expect(stateOf(rig).outbox, isEmpty);
      expect(stateOf(rig).messages.map((m) => m.text), ['are you there']);
    });

    test('the gateway does not hold it: the user decides', () async {
      final rig = bootChat();
      await pumpEventQueue();
      rig.api.submitScript.add(lost);
      await chatOf(rig).send('lost');
      await pumpEventQueue();
      final e = stateOf(rig).outbox.single;
      expect(e.status, OutboxStatus.failed);
      expect(e.error, OutboxFailure.unconfirmed);
      expect(rig.api.submits, 1);
      await chatOf(rig).retry(e.id);
      await pumpEventQueue();
      expect(rig.api.prompts, ['lost']);
    });

    test('it holds the turns behind it until settled', () async {
      final rig = bootChat();
      await pumpEventQueue();
      rig.api.submitScript.add(lost);
      rig.api.historyGate = Completer<void>();
      await chatOf(rig).send('first');
      await chatOf(rig).send('second');
      await pumpEventQueue();
      expect(rig.api.prompts, isEmpty);
      expect(statuses(rig), [OutboxStatus.submitted, OutboxStatus.queued]);
    });
  });

  test('a refusal fails the turn and holds the queue for the user', () async {
    final rig = bootChat();
    await pumpEventQueue();
    rig.api.submitScript.add(const ServerFailure('rejected'));
    await chatOf(rig).send('bad');
    await chatOf(rig).send('behind');
    await pumpEventQueue();
    expect(statuses(rig), [OutboxStatus.failed, OutboxStatus.queued]);
    expect(rig.api.prompts, isEmpty);
    // Discarding the failed turn frees the one behind it.
    await chatOf(rig).discard(stateOf(rig).outbox.first.id);
    await chatOf(rig).retry(stateOf(rig).outbox.single.id);
    await pumpEventQueue();
    expect(rig.api.prompts, ['behind']);
  });

  test('edit and resend replaces the words of the same slot', () async {
    final rig = bootChat();
    await pumpEventQueue();
    rig.api.submitScript.add(const ServerFailure('rejected'));
    await chatOf(rig).send('typo');
    await pumpEventQueue();
    final id = stateOf(rig).outbox.single.id;
    expect(chatOf(rig).draftOf(id), 'typo');
    expect(await chatOf(rig).editAndResend(id, 'fixed'), isTrue);
    await pumpEventQueue();
    expect(rig.api.prompts, ['fixed']);
  });

  test('a turn going out or out unconfirmed cannot be amended', () async {
    final rig = bootChat();
    await pumpEventQueue();
    rig.api.submitGate = Completer<void>();
    unawaited(chatOf(rig).send('in flight'));
    await pumpEventQueue();
    final id = stateOf(rig).outbox.single.id;
    expect(chatOf(rig).canAmend(id), isFalse);
    expect(await chatOf(rig).retry(id), isFalse);
    expect(await chatOf(rig).discard(id), isFalse);
    expect(await chatOf(rig).editAndResend(id, 'x'), isFalse);
    rig.api.submitGate!.complete();
  });

  test('a network miss queues the turn for the next connection', () async {
    final rig = bootChat();
    await pumpEventQueue();
    rig.api.submitScript.add(const NetworkFailure('timeout'));
    await chatOf(rig).send('later');
    await pumpEventQueue();
    expect(statuses(rig), [OutboxStatus.queued]);
    rig.client
      ..goOffline()
      ..goOnline();
    await pumpEventQueue();
    expect(rig.api.prompts, ['later']);
  });

  test('a file that is gone fails the turn instead of retrying it', () async {
    final rig = bootChat();
    await pumpEventQueue();
    await chatOf(rig).send(
      'see',
      attachments: const [
        LocalAttachment(
          id: 'a',
          path: '/nowhere/pic.png',
          name: 'pic.png',
          mimeType: 'image/png',
          sizeBytes: 3,
          kind: AttachmentKind.image,
        ),
      ],
    );
    await pumpEventQueue();
    expect(statuses(rig), [OutboxStatus.failed]);
    expect(rig.api.prompts, isEmpty);
  });

  test('stop while the files upload: the prompt never goes out', () async {
    final rig = bootChat();
    await pumpEventQueue();
    final gate = rig.api.uploadGate = Completer<void>();
    final sent = chatOf(rig).send('look', attachments: [await tempImage()]);
    await pumpEventQueue();
    expect(stateOf(rig).running, isTrue);
    expect(stateOf(rig).upload?.total, 1);
    await chatOf(rig).stop();
    gate.complete();
    // The send reads the file for real: wait for it, not for a queue pump.
    await sent;
    await pumpEventQueue();
    expect(rig.api.prompts, isEmpty);
    expect(rig.api.interrupts, isEmpty, reason: 'nothing reached the agent');
    expect(stateOf(rig).running, isFalse);
    expect(statuses(rig), [OutboxStatus.failed]);
  });

  test('stop interrupts the running turn of the bound session', () async {
    final rig = bootChat();
    await pumpEventQueue();
    rig.client.emit(ev(EventNames.messageStart));
    await pumpEventQueue();
    await chatOf(rig).stop();
    expect(rig.api.interrupts, ['rt-1']);
    expect(stateOf(rig).stopRequested, isTrue);
    rig.client.emit(ev(EventNames.messageComplete, {'status': 'interrupted'}));
    await pumpEventQueue();
    expect(stateOf(rig).running, isFalse);
  });

  test('a full queue refuses a new turn', () async {
    final kv = MemoryKeyValueStore();
    await ChatStore(kv, '').saveOutbox('bot:atlas', [
      for (var i = 0; i < Outbox.maxEntries; i++)
        entry('e$i', 'turn $i', status: OutboxStatus.failed),
    ]);
    final rig = bootChat(kv: kv);
    await pumpEventQueue();
    expect(chatOf(rig).isQueueFull(), isTrue);
    expect(await chatOf(rig).send('one too many'), isFalse);
  });

  group('after the app was killed', () {
    Future<ChatRig> restart(
      OutboxEntry left, {
      List<SessionMessage> rows = const [],
    }) async {
      final kv = MemoryKeyValueStore();
      await ChatStore(kv, '').saveOutbox('bot:atlas', [left]);
      final rig = bootChat(kv: kv, api: ScriptedApi()..rows = rows);
      await pumpEventQueue();
      return rig;
    }

    test('a submit the gateway holds is settled, not sent again', () async {
      final rig = await restart(
        entry('u', 'hi', status: OutboxStatus.submitted),
        rows: [SessionMessage(role: 'user', text: 'hi', timestamp: t0)],
      );
      expect(rig.api.submits, 0);
      expect(stateOf(rig).outbox, isEmpty);
    });

    test('an upload that was cut goes out again', () async {
      final rig = await restart(entry('u', 'hi', status: OutboxStatus.sending));
      expect(rig.api.prompts, ['hi']);
    });
  });

  test(
    'an answer after the chat closed still settles the stored queue',
    () async {
      final rig = bootChat();
      await pumpEventQueue();
      final gate = rig.api.submitGate = Completer<void>();
      unawaited(chatOf(rig).send('bye'));
      await pumpEventQueue();
      rig.container.dispose();
      gate.complete();
      await pumpEventQueue();
      expect(rig.store.outbox(rig.target.key), isEmpty);
    },
  );

  test(
    'the drainer sends what a cold start left, without opening the chat',
    () async {
      final kv = MemoryKeyValueStore();
      await ChatStore(kv, '').saveOutbox('bot:atlas', [entry('u', 'hi')]);
      final rig = bootChat(kv: kv);
      rig.container.listen(outboxDrainerProvider, (_, _) {});
      await pumpEventQueue();
      expect(rig.api.prompts, ['hi']);
      expect(rig.store.pendingTargets(), isEmpty);
    },
  );
}
