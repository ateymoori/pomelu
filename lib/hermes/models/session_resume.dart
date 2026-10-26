import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';
import 'json_parse.dart';
import 'session_message.dart';
import 'todo_plan.dart';

part 'session_resume.freezed.dart';
part 'session_resume.g.dart';

/// Result of `session.create` / `session.resume` / `session.activate`.
///
/// `sessionId` is the ephemeral runtime handle (use for RPCs);
/// `storedId` is the durable key (use for lists and future resumes).
@freezed
abstract class SessionResume with _$SessionResume {
  const SessionResume._();

  const factory SessionResume({
    @JsonKey(name: 'session_id') @LooseString() @Default('') String sessionId,
    @JsonKey(name: 'stored_session_id')
    @LooseStringOrNull()
    String? storedSessionId,
    @JsonKey(name: 'session_key') @LooseStringOrNull() String? sessionKey,
    @LooseStringOrNull() String? resumed,
    @JsonKey(name: 'message_count') @LooseInt() @Default(0) int messageCount,
    @JsonKey(fromJson: _messagesFromJson)
    @Default(<SessionMessage>[])
    List<SessionMessage> messages,
    @JsonKey(name: 'messages_omitted')
    @LooseBool()
    @Default(false)
    bool messagesOmitted,
    @LooseBool() @Default(false) bool hydrating,
    @LooseBool() @Default(false) bool running,
    @LooseString() @Default('') String status,
    RuntimeInfo? info,
    Inflight? inflight,
    QueuedPrompt? queued,

    /// Questions still waiting on this session, as sent to the router: a live
    /// session reattached by a resume lists them here.
    @JsonKey(name: 'open_requests')
    @LooseMapList()
    @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> openRequests,

    /// The agent's plan as last written; null when it keeps none.
    @JsonKey(name: 'todo_state') TodoPlan? todoState,
  }) = _SessionResume;

  factory SessionResume.fromJson(Map<String, dynamic> json) =>
      _$SessionResumeFromJson(json);

  String get storedId => storedSessionId ?? sessionKey ?? resumed ?? sessionId;
}

/// What the live session runs on: model, provider, effort and more.
@freezed
abstract class RuntimeInfo with _$RuntimeInfo {
  const factory RuntimeInfo({
    @LooseString() @Default('') String model,
    @LooseString() @Default('') String provider,
    @JsonKey(name: 'reasoning_effort')
    @LooseString()
    @Default('')
    String reasoningEffort,
    @LooseBool() @Default(false) bool running,
    @LooseString() @Default('') String version,

    @LooseMap() Map<String, dynamic>? usage,
  }) = _RuntimeInfo;

  factory RuntimeInfo.fromJson(Map<String, dynamic> json) =>
      _$RuntimeInfoFromJson(json);
}

/// Partial turn state returned on resume while a turn is (or was) running.
@freezed
abstract class Inflight with _$Inflight {
  const factory Inflight({
    @LooseString() @Default('') String assistant,
    @LooseString() @Default('') String user,
    @LooseBool() @Default(false) bool streaming,
    @LooseStringOrNull() String? error,
    @LooseString() @Default('') String status,
  }) = _Inflight;

  factory Inflight.fromJson(Map<String, dynamic> json) =>
      _$InflightFromJson(json);
}

/// A prompt waiting behind the running turn.
@freezed
abstract class QueuedPrompt with _$QueuedPrompt {
  const factory QueuedPrompt({@LooseString() @Default('') String user}) =
      _QueuedPrompt;

  factory QueuedPrompt.fromJson(Map<String, dynamic> json) =>
      _$QueuedPromptFromJson(json);
}

/// The rows of `messages`; a malformed row is left out, the rest still load.
List<SessionMessage> _messagesFromJson(Object? json) =>
    parseRows(json, SessionMessage.fromJson, what: 'message');
