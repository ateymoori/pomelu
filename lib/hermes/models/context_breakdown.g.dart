// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_breakdown.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContextBreakdown _$ContextBreakdownFromJson(Map<String, dynamic> json) =>
    _ContextBreakdown(
      categories: json['categories'] == null
          ? const <ContextCategory>[]
          : _categoriesFromJson(json['categories']),
      contextMax: json['context_max'] == null
          ? 0
          : const LooseInt().fromJson(json['context_max']),
      contextUsed: json['context_used'] == null
          ? 0
          : const LooseInt().fromJson(json['context_used']),
      contextPercent: const LooseDouble().fromJson(json['context_percent']),
      contextSource: json['context_source'] == null
          ? ''
          : const LooseString().fromJson(json['context_source']),
      model: json['model'] == null
          ? ''
          : const LooseString().fromJson(json['model']),
      contextFiles: json['context_files'] == null
          ? const <ContextFile>[]
          : _filesFromJson(json['context_files']),
    );

Map<String, dynamic> _$ContextBreakdownToJson(_ContextBreakdown instance) =>
    <String, dynamic>{
      'categories': instance.categories,
      'context_max': const LooseInt().toJson(instance.contextMax),
      'context_used': const LooseInt().toJson(instance.contextUsed),
      'context_percent': const LooseDouble().toJson(instance.contextPercent),
      'context_source': const LooseString().toJson(instance.contextSource),
      'model': const LooseString().toJson(instance.model),
      'context_files': instance.contextFiles,
    };

_ContextCategory _$ContextCategoryFromJson(Map<String, dynamic> json) =>
    _ContextCategory(
      id: json['id'] == null ? '' : const LooseString().fromJson(json['id']),
      label: json['label'] == null
          ? ''
          : const LooseString().fromJson(json['label']),
      tokens: json['tokens'] == null
          ? 0
          : const LooseInt().fromJson(json['tokens']),
    );

Map<String, dynamic> _$ContextCategoryToJson(_ContextCategory instance) =>
    <String, dynamic>{
      'id': const LooseString().toJson(instance.id),
      'label': const LooseString().toJson(instance.label),
      'tokens': const LooseInt().toJson(instance.tokens),
    };

_ContextFile _$ContextFileFromJson(Map<String, dynamic> json) => _ContextFile(
  label: json['label'] == null
      ? ''
      : const LooseString().fromJson(json['label']),
  path: json['path'] == null ? '' : const LooseString().fromJson(json['path']),
  tokens: json['est_tokens'] == null
      ? 0
      : const LooseInt().fromJson(json['est_tokens']),
  loaded: json['loaded'] == null
      ? false
      : const LooseBool().fromJson(json['loaded']),
  status: json['status'] == null
      ? ''
      : const LooseString().fromJson(json['status']),
);

Map<String, dynamic> _$ContextFileToJson(_ContextFile instance) =>
    <String, dynamic>{
      'label': const LooseString().toJson(instance.label),
      'path': const LooseString().toJson(instance.path),
      'est_tokens': const LooseInt().toJson(instance.tokens),
      'loaded': const LooseBool().toJson(instance.loaded),
      'status': const LooseString().toJson(instance.status),
    };
