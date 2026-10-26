// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compress_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CompressResult _$CompressResultFromJson(Map<String, dynamic> json) =>
    _CompressResult(
      status: json['status'] == null
          ? ''
          : const LooseString().fromJson(json['status']),
      summary: json['summary'] == null
          ? null
          : CompressSummary.fromJson(json['summary'] as Map<String, dynamic>),
      lockHeld: json['lock_held'] == null
          ? false
          : const LooseBool().fromJson(json['lock_held']),
      message: json['message'] == null
          ? ''
          : const LooseString().fromJson(json['message']),
    );

Map<String, dynamic> _$CompressResultToJson(_CompressResult instance) =>
    <String, dynamic>{
      'status': const LooseString().toJson(instance.status),
      'summary': instance.summary,
      'lock_held': const LooseBool().toJson(instance.lockHeld),
      'message': const LooseString().toJson(instance.message),
    };

_CompressSummary _$CompressSummaryFromJson(Map<String, dynamic> json) =>
    _CompressSummary(
      headline: json['headline'] == null
          ? ''
          : const LooseString().fromJson(json['headline']),
      tokenLine: json['token_line'] == null
          ? ''
          : const LooseString().fromJson(json['token_line']),
      note: json['note'] == null
          ? ''
          : const LooseString().fromJson(json['note']),
    );

Map<String, dynamic> _$CompressSummaryToJson(_CompressSummary instance) =>
    <String, dynamic>{
      'headline': const LooseString().toJson(instance.headline),
      'token_line': const LooseString().toJson(instance.tokenLine),
      'note': const LooseString().toJson(instance.note),
    };
