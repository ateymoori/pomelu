// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cron_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CronSchedule _$CronScheduleFromJson(
  Map<String, dynamic> json,
) => _CronSchedule(
  kind: json['kind'] == null ? '' : const LooseString().fromJson(json['kind']),
  expr: json['expr'] == null ? '' : const LooseString().fromJson(json['expr']),
  minutes: json['minutes'] == null
      ? 0
      : const LooseInt().fromJson(json['minutes']),
  runAt: const LooseDateTime().fromJson(json['run_at']),
  display: json['display'] == null
      ? ''
      : const LooseString().fromJson(json['display']),
);

Map<String, dynamic> _$CronScheduleToJson(_CronSchedule instance) =>
    <String, dynamic>{
      'kind': const LooseString().toJson(instance.kind),
      'expr': const LooseString().toJson(instance.expr),
      'minutes': const LooseInt().toJson(instance.minutes),
      'run_at': const LooseDateTime().toJson(instance.runAt),
      'display': const LooseString().toJson(instance.display),
    };
