// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hermes_auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthProvider _$AuthProviderFromJson(Map<String, dynamic> json) =>
    _AuthProvider(
      name: json['name'] == null
          ? ''
          : const LooseString().fromJson(json['name']),
      displayName: json['display_name'] == null
          ? ''
          : const LooseString().fromJson(json['display_name']),
      supportsPassword: json['supports_password'] == null
          ? false
          : const LooseBool().fromJson(json['supports_password']),
    );

Map<String, dynamic> _$AuthProviderToJson(_AuthProvider instance) =>
    <String, dynamic>{
      'name': const LooseString().toJson(instance.name),
      'display_name': const LooseString().toJson(instance.displayName),
      'supports_password': const LooseBool().toJson(instance.supportsPassword),
    };

_TokenRefresh _$TokenRefreshFromJson(Map<String, dynamic> json) =>
    _TokenRefresh(
      accessToken: json['access_token'] == null
          ? ''
          : const LooseString().fromJson(json['access_token']),
      refreshToken: const LooseStringOrNull().fromJson(json['refresh_token']),
      provider: const LooseStringOrNull().fromJson(json['provider']),
      expiresAt: const LooseDateTime().fromJson(json['expires_at']),
    );

Map<String, dynamic> _$TokenRefreshToJson(_TokenRefresh instance) =>
    <String, dynamic>{
      'access_token': const LooseString().toJson(instance.accessToken),
      'refresh_token': const LooseStringOrNull().toJson(instance.refreshToken),
      'provider': const LooseStringOrNull().toJson(instance.provider),
      'expires_at': const LooseDateTime().toJson(instance.expiresAt),
    };
