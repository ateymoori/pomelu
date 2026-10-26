// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attach_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImageAttachResult _$ImageAttachResultFromJson(
  Map<String, dynamic> json,
) => _ImageAttachResult(
  attached: json['attached'] == null
      ? false
      : const LooseBool().fromJson(json['attached']),
  path: json['path'] == null ? '' : const LooseString().fromJson(json['path']),
  name: json['name'] == null ? '' : const LooseString().fromJson(json['name']),
  text: json['text'] == null ? '' : const LooseString().fromJson(json['text']),
  count: json['count'] == null ? 0 : const LooseInt().fromJson(json['count']),
  bytes: json['bytes'] == null ? 0 : const LooseInt().fromJson(json['bytes']),
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
);

Map<String, dynamic> _$ImageAttachResultToJson(_ImageAttachResult instance) =>
    <String, dynamic>{
      'attached': const LooseBool().toJson(instance.attached),
      'path': const LooseString().toJson(instance.path),
      'name': const LooseString().toJson(instance.name),
      'text': const LooseString().toJson(instance.text),
      'count': const LooseInt().toJson(instance.count),
      'bytes': const LooseInt().toJson(instance.bytes),
      'width': instance.width,
      'height': instance.height,
    };

_FileAttachResult _$FileAttachResultFromJson(
  Map<String, dynamic> json,
) => _FileAttachResult(
  name: json['name'] == null ? '' : const LooseString().fromJson(json['name']),
  path: json['path'] == null ? '' : const LooseString().fromJson(json['path']),
  refText: json['ref_text'] == null
      ? ''
      : const LooseString().fromJson(json['ref_text']),
);

Map<String, dynamic> _$FileAttachResultToJson(_FileAttachResult instance) =>
    <String, dynamic>{
      'name': const LooseString().toJson(instance.name),
      'path': const LooseString().toJson(instance.path),
      'ref_text': const LooseString().toJson(instance.refText),
    };
