// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ModelProvider _$ModelProviderFromJson(
  Map<String, dynamic> json,
) => _ModelProvider(
  slug: json['slug'] == null ? '' : const LooseString().fromJson(json['slug']),
  name: json['name'] == null ? '' : const LooseString().fromJson(json['name']),
  isCurrent: json['is_current'] == null
      ? false
      : const LooseBool().fromJson(json['is_current']),
  authenticated: json['authenticated'] == null
      ? true
      : const LooseBool().fromJson(json['authenticated']),
  models: json['models'] == null
      ? const <String>[]
      : _stringsFromJson(json['models']),
  capabilities: const LooseMap().fromJson(json['capabilities']),
);

Map<String, dynamic> _$ModelProviderToJson(_ModelProvider instance) =>
    <String, dynamic>{
      'slug': const LooseString().toJson(instance.slug),
      'name': const LooseString().toJson(instance.name),
      'is_current': const LooseBool().toJson(instance.isCurrent),
      'authenticated': const LooseBool().toJson(instance.authenticated),
      'models': instance.models,
      'capabilities': const LooseMap().toJson(instance.capabilities),
    };

_ModelOptions _$ModelOptionsFromJson(Map<String, dynamic> json) =>
    _ModelOptions(
      providers: json['providers'] == null
          ? const <ModelProvider>[]
          : _providersFromJson(json['providers']),
      model: json['model'] == null
          ? ''
          : const LooseString().fromJson(json['model']),
      provider: json['provider'] == null
          ? ''
          : const LooseString().fromJson(json['provider']),
    );

Map<String, dynamic> _$ModelOptionsToJson(_ModelOptions instance) =>
    <String, dynamic>{
      'providers': instance.providers,
      'model': const LooseString().toJson(instance.model),
      'provider': const LooseString().toJson(instance.provider),
    };
