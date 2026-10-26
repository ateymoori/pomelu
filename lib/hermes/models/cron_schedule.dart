import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'cron_schedule.freezed.dart';
part 'cron_schedule.g.dart';

/// When a cron job runs: the `schedule` object of a job row.
@freezed
abstract class CronSchedule with _$CronSchedule {
  const factory CronSchedule({
    @LooseString() @Default('') String kind,

    @LooseString() @Default('') String expr,
    @LooseInt() @Default(0) int minutes,
    @JsonKey(name: 'run_at') @LooseDateTime() DateTime? runAt,

    @LooseString() @Default('') String display,
  }) = _CronSchedule;

  factory CronSchedule.fromJson(Map<String, dynamic> json) =>
      _$CronScheduleFromJson(json);
}
