import 'dart:async';

import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/chat/domain/chat_target.dart';
import 'package:hermes/features/chat/domain/slash_command.dart';
import 'package:hermes/features/chat/presentation/chat_controller.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/hermes/events/gateway_event.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/session_message.dart';
import 'package:hermes/hermes/models/session_resume.dart';
import 'package:hermes/hermes/models/session_summary.dart';

import '../../support/memory_stores.dart';
import '../../support/scripted_api.dart';
import 'chat_harness.dart';

List<String> words(ChatRig rig) => [
  for (final m in stateOf(rig).messages) m.text,
];

void main() {
  test(
    'without a gateway the chat builds in an error and does nothing',
    () async {
      final container = ProviderContainer(
        overrides: [
          ...memoryStoreOverrides(),
          hermesClientProvider.overrideWithValue(null),
          hermesApiProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);
      const target = BotTarget('atlas');
      container.listen(chatControllerProvider(target), (_, _) {});
      final c = container.read(chatControllerProvider(target).notifier);
      await pumpEventQueue();
      expect(
        container.read(chatControllerProvider(target)).error,
        isA<NetworkFailure>(),
      );
      expect(await c.send('hello'), isFalse);
      await c.stop();
      await c.runSlash(SlashCommand.restart);
      await c.loadEarlier();
      expect(await c.deleteFrom('x'), DeleteOutcome.failed);
      expect(c.answerApproval('1', 'once'), isFalse);
      await expectLater(c.modelOptions(), throwsA(isA<NetworkFailure>()));
    },
  );

  test(
    'an idle chat lets go of its session while the app is away, and resumes',
    () async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      addTearDown(
        () => binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed),
      );
      final api = ScriptedApi();
      final rig = bootChat(api: api);
      await pumpEventQueue();
      expect(api.resumedIds, ['stored-1']);

      binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await pumpEventQueue();
      expect(api.closedIds, ['rt-1']);
      expect(rig.client.watched, isEmpty);

      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await pumpEventQueue();
      expect(api.resumedIds, ['stored-1', 'stored-1']);
      expect(rig.client.watched, ['rt-1']);
    },
  );

  test(
    'a turn running while the app is away keeps its session until it ends',
    () async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      addTearDown(
        () => binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed),
      );
      final api = ScriptedApi();
      final rig = bootChat(api: api);
      await pumpEventQueue();
      rig.client.emit(ev(EventNames.messageStart));
      await pumpEventQueue();

      binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await pumpEventQueue();
      expect(api.closedIds, isEmpty);

      rig.client.emit(ev(EventNames.messageComplete, {'text': 'done'}));
      await pumpEventQueue();
      expect(api.closedIds, ['rt-1']);
    },
  );

  test('opens the Bot Chat it finds and reads its transcript', () async {
    final api = ScriptedApi()
      ..rows = const [SessionMessage(role: 'user', text: 'hi')];
    final rig = bootChat(api: api);
    await pumpEventQueue();
    expect(api.resumedIds, ['stored-1']);
    expect(rig.client.watched, ['rt-1']);
    expect(words(rig), ['hi']);
    expect(stateOf(rig).isReady, isTrue);
  });

  test(
    'a hydrating chat shows its transcript at once, short of its count',
    () async {
      final api = ScriptedApi()
        ..rows = const [SessionMessage(role: 'user', text: 'hi')]
        ..resume = (id) => SessionResume(
          sessionId: 'rt-1',
          storedSessionId: id,
          hydrating: true,
          messageCount: 40,
        );
      final rig = bootChat(api: api);
      await pumpEventQueue();
      expect(words(rig), ['hi']);
      expect(stateOf(rig).loading, isFalse);
      expect(api.historyCalls, 1);
    },
  );

  test('a bot without a chat gets one, titled', () async {
    final api = ScriptedApi()..botChat = null;
    final rig = bootChat(api: api);
    await pumpEventQueue();
    expect(api.creates, 1);
    expect(stateOf(rig).runtimeId, 'rt-new');
  });

  test('a chat another phone titled first is the one opened', () async {
    final api = _TitleRaceApi()
      ..nextTitleFailure = const TitleInUseFailure('already in use');
    bootChat(api: api);
    await pumpEventQueue();
    expect(api.creates, 1);
    expect(api.resumedIds, ['stored-winner']);
  });

  test('waits for the socket, then opens once', () async {
    final rig = bootChat(online: false);
    await pumpEventQueue();
    expect(stateOf(rig).loading, isTrue);
    rig.client.goOnline();
    await pumpEventQueue();
    expect(rig.api.resumedIds, hasLength(1));
    expect(stateOf(rig).isReady, isTrue);
  });

  test(
    'a failed open shows the error; Retry opens it on the same chat',
    () async {
      final api = ScriptedApi()..nextFindFailure = const NetworkFailure('down');
      final rig = bootChat(api: api);
      await pumpEventQueue();
      expect(stateOf(rig).error, isA<NetworkFailure>());
      expect(stateOf(rig).loading, isFalse);
      await chatOf(rig).reopen();
      await pumpEventQueue();
      expect(stateOf(rig).isReady, isTrue);
      expect(stateOf(rig).error, isNull);
    },
  );

  test(
    'a transcript that cannot be read is stale until the next read',
    () async {
      final api = ScriptedApi()
        ..rows = const [SessionMessage(role: 'user', text: 'hello')]
        ..nextHistoryFailure = const NetworkFailure('timed out');
      final rig = bootChat(api: api);
      await pumpEventQueue();
      expect(stateOf(rig).historyStale, isTrue);
      expect(stateOf(rig).runtimeId, isNotEmpty);
      rig.client
        ..goOffline()
        ..goOnline();
      await pumpEventQueue();
      expect(words(rig), ['hello']);
      expect(stateOf(rig).historyStale, isFalse);
      expect(stateOf(rig).error, isNull);
    },
  );

  test('an open cut off by a reconnect opens again once it ends', () async {
    final gate = Completer<void>();
    final api = ScriptedApi()
      ..rows = const [SessionMessage(role: 'user', text: 'hello')]
      ..resumeGate = gate
      ..nextResumeFailure = const OutcomeUnknownFailure('socket closed');
    final rig = bootChat(api: api);
    await pumpEventQueue();
    rig.client
      ..goOffline()
      ..goOnline();
    await pumpEventQueue();
    gate.complete();
    await pumpEventQueue();
    expect(api.resumedIds, hasLength(2));
    expect(words(rig), ['hello']);
    expect(stateOf(rig).error, isNull);
  });

  test(
    'a reconnect reads the open chat again: what came meanwhile shows',
    () async {
      final api = ScriptedApi()
        ..rows = const [SessionMessage(role: 'user', text: 'hello', rowId: 1)];
      final rig = bootChat(api: api);
      await pumpEventQueue();
      api.rows = const [
        SessionMessage(role: 'user', text: 'hello', rowId: 1),
        SessionMessage(
          role: 'assistant',
          text: 'while you were away',
          rowId: 2,
        ),
      ];
      rig.client
        ..goOffline()
        ..goOnline();
      await Future<void>.delayed(const Duration(seconds: 1));
      await pumpEventQueue();
      expect(words(rig), ['hello', 'while you were away']);
    },
  );

  test('a stale runtime id is resumed again and the call retried', () async {
    final rig = bootChat();
    await pumpEventQueue();
    rig.api.submitScript.add(
      const ServerFailure('gone', rpcCode: HermesProtocol.errSessionNotFound),
    );
    await chatOf(rig).send('hello');
    await pumpEventQueue();
    expect(rig.api.resumedIds, hasLength(2));
    expect(rig.api.prompts, ['hello']);
  });

  test('live events of the bound session stream into the transcript', () async {
    final rig = bootChat();
    await pumpEventQueue();
    rig.client.emit(ev(EventNames.messageDelta, {'text': 'hello'}));
    rig.client.emit(
      const GatewayEvent(
        type: EventNames.messageDelta,
        sessionId: 'other',
        payload: {'text': 'not ours'},
      ),
    );
    await pumpEventQueue();
    expect(words(rig), ['hello']);
  });

  test('a socket that drops ends the running turn', () async {
    final rig = bootChat();
    await pumpEventQueue();
    rig.client.emit(ev(EventNames.messageStart));
    await pumpEventQueue();
    expect(stateOf(rig).running, isTrue);
    rig.client.goOffline();
    await pumpEventQueue();
    expect(stateOf(rig).running, isFalse);
  });

  test('closing the chat while it loads is quiet and stops watching', () async {
    final gate = Completer<void>();
    final rig = bootChat(api: ScriptedApi()..historyGate = gate);
    await pumpEventQueue();
    rig.container.dispose();
    gate.complete();
    await pumpEventQueue();
    expect(rig.client.watched, isEmpty);
  });
}

/// No Bot Chat on the first look; the other writer's on the next.
class _TitleRaceApi extends ScriptedApi {
  var _finds = 0;

  @override
  Future<SessionSummary?> findByTitle(String profile, String title) async =>
      _finds++ == 0 ? null : const SessionSummary(id: 'stored-winner');
}
