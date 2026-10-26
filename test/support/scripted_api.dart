import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/chat/data/chat_store.dart';
import 'package:hermes/features/chat/domain/chat_state.dart';
import 'package:hermes/features/chat/domain/chat_target.dart';
import 'package:hermes/features/chat/presentation/chat_controller.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/hermes/api/hermes_api.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/attach_result.dart';
import 'package:hermes/hermes/models/compress_result.dart';
import 'package:hermes/hermes/models/context_breakdown.dart';
import 'package:hermes/hermes/models/gateway_action.dart';
import 'package:hermes/hermes/models/session_message.dart';
import 'package:hermes/hermes/models/session_resume.dart';
import 'package:hermes/hermes/models/session_summary.dart';

import 'fake_gateway.dart';
import 'memory_stores.dart';
import 'throwing.dart';

/// A gateway the test scripts call by call: what each answers, what it
/// throws, what is held back until the test lets it go, and what was asked.
///
/// Anything thrown is an [Object], so a test can throw a [HermesFailure] or
/// something that is not one (a bug, a `FileSystemException`).
class ScriptedApi extends FakeApi {
  /// A gateway whose chat is `stored-1`, bound to runtime id [runtimeId].
  ScriptedApi({super.runtimeId});

  /// Answers `session.resume`; the default is a bound chat whose transcript
  /// is read with `session.history`.
  SessionResume Function(String storedId)? resume;

  /// The rows `session.history` answers with.
  List<SessionMessage> rows = const [];

  /// Held open until completed, when set; answers [rows] after.
  Completer<void>? historyGate;

  /// Thrown by the next `session.history`, then cleared.
  Object? nextHistoryFailure;

  /// Held open until completed, when set (once, then cleared).
  Completer<void>? resumeGate;

  /// Thrown by the next `session.resume`, then cleared.
  Object? nextResumeFailure;

  /// Thrown by the next `prompt.submit`s, one each, then none. A null entry
  /// lets that submit through.
  final List<Object?> submitScript = [];

  /// Held open until completed, when set (once, then cleared).
  Completer<void>? submitGate;

  /// Thrown by the next attachment upload, then cleared.
  Object? nextUploadError;

  /// Held open until completed, when set (once, then cleared).
  Completer<void>? uploadGate;

  /// The Bot Chat `findByTitle` answers with.
  SessionSummary? botChat = const SessionSummary(id: 'stored-1');

  /// Thrown by the next `findByTitle`, then cleared.
  Object? nextFindFailure;

  /// Thrown by the next `session.create`, then cleared.
  Object? nextCreateFailure;

  /// Thrown by the next `session.title`, then cleared.
  Object? nextTitleFailure;

  /// Thrown by the archive calls that restore (`archived: false`).
  Object? restoreFailure;

  /// Thrown by the call that archives the session with this id.
  final Map<String, Object> archiveFailures = {};

  /// `session.resume` calls, and the stored ids asked for.
  final List<String> resumedIds = [];

  /// How many times the transcript was read.
  int historyCalls = 0;

  /// How many `prompt.submit` frames went out, accepted or not.
  int submits = 0;

  /// Stored sessions by id, with their parent links; any other has none.
  final Map<String, SessionSummary> chain = {};

  /// Saved transcripts of stored sessions.
  final Map<String, List<SessionMessage>> stored = {};

  /// What `GET /api/sessions` lists of the app's conversations.
  List<SessionSummary> appListed = const [];

  /// What `session.compress` answers.
  CompressResult compressed = const CompressResult(message: 'compacted');

  /// What a restart or an update start answers.
  GatewayAction action = const GatewayAction(ok: true);

  /// How a followed action ends.
  ActionStatus actionDone = const ActionStatus(exitCode: 0, lines: ['ok']);

  /// What the update check answers.
  UpdateCheck update = const UpdateCheck(behind: 0, message: 'up to date');

  /// `session.undo` calls; each drops the last two rows of [rows].
  int undos = 0;

  /// `session.archive` calls: the id, and whether it archived or restored.
  final List<({String id, bool archived})> archives = [];

  /// `session.create` answers handed out so far.
  int creates = 0;

  /// Texts sent to text to speech.
  final List<String> spoken = [];

  @override
  Future<SpeechAudio> speak({required String text, String? profile}) async {
    spoken.add(text);
    return (bytes: Uint8List.fromList([1]), mimeType: 'audio/mpeg');
  }

  /// What `session.context_breakdown` answers; null throws as an older
  /// gateway would.
  ContextBreakdown? breakdown;

  @override
  Future<ContextBreakdown> contextBreakdown(String runtimeId) async =>
      breakdown ??
      (throw const ServerFailure(
        'method not found',
        rpcCode: HermesProtocol.errMethodNotFound,
      ));

  @override
  Future<SessionResume> resumeSession({
    required String storedId,
    required String profile,
    bool deferHistory = true,
  }) async {
    resumedIds.add(storedId);
    final gate = resumeGate;
    resumeGate = null;
    await gate?.future;
    final failure = nextResumeFailure;
    nextResumeFailure = null;
    if (failure != null) throwInjected(failure);
    return resume?.call(storedId) ??
        SessionResume(
          sessionId: runtimeId,
          storedSessionId: storedId,
          messagesOmitted: true,
        );
  }

  @override
  Future<SessionResume> createSession({
    required String profile,
    String? title,
    bool hidden = false,
    bool followProfileConfig = false,
    String? parentSessionId,
  }) async {
    creates++;
    final failure = nextCreateFailure;
    nextCreateFailure = null;
    if (failure != null) throwInjected(failure);
    return const SessionResume(
      sessionId: 'rt-new',
      storedSessionId: 'stored-new',
    );
  }

  @override
  Future<void> setTitle(String runtimeId, String title) async {
    final failure = nextTitleFailure;
    nextTitleFailure = null;
    if (failure != null) throwInjected(failure);
  }

  @override
  Future<void> archiveSession({
    required String sessionId,
    required String profile,
    bool archived = true,
  }) async {
    archives.add((id: sessionId, archived: archived));
    if (!archived && restoreFailure != null) throwInjected(restoreFailure!);
    if (archived && archiveFailures.containsKey(sessionId)) {
      throwInjected(archiveFailures[sessionId]!);
    }
  }

  @override
  Future<List<SessionMessage>> history(String runtimeId) async {
    historyCalls++;
    final gate = historyGate;
    if (gate != null) {
      historyGate = null;
      final held = rows;
      await gate.future;
      return held;
    }
    final failure = nextHistoryFailure;
    nextHistoryFailure = null;
    if (failure != null) throwInjected(failure);
    return rows;
  }

  @override
  Future<SessionSummary> storedSession({
    required String storedId,
    required String profile,
  }) async => chain[storedId] ?? SessionSummary(id: storedId);

  @override
  Future<List<SessionSummary>> appSessions({
    required String profile,
    int offset = 0,
  }) async => appListed.skip(offset).toList();

  @override
  Future<List<SessionMessage>> storedMessages({
    required String storedId,
    required String profile,
    int limit = HermesLimits.storedMessagesPage,
  }) async => stored[storedId] ?? const [];

  @override
  Future<CompressResult> compress(String runtimeId) async => compressed;

  @override
  Future<GatewayAction> restartGateway() async => action;

  @override
  Future<GatewayAction> startUpdate() async => action;

  @override
  Future<UpdateCheck> checkUpdate({bool force = true}) async => update;

  @override
  Future<ActionStatus> awaitAction(
    String name, {
    required Duration timeout,
    void Function(ActionStatus status)? onProgress,
    Future<void> Function(Duration) wait = Future.delayed,
    bool Function()? cancelled,
  }) async {
    onProgress?.call(const ActionStatus(running: true, lines: ['working']));
    return actionDone;
  }

  @override
  Future<int> undoLastTurn(String runtimeId) async {
    undos++;
    if (rows.length < 2) return 0;
    rows = rows.sublist(0, rows.length - 2);
    return 2;
  }

  @override
  Future<SessionSummary?> findByTitle(String profile, String title) async {
    final failure = nextFindFailure;
    nextFindFailure = null;
    if (failure != null) throwInjected(failure);
    return botChat;
  }

  @override
  Future<String> submitPrompt({
    required String runtimeId,
    required String profile,
    required String text,
    bool interrupted = false,
  }) async {
    submits++;
    await submitGate?.future;
    submitGate = null;
    if (submitScript.isNotEmpty) {
      final failure = submitScript.removeAt(0);
      if (failure != null) throwInjected(failure);
    }
    return super.submitPrompt(
      runtimeId: runtimeId,
      profile: profile,
      text: text,
      interrupted: interrupted,
    );
  }

  @override
  Future<ImageAttachResult> attachImageBytes({
    required String runtimeId,
    required List<int> bytes,
    required String filename,
  }) async {
    final gate = uploadGate;
    uploadGate = null;
    await gate?.future;
    final failure = nextUploadError;
    nextUploadError = null;
    if (failure != null) throwInjected(failure);
    return super.attachImageBytes(
      runtimeId: runtimeId,
      bytes: bytes,
      filename: filename,
    );
  }
}

/// One chat over a [ScriptedApi] and the store it saves to.
typedef ChatRig = ({
  ProviderContainer container,
  FakeClient client,
  ScriptedApi api,
  ChatStore store,
  ChatTarget target,
});

/// A chat of [target] on a scripted gateway, held open as a mounted screen
/// would. [kv] is what an earlier run left on disk.
ChatRig bootChat({
  ChatTarget target = const BotTarget('atlas'),
  ScriptedApi? api,
  FakeClient? client,
  MemoryKeyValueStore? kv,
  bool online = true,
  List<Override> overrides = const [],
}) {
  final fakeClient = client ?? (FakeClient()..connected = online);
  final gateway = api ?? ScriptedApi();
  final store = ChatStore(kv ?? MemoryKeyValueStore(), '');
  final container = ProviderContainer(
    overrides: [
      ...memoryStoreOverrides(),
      hermesClientProvider.overrideWithValue(fakeClient),
      hermesApiProvider.overrideWithValue(gateway),
      chatStoreProvider.overrideWithValue(store),
      ...overrides,
    ],
  );
  container.listen(
    chatControllerProvider(target),
    (_, _) {},
    fireImmediately: true,
  );
  addTearDown(() async {
    container.dispose();
    await fakeClient.close();
  });
  return (
    container: container,
    client: fakeClient,
    api: gateway,
    store: store,
    target: target,
  );
}

/// The notifier of the chat in [rig].
ChatController chatOf(ChatRig rig) =>
    rig.container.read(chatControllerProvider(rig.target).notifier);

/// The state of the chat in [rig].
ChatState stateOf(ChatRig rig) =>
    rig.container.read(chatControllerProvider(rig.target));
