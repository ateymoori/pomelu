// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_credential.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionTokenCredential _$SessionTokenCredentialFromJson(
  Map<String, dynamic> json,
) => _SessionTokenCredential(
  json['token'] as String,
  origin: json['origin'] as String? ?? '',
);

Map<String, dynamic> _$SessionTokenCredentialToJson(
  _SessionTokenCredential instance,
) => <String, dynamic>{'token': instance.token, 'origin': instance.origin};

_BearerCredential _$BearerCredentialFromJson(Map<String, dynamic> json) =>
    _BearerCredential(
      accessToken: const LooseString().fromJson(json['accessToken']),
      refreshToken: const LooseStringOrNull().fromJson(json['refreshToken']),
      provider: json['provider'] == null
          ? ''
          : const LooseString().fromJson(json['provider']),
      expiresAt: const LooseDateTime().fromJson(json['expiresAt']),
      username: json['username'] == null
          ? ''
          : const LooseString().fromJson(json['username']),
      origin: json['origin'] == null
          ? ''
          : const LooseString().fromJson(json['origin']),
    );

Map<String, dynamic> _$BearerCredentialToJson(_BearerCredential instance) =>
    <String, dynamic>{
      'accessToken': const LooseString().toJson(instance.accessToken),
      'refreshToken': const LooseStringOrNull().toJson(instance.refreshToken),
      'provider': const LooseString().toJson(instance.provider),
      'expiresAt': const LooseDateTime().toJson(instance.expiresAt),
      'username': const LooseString().toJson(instance.username),
      'origin': const LooseString().toJson(instance.origin),
    };
