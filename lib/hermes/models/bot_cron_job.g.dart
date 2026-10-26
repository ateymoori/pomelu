// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_cron_job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BotCronJob _$BotCronJobFromJson(Map<String, dynamic> json) => _BotCronJob(
  id: json['id'] == null ? '' : const LooseString().fromJson(json['id']),
  name: json['name'] == null ? '' : const LooseString().fromJson(json['name']),
  prompt: json['prompt'] == null
      ? ''
      : const LooseString().fromJson(json['prompt']),
  schedule: _scheduleFromJson(json['schedule']),
  scheduleDisplay: json['schedule_display'] == null
      ? ''
      : const LooseString().fromJson(json['schedule_display']),
  state: json['state'] == null
      ? ''
      : const LooseString().fromJson(json['state']),
  nextRunAt: const LooseDateTime().fromJson(json['next_run_at']),
  lastRunAt: const LooseDateTime().fromJson(json['last_run_at']),
  lastStatus: json['last_status'] == null
      ? ''
      : const LooseString().fromJson(json['last_status']),
  lastError: json['last_error'] == null
      ? ''
      : const LooseString().fromJson(json['last_error']),
  lastDeliveryError: json['last_delivery_error'] == null
      ? ''
      : const LooseString().fromJson(json['last_delivery_error']),
);

Map<String, dynamic> _$BotCronJobToJson(
  _BotCronJob instance,
) => <String, dynamic>{
  'id': const LooseString().toJson(instance.id),
  'name': const LooseString().toJson(instance.name),
  'prompt': const LooseString().toJson(instance.prompt),
  'schedule': instance.schedule,
  'schedule_display': const LooseString().toJson(instance.scheduleDisplay),
  'state': const LooseString().toJson(instance.state),
  'next_run_at': const LooseDateTime().toJson(instance.nextRunAt),
  'last_run_at': const LooseDateTime().toJson(instance.lastRunAt),
  'last_status': const LooseString().toJson(instance.lastStatus),
  'last_error': const LooseString().toJson(instance.lastError),
  'last_delivery_error': const LooseString().toJson(instance.lastDeliveryError),
};
