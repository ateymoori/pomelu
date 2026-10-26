// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocalAttachment _$LocalAttachmentFromJson(Map<String, dynamic> json) =>
    _LocalAttachment(
      id: const LooseString().fromJson(json['id']),
      path: const LooseString().fromJson(json['path']),
      name: const LooseString().fromJson(json['name']),
      mimeType: const LooseString().fromJson(json['mime_type']),
      sizeBytes: const LooseInt().fromJson(json['size_bytes']),
      kind:
          $enumDecodeNullable(
            _$AttachmentKindEnumMap,
            json['kind'],
            unknownValue: AttachmentKind.file,
          ) ??
          AttachmentKind.file,
      duration: const DurationMillis().fromJson(json['duration_ms']),
      thumbnailPath: json['thumbnail_path'] as String?,
    );

Map<String, dynamic> _$LocalAttachmentToJson(_LocalAttachment instance) =>
    <String, dynamic>{
      'id': const LooseString().toJson(instance.id),
      'path': const LooseString().toJson(instance.path),
      'name': const LooseString().toJson(instance.name),
      'mime_type': const LooseString().toJson(instance.mimeType),
      'size_bytes': const LooseInt().toJson(instance.sizeBytes),
      'kind': _$AttachmentKindEnumMap[instance.kind]!,
      'duration_ms': ?const DurationMillis().toJson(instance.duration),
      'thumbnail_path': ?instance.thumbnailPath,
    };

const _$AttachmentKindEnumMap = {
  AttachmentKind.image: 'image',
  AttachmentKind.video: 'video',
  AttachmentKind.audio: 'audio',
  AttachmentKind.file: 'file',
};
