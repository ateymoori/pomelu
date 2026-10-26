/// Typed views of the events of one chat turn: tool calls, the interim and
/// final text, and the runtime a live `session.info` reports.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/json_converters.dart';
import '../models/todo_plan.dart';
import 'gateway_event.dart';

part 'turn_payloads.freezed.dart';
part 'turn_payloads.g.dart';

/// `tool.start`, `tool.progress` and `tool.complete`: one tool call.
@Freezed(toJson: false)
abstract class ToolEvent with _$ToolEvent {
  const factory ToolEvent({
    /// `tool_id`, else `tool_call_id`, else `id`; empty when none came.
    @JsonKey(readValue: _toolId) @LooseString() @Default('') String id,
    @LooseString() @Default('') String name,
    @LooseString() @Default('') String context,

    /// `result_text`, else the raw `result` as text; null when neither came.
    @JsonKey(name: 'result_text', readValue: _resultText)
    @LooseStringOrNull()
    String? resultText,
    @JsonKey(name: 'inline_diff') @LooseString() @Default('') String inlineDiff,
    @JsonKey(name: 'duration_s') @LooseDouble() double? durationSeconds,

    /// Any `error` but `false` marks the call failed.
    @JsonKey(name: 'error', fromJson: _isError) @Default(false) bool failed,
  }) = _ToolEvent;

  factory ToolEvent.fromJson(Map<String, dynamic> json) =>
      _$ToolEventFromJson(json);
}

Object? _toolId(Map<dynamic, dynamic> json, String key) {
  for (final k in const ['tool_id', 'tool_call_id', 'id']) {
    final id = const LooseString().fromJson(json[k]);
    if (id.isNotEmpty) return id;
  }
  return null;
}

Object? _resultText(Map<dynamic, dynamic> json, String key) {
  final text = const LooseString().fromJson(json[key]);
  return text.isNotEmpty ? text : json['result'];
}

bool _isError(Object? json) => json != null && json != false;

/// `message.complete`: the turn's whole text, its reasoning and how it ended
/// (a [TurnStatus]).
@Freezed(toJson: false)
abstract class TurnComplete with _$TurnComplete {
  const factory TurnComplete({
    @LooseString() @Default('') String text,
    @LooseString() @Default('') String reasoning,
    @LooseString() @Default('') String status,
    @LooseString() @Default('') String error,
  }) = _TurnComplete;

  factory TurnComplete.fromJson(Map<String, dynamic> json) =>
      _$TurnCompleteFromJson(json);
}

/// `message.interim`: a commentary line between tool calls.
@Freezed(toJson: false)
abstract class InterimMessage with _$InterimMessage {
  const factory InterimMessage({
    @LooseString() @Default('') String text,

    /// Its words came as deltas already.
    @JsonKey(name: 'already_streamed')
    @LooseBool()
    @Default(false)
    bool alreadyStreamed,
  }) = _InterimMessage;

  factory InterimMessage.fromJson(Map<String, dynamic> json) =>
      _$InterimMessageFromJson(json);
}

/// What a live `session.info` says of the session's runtime. [running] is
/// null when the event does not say.
@Freezed(toJson: false)
abstract class SessionInfoEvent with _$SessionInfoEvent {
  const factory SessionInfoEvent({
    @LooseString() @Default('') String model,
    @JsonKey(name: 'reasoning_effort')
    @LooseString()
    @Default('')
    String reasoningEffort,
    @LooseString() @Default('') String provider,
    @JsonKey(fromJson: _strictBool) bool? running,
  }) = _SessionInfoEvent;

  factory SessionInfoEvent.fromJson(Map<String, dynamic> json) =>
      _$SessionInfoEventFromJson(json);
}

bool? _strictBool(Object? json) => json is bool ? json : null;

/// Typed reads of the events a chat applies.
extension ChatEventPayloads on GatewayEvent {
  Map<String, dynamic> get _json => payload ?? const {};

  ToolEvent get tool => ToolEvent.fromJson(_json);
  TurnComplete get turnComplete => TurnComplete.fromJson(_json);
  InterimMessage get interim => InterimMessage.fromJson(_json);
  SessionInfoEvent get sessionInfo => SessionInfoEvent.fromJson(_json);
  TodoPlan get todoPlan => TodoPlan.fromJson(_json);

  /// The words of an `error` event.
  String get errorMessage => text('message');

  /// The tool a `tool.generating` event is writing the call of.
  String get generatingTool => text('name');

  /// The session a `session.reclaimed` event took back.
  String get reclaimedSession => text('session_id');

  /// A `session.resume_progress` event says the transcript is in.
  bool get resumeDone => text('status') == 'complete';
}
