// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_skill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BotSkill _$BotSkillFromJson(Map<String, dynamic> json) => _BotSkill(
  name: json['name'] == null ? '' : const LooseString().fromJson(json['name']),
  description: json['description'] == null
      ? ''
      : const LooseString().fromJson(json['description']),
  category: json['category'] == null
      ? ''
      : const LooseString().fromJson(json['category']),
  enabled: json['enabled'] == null
      ? true
      : const LooseBool().fromJson(json['enabled']),
);

Map<String, dynamic> _$BotSkillToJson(_BotSkill instance) => <String, dynamic>{
  'name': const LooseString().toJson(instance.name),
  'description': const LooseString().toJson(instance.description),
  'category': const LooseString().toJson(instance.category),
  'enabled': const LooseBool().toJson(instance.enabled),
};
