// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HermesProfile _$HermesProfileFromJson(
  Map<String, dynamic> json,
) => _HermesProfile(
  name: json['name'] == null ? '' : const LooseString().fromJson(json['name']),
  isDefault: json['is_default'] == null
      ? false
      : const LooseBool().fromJson(json['is_default']),
  model: json['model'] == null
      ? ''
      : const LooseString().fromJson(json['model']),
  provider: json['provider'] == null
      ? ''
      : const LooseString().fromJson(json['provider']),
  description: json['description'] == null
      ? ''
      : const LooseString().fromJson(json['description']),
  displayName: json['display_name'] == null
      ? ''
      : const LooseString().fromJson(json['display_name']),
  lastSession: json['last_session'] == null
      ? null
      : SessionPreview.fromJson(json['last_session'] as Map<String, dynamic>),
  workerSession: json['worker_session'] == null
      ? null
      : WorkerSession.fromJson(json['worker_session'] as Map<String, dynamic>),
  canonicalSession: json['canonical_session'] == null
      ? null
      : CanonicalSession.fromJson(
          json['canonical_session'] as Map<String, dynamic>,
        ),
  uiMeta: const LooseMap().fromJson(json['ui_meta']),
  uiMetaRevisions: const LooseMap().fromJson(json['ui_meta_revisions']),
);

Map<String, dynamic> _$HermesProfileToJson(_HermesProfile instance) =>
    <String, dynamic>{
      'name': const LooseString().toJson(instance.name),
      'is_default': const LooseBool().toJson(instance.isDefault),
      'model': const LooseString().toJson(instance.model),
      'provider': const LooseString().toJson(instance.provider),
      'description': const LooseString().toJson(instance.description),
      'display_name': const LooseString().toJson(instance.displayName),
      'last_session': instance.lastSession,
      'worker_session': instance.workerSession,
      'canonical_session': instance.canonicalSession,
      'ui_meta': const LooseMap().toJson(instance.uiMeta),
      'ui_meta_revisions': const LooseMap().toJson(instance.uiMetaRevisions),
    };

_SessionPreview _$SessionPreviewFromJson(Map<String, dynamic> json) =>
    _SessionPreview(
      id: json['id'] == null ? '' : const LooseString().fromJson(json['id']),
      title: json['title'] == null
          ? ''
          : const LooseString().fromJson(json['title']),
      preview: json['preview'] == null
          ? ''
          : const LooseString().fromJson(json['preview']),
      lastActive: dateTimeFromEpochSeconds(json['last_active']),
      messageCount: json['message_count'] == null
          ? 0
          : const LooseInt().fromJson(json['message_count']),
    );

Map<String, dynamic> _$SessionPreviewToJson(_SessionPreview instance) =>
    <String, dynamic>{
      'id': const LooseString().toJson(instance.id),
      'title': const LooseString().toJson(instance.title),
      'preview': const LooseString().toJson(instance.preview),
      'last_active': instance.lastActive?.toIso8601String(),
      'message_count': const LooseInt().toJson(instance.messageCount),
    };

_CanonicalSession _$CanonicalSessionFromJson(Map<String, dynamic> json) =>
    _CanonicalSession(
      id: json['id'] == null ? '' : const LooseString().fromJson(json['id']),
      resolvedId: const LooseStringOrNull().fromJson(json['resolved_id']),
      title: json['title'] == null
          ? ''
          : const LooseString().fromJson(json['title']),
      preview: json['preview'] == null
          ? ''
          : const LooseString().fromJson(json['preview']),
      lastActive: dateTimeFromEpochSeconds(json['last_active']),
      messageCount: json['message_count'] == null
          ? 0
          : const LooseInt().fromJson(json['message_count']),
    );

Map<String, dynamic> _$CanonicalSessionToJson(_CanonicalSession instance) =>
    <String, dynamic>{
      'id': const LooseString().toJson(instance.id),
      'resolved_id': const LooseStringOrNull().toJson(instance.resolvedId),
      'title': const LooseString().toJson(instance.title),
      'preview': const LooseString().toJson(instance.preview),
      'last_active': instance.lastActive?.toIso8601String(),
      'message_count': const LooseInt().toJson(instance.messageCount),
    };

_WorkerSession _$WorkerSessionFromJson(Map<String, dynamic> json) =>
    _WorkerSession(
      id: json['id'] == null ? '' : const LooseString().fromJson(json['id']),
      title: json['title'] == null
          ? ''
          : const LooseString().fromJson(json['title']),
      lastActive: dateTimeFromEpochSeconds(json['last_active']),
    );

Map<String, dynamic> _$WorkerSessionToJson(_WorkerSession instance) =>
    <String, dynamic>{
      'id': const LooseString().toJson(instance.id),
      'title': const LooseString().toJson(instance.title),
      'last_active': instance.lastActive?.toIso8601String(),
    };

_BotMeta _$BotMetaFromJson(Map<String, dynamic> json) => _BotMeta(
  color: const LooseStringOrNull().fromJson(json['color']),
  title: const LooseStringOrNull().fromJson(json['title']),
  description: const LooseStringOrNull().fromJson(json['description']),
  image: const LooseStringOrNull().fromJson(json['image']),
  shape: const LooseStringOrNull().fromJson(json['shape']),
  group: const LooseStringOrNull().fromJson(json['group']),
  hidden: json['hidden'] == null
      ? false
      : const LooseBool().fromJson(json['hidden']),
);

Map<String, dynamic> _$BotMetaToJson(_BotMeta instance) => <String, dynamic>{
  'color': const LooseStringOrNull().toJson(instance.color),
  'title': const LooseStringOrNull().toJson(instance.title),
  'description': const LooseStringOrNull().toJson(instance.description),
  'image': const LooseStringOrNull().toJson(instance.image),
  'shape': const LooseStringOrNull().toJson(instance.shape),
  'group': const LooseStringOrNull().toJson(instance.group),
  'hidden': const LooseBool().toJson(instance.hidden),
};
