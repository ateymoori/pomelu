import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/chat/domain/chat_target.dart';
import 'package:hermes/hermes/api/hermes_api.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/client/hermes_client.dart';
import 'package:hermes/hermes/events/gateway_event.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/attach_result.dart';
import 'package:hermes/hermes/models/profile.dart';
import 'package:hermes/hermes/models/session_message.dart';
import 'package:hermes/hermes/models/session_resume.dart';
import 'package:hermes/hermes/models/session_summary.dart';
import 'package:hermes/hermes/requests/server_request_router.dart';

/// A [HermesClient] the test drives: [goOnline], [goOffline], [emit].
class FakeClient extends Fake implements HermesClient {
  final StreamController<GatewayEvent> _events =
      StreamController<GatewayEvent>.broadcast();
  final StreamController<HermesConnectionState> _states =
      StreamController<HermesConnectionState>.broadcast();

  bool connected = true;
  final List<String> watched = [];

  @override
  final ServerRequestRouter requests = ServerRequestRouter();

  @override
  Stream<GatewayEvent> get events => _events.stream;

  @override
  Stream<HermesConnectionState> get states => _states.stream;

  @override
  bool get isConnected => connected;

  @override
  HermesConnectionState get state =>
      connected ? const Connected(replayEpoch: 'e') : const Disconnected();

  @override
  void watchSession(String runtimeId) => watched.add(runtimeId);

  @override
  void unwatchSession(String runtimeId) => watched.remove(runtimeId);

  void goOnline() {
    connected = true;
    _states.add(const Connected(replayEpoch: 'e'));
  }

  void goOffline() {
    connected = false;
    _states.add(const Disconnected());
  }

  void emit(GatewayEvent ev) => _events.add(ev);

  Future<void> close() async {
    await _events.close();
    await _states.close();
  }
}

/// Scripted gateway: every prompt answers with whatever [nextPromptFailure] says.
class FakeApi extends Fake implements HermesApi {
  FakeApi({this.runtimeId = 'rt-1'});

  final String runtimeId;

  /// Listed by `session.resume` as still waiting on the session.
  List<Map<String, dynamic>> openRequests = const [];
  final List<String> prompts = [];
  final List<String> interrupts = [];
  final List<String> staged = [];
  int resumes = 0;

  /// Thrown by the next `submitPrompt`, then cleared.
  HermesFailure? nextPromptFailure;

  /// Thrown by the next attachment upload, then cleared.
  HermesFailure? nextStageFailure;

  @override
  Future<SessionResume> resumeSession({
    required String storedId,
    required String profile,
    bool deferHistory = true,
  }) async {
    resumes++;
    return SessionResume(
      sessionId: runtimeId,
      storedSessionId: storedId,
      openRequests: openRequests,
    );
  }

  @override
  Future<SessionResume> createSession({
    required String profile,
    String? title,
    bool hidden = false,
    bool followProfileConfig = false,
    String? parentSessionId,
  }) async => SessionResume(sessionId: runtimeId, storedSessionId: 'stored-1');

  @override
  Future<List<SessionMessage>> history(String runtimeId) async => const [];

  @override
  Future<String> submitPrompt({
    required String runtimeId,
    required String profile,
    required String text,
    bool interrupted = false,
  }) async {
    final failure = nextPromptFailure;
    nextPromptFailure = null;
    if (failure != null) throw failure;
    prompts.add(text);
    return 'ok';
  }

  @override
  Future<void> interrupt(String runtimeId) async => interrupts.add(runtimeId);

  @override
  Future<ImageAttachResult> attachImageBytes({
    required String runtimeId,
    required List<int> bytes,
    required String filename,
  }) async {
    final failure = nextStageFailure;
    nextStageFailure = null;
    if (failure != null) throw failure;
    staged.add(filename);
    return const ImageAttachResult(attached: true);
  }

  @override
  Future<List<HermesProfile>> listProfiles() async => const [];

  /// The bot's Bot Chat is `stored-1`.
  @override
  Future<SessionSummary?> findByTitle(String profile, String title) async =>
      SessionSummary(id: 'stored-1', title: title, profile: profile);
}

/// The chat most fakes serve.
const target = BotTarget('atlas');
