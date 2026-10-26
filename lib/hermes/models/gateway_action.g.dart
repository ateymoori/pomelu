// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gateway_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GatewayAction _$GatewayActionFromJson(Map<String, dynamic> json) =>
    _GatewayAction(
      ok: json['ok'] == null ? false : const LooseBool().fromJson(json['ok']),
      name: json['name'] == null
          ? ''
          : const LooseString().fromJson(json['name']),
      error: json['error'] == null
          ? ''
          : const LooseString().fromJson(json['error']),
      message: json['message'] == null
          ? ''
          : const LooseString().fromJson(json['message']),
      updateCommand: json['update_command'] == null
          ? ''
          : const LooseString().fromJson(json['update_command']),
    );

Map<String, dynamic> _$GatewayActionToJson(_GatewayAction instance) =>
    <String, dynamic>{
      'ok': const LooseBool().toJson(instance.ok),
      'name': const LooseString().toJson(instance.name),
      'error': const LooseString().toJson(instance.error),
      'message': const LooseString().toJson(instance.message),
      'update_command': const LooseString().toJson(instance.updateCommand),
    };

_ActionStatus _$ActionStatusFromJson(Map<String, dynamic> json) =>
    _ActionStatus(
      name: json['name'] == null
          ? ''
          : const LooseString().fromJson(json['name']),
      running: json['running'] == null
          ? false
          : const LooseBool().fromJson(json['running']),
      exitCode: const LooseIntOrNull().fromJson(json['exit_code']),
      lines: const LooseStringList().fromJson(json['lines']),
    );

Map<String, dynamic> _$ActionStatusToJson(_ActionStatus instance) =>
    <String, dynamic>{
      'name': const LooseString().toJson(instance.name),
      'running': const LooseBool().toJson(instance.running),
      'exit_code': const LooseIntOrNull().toJson(instance.exitCode),
      'lines': const LooseStringList().toJson(instance.lines),
    };

_UpdateCheck _$UpdateCheckFromJson(Map<String, dynamic> json) => _UpdateCheck(
  currentVersion: json['current_version'] == null
      ? ''
      : const LooseString().fromJson(json['current_version']),
  behind: const LooseIntOrNull().fromJson(json['behind']),
  updateAvailable: json['update_available'] == null
      ? false
      : const LooseBool().fromJson(json['update_available']),
  canApply: json['can_apply'] == null
      ? false
      : const LooseBool().fromJson(json['can_apply']),
  updateCommand: json['update_command'] == null
      ? ''
      : const LooseString().fromJson(json['update_command']),
  message: json['message'] == null
      ? ''
      : const LooseString().fromJson(json['message']),
);

Map<String, dynamic> _$UpdateCheckToJson(_UpdateCheck instance) =>
    <String, dynamic>{
      'current_version': const LooseString().toJson(instance.currentVersion),
      'behind': const LooseIntOrNull().toJson(instance.behind),
      'update_available': const LooseBool().toJson(instance.updateAvailable),
      'can_apply': const LooseBool().toJson(instance.canApply),
      'update_command': const LooseString().toJson(instance.updateCommand),
      'message': const LooseString().toJson(instance.message),
    };
