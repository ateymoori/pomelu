import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/chat/domain/chat_message.dart';
import 'package:hermes/features/chat/domain/slash_command.dart';
import 'package:hermes/features/chat/presentation/chat_controller.dart';
import 'package:hermes/hermes/events/gateway_event.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/gateway_action.dart';
import 'package:hermes/hermes/models/session_message.dart';
import 'package:hermes/hermes/models/session_summary.dart';

import '../../support/scripted_api.dart';
import 'chat_harness.dart';

const _rows = [
  SessionMessage(role: 'user', text: 'my cat is Miso', rowId: 1),
  SessionMessage(role: 'assistant', text: 'ok', rowId: 2),
];

Future<ChatRig> open([ScriptedApi? api]) async {
  final rig = bootChat(api: (api ?? ScriptedApi())..rows = _rows);
  await pumpEventQueue();
  return rig;
}

void main() {
  group('a new conversation', () {
    test(
      'is a fresh session that follows the old one, the old rows above',
      () async {
        final rig = await open();
        rig.api.rows = const [];
        await chatOf(rig).runSlash(SlashCommand.newConversation);
        await pumpEventQueue();
        final s = stateOf(rig);
        expect(s.storedId, 'stored-new');
        expect(rig.api.archives, [(id: 'rt-1', archived: true)]);
        expect(s.messages, isEmpty);
        expect(s.earlier.map((m) => m.text), ['my cat is Miso', 'ok', '']);
        expect(s.earlier.last.boundary, isTrue);
      },
    );

    test('a failed create leaves the old chat as it was', () async {
      final rig = await open(
        ScriptedApi()..nextCreateFailure = const NetworkFailure('down'),
      );
      await chatOf(rig).startOver();
      expect(stateOf(rig).storedId, 'stored-1');
      expect(stateOf(rig).messages, hasLength(2));
      expect(stateOf(rig).error, isA<NetworkFailure>());
      expect(rig.api.archives, isEmpty);
    });

    test(
      'a later failure archives the new one and puts the old one back',
      () async {
        final rig = await open(
          ScriptedApi()..nextTitleFailure = const ServerFailure('nope'),
        );
        await chatOf(rig).startOver();
        expect(rig.api.archives, [
          (id: 'rt-1', archived: true),
          (id: 'rt-new', archived: true),
          (id: 'rt-1', archived: false),
        ]);
        expect(stateOf(rig).storedId, 'stored-1');
      },
    );
  });

  test(
    'earlier conversations load one at a time, skipping compactions',
    () async {
      final api = ScriptedApi();
      api.chain.addAll({
        'stored-1': const SessionSummary(id: 'stored-1', parentSessionId: 'c'),
        'c': const SessionSummary(
          id: 'c',
          parentSessionId: 'old',
          endReason: HermesProtocol.compressionEndReason,
        ),
      });
      api.stored['old'] = const [
        SessionMessage(role: 'user', text: 'long ago'),
      ];
      final rig = await open(api);
      await chatOf(rig).loadEarlier();
      expect(stateOf(rig).earlier.map((m) => m.text), ['long ago', '']);
      expect(stateOf(rig).earlierCursor, 'old');
      await chatOf(rig).loadEarlier();
      expect(stateOf(rig).earlierDone, isTrue);
    },
  );

  test('a Bot Chat the gateway moved aside loads above the first', () async {
    DateTime at(int day) => DateTime.utc(2026, 10, day);
    final api = ScriptedApi();
    api.chain['stored-1'] = SessionSummary(id: 'stored-1', startedAt: at(21));
    api.appListed = [
      SessionSummary(
        id: 'later',
        title: 'Bot Chat (mobile x)',
        startedAt: at(22),
      ),
      SessionSummary(id: 'other', title: 'Weather', startedAt: at(12)),
      SessionSummary(
        id: 'aside',
        title: 'Bot Chat (mobile y)',
        startedAt: at(10),
      ),
      SessionSummary(
        id: 'older',
        title: 'Bot Chat (mobile z)',
        startedAt: at(2),
      ),
    ];
    api.stored['aside'] = const [
      SessionMessage(role: 'user', text: 'before the move'),
    ];
    final rig = await open(api);
    await chatOf(rig).loadEarlier();
    expect(stateOf(rig).earlier.map((m) => m.text), ['before the move', '']);
    expect(stateOf(rig).earlierCursor, 'aside');
  });

  test(
    'a message another client wrote appears, the same words are not redrawn',
    () async {
      final rig = await open();
      rig.client.emit(ev(EventNames.sessionsChanged));
      await Future<void>.delayed(const Duration(seconds: 1));
      final calls = rig.api.historyCalls;
      expect(stateOf(rig).messages, hasLength(2));
      rig.api.rows = [
        ..._rows,
        const SessionMessage(role: 'user', text: 'from Telegram'),
      ];
      rig.api.botChat = const SessionSummary(id: 'stored-1', messageCount: 3);
      rig.client.emit(ev(EventNames.sessionsChanged));
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(rig.api.historyCalls, calls + 1);
      expect(stateOf(rig).messages.last.text, 'from Telegram');
    },
  );

  test('a new conversation started on another device is followed', () async {
    final rig = await open();
    rig.api.botChat = const SessionSummary(id: 'elsewhere');
    rig.api.chain['elsewhere'] = const SessionSummary(
      id: 'elsewhere',
      parentSessionId: 'stored-1',
    );
    rig.client.emit(ev(EventNames.sessionsChanged));
    await Future<void>.delayed(const Duration(seconds: 1));
    expect(stateOf(rig).storedId, 'elsewhere');
  });

  group('commands leave a row with their output', () {
    ChatMessage note(ChatRig rig) =>
        stateOf(rig).messages.lastWhere((m) => m.isCommand);

    test('/compact compresses and reads the transcript again', () async {
      final rig = await open();
      final reads = rig.api.historyCalls;
      await chatOf(rig).runSlash(SlashCommand.compact);
      expect(note(rig).command, '/compact');
      expect(note(rig).text, 'compacted');
      expect(rig.api.historyCalls, greaterThan(reads));
    });

    test(
      '/restart follows the action to its end; a refusal says why',
      () async {
        final rig = await open();
        await chatOf(rig).runSlash(SlashCommand.restart);
        expect(note(rig).text, 'ok');
        expect(note(rig).delivery, DeliveryState.sent);
        rig.api.action = const GatewayAction(message: 'not allowed');
        await chatOf(rig).runSlash(SlashCommand.restart);
        expect(
          (note(rig).text, note(rig).delivery),
          ('not allowed', DeliveryState.failed),
        );
      },
    );

    test('/update on a current install only tells so', () async {
      final rig = await open();
      await chatOf(rig).runSlash(SlashCommand.update);
      expect(note(rig).text, 'up to date');
    });

    test('a command row survives a reload and can be removed', () async {
      final rig = await open();
      await chatOf(rig).runSlash(SlashCommand.restart);
      rig.client.emit(ev(SyntheticEvents.replayTruncated));
      await pumpEventQueue();
      final id = note(rig).id;
      chatOf(rig).deleteNote(id);
      expect(stateOf(rig).messages.where((m) => m.isCommand), isEmpty);
    });
  });

  test('delete from a turn undoes turns until its row is gone', () async {
    final rig = await open();
    final outcome = await chatOf(rig).deleteFrom('row-2');
    expect(outcome, DeleteOutcome.removed);
    expect(rig.api.undos, 1);
    expect(stateOf(rig).messages, isEmpty);
  });

  test('hide is view-only and can be undone', () async {
    final rig = await open();
    final rowId = await chatOf(rig).hide('row-1');
    expect(rowId, 1);
    expect(stateOf(rig).hidden, {1});
    expect(rig.store.hidden(rig.target.key), {1});
    chatOf(rig).show(1);
    expect(stateOf(rig).hidden, isEmpty);
  });
}
