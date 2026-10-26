// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turn_payloads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ToolEvent _$ToolEventFromJson(Map<String, dynamic> json) => _ToolEvent(
  id: _toolId(json, 'id') == null
      ? ''
      : const LooseString().fromJson(_toolId(json, 'id')),
  name: json['name'] == null ? '' : const LooseString().fromJson(json['name']),
  context: json['context'] == null
      ? ''
      : const LooseString().fromJson(json['context']),
  resultText: const LooseStringOrNull().fromJson(
    _resultText(json, 'result_text'),
  ),
  inlineDiff: json['inline_diff'] == null
      ? ''
      : const LooseString().fromJson(json['inline_diff']),
  durationSeconds: const LooseDouble().fromJson(json['duration_s']),
  failed: json['error'] == null ? false : _isError(json['error']),
);

_TurnComplete _$TurnCompleteFromJson(Map<String, dynamic> json) =>
    _TurnComplete(
      text: json['text'] == null
          ? ''
          : const LooseString().fromJson(json['text']),
      reasoning: json['reasoning'] == null
          ? ''
          : const LooseString().fromJson(json['reasoning']),
      status: json['status'] == null
          ? ''
          : const LooseString().fromJson(json['status']),
      error: json['error'] == null
          ? ''
          : const LooseString().fromJson(json['error']),
    );

_InterimMessage _$InterimMessageFromJson(Map<String, dynamic> json) =>
    _InterimMessage(
      text: json['text'] == null
          ? ''
          : const LooseString().fromJson(json['text']),
      alreadyStreamed: json['already_streamed'] == null
          ? false
          : const LooseBool().fromJson(json['already_streamed']),
    );

_SessionInfoEvent _$SessionInfoEventFromJson(Map<String, dynamic> json) =>
    _SessionInfoEvent(
      model: json['model'] == null
          ? ''
          : const LooseString().fromJson(json['model']),
      reasoningEffort: json['reasoning_effort'] == null
          ? ''
          : const LooseString().fromJson(json['reasoning_effort']),
      provider: json['provider'] == null
          ? ''
          : const LooseString().fromJson(json['provider']),
      running: _strictBool(json['running']),
    );
