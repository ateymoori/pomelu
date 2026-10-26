// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_soul.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BotSoul _$BotSoulFromJson(Map<String, dynamic> json) => _BotSoul(
  content: json['content'] == null
      ? ''
      : const LooseString().fromJson(json['content']),
  exists: json['exists'] == null
      ? false
      : const LooseBool().fromJson(json['exists']),
);

Map<String, dynamic> _$BotSoulToJson(_BotSoul instance) => <String, dynamic>{
  'content': const LooseString().toJson(instance.content),
  'exists': const LooseBool().toJson(instance.exists),
};
