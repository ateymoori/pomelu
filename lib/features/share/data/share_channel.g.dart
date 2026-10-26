// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SharedItem _$SharedItemFromJson(Map<String, dynamic> json) => _SharedItem(
  type: json['type'] as String,
  text: json['text'] as String?,
  path: json['path'] as String?,
  mime: json['mime'] as String?,
  name: json['name'] as String?,
  count: (json['count'] as num?)?.toInt() ?? 0,
  profile: json['profile'] as String?,
);

Map<String, dynamic> _$SharedItemToJson(_SharedItem instance) =>
    <String, dynamic>{
      'type': instance.type,
      'text': instance.text,
      'path': instance.path,
      'mime': instance.mime,
      'name': instance.name,
      'count': instance.count,
      'profile': instance.profile,
    };
