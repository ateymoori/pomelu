// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_toolset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BotToolset _$BotToolsetFromJson(Map<String, dynamic> json) => _BotToolset(
  name: json['name'] == null ? '' : const LooseString().fromJson(json['name']),
  label: json['label'] == null
      ? ''
      : const LooseString().fromJson(json['label']),
  description: json['description'] == null
      ? ''
      : const LooseString().fromJson(json['description']),
  enabled: json['enabled'] == null
      ? false
      : const LooseBool().fromJson(json['enabled']),
  tools: const LooseStringList().fromJson(json['tools']),
);

Map<String, dynamic> _$BotToolsetToJson(_BotToolset instance) =>
    <String, dynamic>{
      'name': const LooseString().toJson(instance.name),
      'label': const LooseString().toJson(instance.label),
      'description': const LooseString().toJson(instance.description),
      'enabled': const LooseBool().toJson(instance.enabled),
      'tools': const LooseStringList().toJson(instance.tools),
    };
