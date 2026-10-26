// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OutboxEntry _$OutboxEntryFromJson(Map<String, dynamic> json) => _OutboxEntry(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  text: json['text'] as String? ?? '',
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => LocalAttachment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <LocalAttachment>[],
  status:
      $enumDecodeNullable(_$OutboxStatusEnumMap, json['status']) ??
      OutboxStatus.queued,
  error: $enumDecodeNullable(
    _$OutboxFailureEnumMap,
    json['error'],
    unknownValue: OutboxFailure.local,
  ),
  attempts: (json['attempts'] as num?)?.toInt() ?? 0,
  sentText: json['sentText'] as String?,
);

Map<String, dynamic> _$OutboxEntryToJson(_OutboxEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'text': instance.text,
      'attachments': instance.attachments,
      'status': _$OutboxStatusEnumMap[instance.status]!,
      'error': _$OutboxFailureEnumMap[instance.error],
      'attempts': instance.attempts,
      'sentText': instance.sentText,
    };

const _$OutboxStatusEnumMap = {
  OutboxStatus.queued: 'queued',
  OutboxStatus.sending: 'sending',
  OutboxStatus.submitted: 'submitted',
  OutboxStatus.failed: 'failed',
};

const _$OutboxFailureEnumMap = {
  OutboxFailure.stopped: 'stopped',
  OutboxFailure.unconfirmed: 'unconfirmed',
  OutboxFailure.network: 'network',
  OutboxFailure.refused: 'refused',
  OutboxFailure.local: 'local',
};
