// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_screen.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScreenLease _$ScreenLeaseFromJson(Map<String, dynamic> json) => _ScreenLease(
  holder:
      $enumDecodeNullable(
        _$ScreenHolderEnumMap,
        json['holder'],
        unknownValue: ScreenHolder.agent,
      ) ??
      ScreenHolder.agent,
  viewerHash: const LooseStringOrNull().fromJson(json['viewer_hash']),
  epoch: json['epoch'] == null ? 0 : const LooseInt().fromJson(json['epoch']),
);

Map<String, dynamic> _$ScreenLeaseToJson(_ScreenLease instance) =>
    <String, dynamic>{
      'holder': _$ScreenHolderEnumMap[instance.holder]!,
      'viewer_hash': const LooseStringOrNull().toJson(instance.viewerHash),
      'epoch': const LooseInt().toJson(instance.epoch),
    };

const _$ScreenHolderEnumMap = {
  ScreenHolder.agent: 'agent',
  ScreenHolder.human: 'human',
};

_ScreenStatus _$ScreenStatusFromJson(Map<String, dynamic> json) =>
    _ScreenStatus(
      supported: json['supported'] == null
          ? false
          : const LooseBool().fromJson(json['supported']),
      installed: json['installed'] == null
          ? false
          : const LooseBool().fromJson(json['installed']),
      running: json['running'] == null
          ? false
          : const LooseBool().fromJson(json['running']),
      blocker: const LooseStringOrNull().fromJson(json['blocker']),
      lease: json['lease'] == null
          ? const ScreenLease()
          : ScreenLease.fromJson(json['lease'] as Map<String, dynamic>),
      profileKey: json['profile_key'] == null
          ? ''
          : const LooseString().fromJson(json['profile_key']),
    );

Map<String, dynamic> _$ScreenStatusToJson(_ScreenStatus instance) =>
    <String, dynamic>{
      'supported': const LooseBool().toJson(instance.supported),
      'installed': const LooseBool().toJson(instance.installed),
      'running': const LooseBool().toJson(instance.running),
      'blocker': const LooseStringOrNull().toJson(instance.blocker),
      'lease': instance.lease,
      'profile_key': const LooseString().toJson(instance.profileKey),
    };
