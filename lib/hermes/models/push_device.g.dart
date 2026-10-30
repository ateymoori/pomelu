// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PushDevice _$PushDeviceFromJson(Map<String, dynamic> json) => _PushDevice(
  platform: json['platform'] as String,
  token: json['token'] as String,
  key: json['key'] as String,
  sandbox: json['sandbox'] as bool? ?? false,
);

Map<String, dynamic> _$PushDeviceToJson(_PushDevice instance) =>
    <String, dynamic>{
      'platform': instance.platform,
      'token': instance.token,
      'key': instance.key,
      'sandbox': instance.sandbox,
    };
