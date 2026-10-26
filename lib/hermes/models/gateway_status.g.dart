// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gateway_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GatewayStatus _$GatewayStatusFromJson(Map<String, dynamic> json) =>
    _GatewayStatus(
      version: json['version'] == null
          ? ''
          : const LooseString().fromJson(json['version']),
      authRequired: json['auth_required'] == null
          ? false
          : const LooseBool().fromJson(json['auth_required']),
      authProviders: const LooseStringList().fromJson(json['auth_providers']),
    );

Map<String, dynamic> _$GatewayStatusToJson(_GatewayStatus instance) =>
    <String, dynamic>{
      'version': const LooseString().toJson(instance.version),
      'auth_required': const LooseBool().toJson(instance.authRequired),
      'auth_providers': const LooseStringList().toJson(instance.authProviders),
    };
