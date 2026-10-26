import 'package:freezed_annotation/freezed_annotation.dart';

import 'cron_schedule.dart';
import 'json_converters.dart';

part 'bot_cron_job.freezed.dart';
part 'bot_cron_job.g.dart';

/// One scheduled job of a bot, a row of `GET /api/cron/jobs?profile=`: the same
/// list the Hermes dashboard's Cron page shows.
@freezed
abstract class BotCronJob with _$BotCronJob {
  const BotCronJob._();

  const factory BotCronJob({
    @LooseString() @Default('') String id,
    @LooseString() @Default('') String name,

    @LooseString() @Default('') String prompt,

    @JsonKey(fromJson: _scheduleFromJson) CronSchedule? schedule,
    @JsonKey(name: 'schedule_display')
    @LooseString()
    @Default('')
    String scheduleDisplay,

    @LooseString() @Default('') String state,
    @JsonKey(name: 'next_run_at') @LooseDateTime() DateTime? nextRunAt,
    @JsonKey(name: 'last_run_at') @LooseDateTime() DateTime? lastRunAt,

    @JsonKey(name: 'last_status') @LooseString() @Default('') String lastStatus,
    @JsonKey(name: 'last_error') @LooseString() @Default('') String lastError,
    @JsonKey(name: 'last_delivery_error')
    @LooseString()
    @Default('')
    String lastDeliveryError,
  }) = _BotCronJob;

  factory BotCronJob.fromJson(Map<String, dynamic> json) =>
      _$BotCronJobFromJson(json);

  /// The name to show: the job's name, else the first line of its prompt, else
  /// its id.
  String get title {
    if (name.trim().isNotEmpty) return name.trim();
    final line = prompt.trim().split('\n').first.trim();
    return line.isNotEmpty ? line : id;
  }

  bool get isPaused => state == 'paused';

  bool get isCompleted => state == 'completed';

  bool get lastRunFailed => lastStatus.isNotEmpty && lastStatus != 'ok';

  /// Why the last run went wrong, or empty. A failed delivery explains itself
  /// in its own field, anything else in `last_error`.
  String get lastDetail {
    final delivery = lastDeliveryError.trim();
    final run = lastError.trim();
    final byImportance = lastStatus == 'delivery_failed'
        ? [delivery, run]
        : [run, delivery];
    return byImportance.firstWhere((t) => t.isNotEmpty, orElse: () => '');
  }
}

CronSchedule? _scheduleFromJson(Object? json) =>
    json is Map<String, dynamic> ? CronSchedule.fromJson(json) : null;
