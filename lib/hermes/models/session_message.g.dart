// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionMessage _$SessionMessageFromJson(
  Map<String, dynamic> json,
) => _SessionMessage(
  role: json['role'] == null ? '' : const LooseString().fromJson(json['role']),
  text: json['text'] == null ? '' : const LooseString().fromJson(json['text']),
  timestamp: dateTimeFromEpochSeconds(json['timestamp']),
  rowId: const LooseIntOrNull().fromJson(json['row_id']),
  id: const LooseIntOrNull().fromJson(json['id']),
  reasoning: const LooseStringOrNull().fromJson(json['reasoning']),
  reasoningContent: const LooseStringOrNull().fromJson(
    json['reasoning_content'],
  ),
  displayKind: const LooseStringOrNull().fromJson(json['display_kind']),
  name: const LooseStringOrNull().fromJson(json['name']),
  context: json['context'] == null
      ? ''
      : const LooseString().fromJson(json['context']),
  content: json['content'] == null
      ? ''
      : const ContentText().fromJson(json['content']),
  displayContent: const LooseStringOrNull().fromJson(json['display_content']),
  storedToolName: const LooseStringOrNull().fromJson(json['tool_name']),
);

Map<String, dynamic> _$SessionMessageToJson(
  _SessionMessage instance,
) => <String, dynamic>{
  'role': const LooseString().toJson(instance.role),
  'text': const LooseString().toJson(instance.text),
  'timestamp': instance.timestamp?.toIso8601String(),
  'row_id': const LooseIntOrNull().toJson(instance.rowId),
  'id': const LooseIntOrNull().toJson(instance.id),
  'reasoning': const LooseStringOrNull().toJson(instance.reasoning),
  'reasoning_content': const LooseStringOrNull().toJson(
    instance.reasoningContent,
  ),
  'display_kind': const LooseStringOrNull().toJson(instance.displayKind),
  'name': const LooseStringOrNull().toJson(instance.name),
  'context': const LooseString().toJson(instance.context),
  'content': const ContentText().toJson(instance.content),
  'display_content': const LooseStringOrNull().toJson(instance.displayContent),
  'tool_name': const LooseStringOrNull().toJson(instance.storedToolName),
};
