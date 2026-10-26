// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionSummary _$SessionSummaryFromJson(Map<String, dynamic> json) =>
    _SessionSummary(
      id: json['id'] == null ? '' : const LooseString().fromJson(json['id']),
      title: json['title'] == null
          ? ''
          : const LooseString().fromJson(json['title']),
      preview: json['preview'] == null
          ? ''
          : const LooseString().fromJson(json['preview']),
      profile: json['profile'] == null
          ? ''
          : const LooseString().fromJson(json['profile']),
      model: json['model'] == null
          ? ''
          : const LooseString().fromJson(json['model']),
      lastActive: dateTimeFromEpochSeconds(json['last_active']),
      startedAt: dateTimeFromEpochSeconds(json['started_at']),
      messageCount: json['message_count'] == null
          ? 0
          : const LooseInt().fromJson(json['message_count']),
      parentSessionId: const LooseStringOrNull().fromJson(
        json['parent_session_id'],
      ),
      resolvedId: const LooseStringOrNull().fromJson(json['resolved_id']),
      endReason: const LooseStringOrNull().fromJson(json['end_reason']),
      hidden: json['hidden'] == null
          ? false
          : const LooseBool().fromJson(json['hidden']),
      isActive: json['is_active'] == null
          ? false
          : const LooseBool().fromJson(json['is_active']),
    );

Map<String, dynamic> _$SessionSummaryToJson(_SessionSummary instance) =>
    <String, dynamic>{
      'id': const LooseString().toJson(instance.id),
      'title': const LooseString().toJson(instance.title),
      'preview': const LooseString().toJson(instance.preview),
      'profile': const LooseString().toJson(instance.profile),
      'model': const LooseString().toJson(instance.model),
      'last_active': instance.lastActive?.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'message_count': const LooseInt().toJson(instance.messageCount),
      'parent_session_id': const LooseStringOrNull().toJson(
        instance.parentSessionId,
      ),
      'resolved_id': const LooseStringOrNull().toJson(instance.resolvedId),
      'end_reason': const LooseStringOrNull().toJson(instance.endReason),
      'hidden': const LooseBool().toJson(instance.hidden),
      'is_active': const LooseBool().toJson(instance.isActive),
    };
