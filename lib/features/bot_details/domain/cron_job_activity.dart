import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../hermes/hermes_failure.dart';

part 'cron_job_activity.freezed.dart';

/// What the Cron tab can do to one job.
enum CronAction { pause, run, delete }

/// The action in flight on one cron job (every control waits meanwhile), or
/// why the last one failed.
@freezed
abstract class CronJobActivity with _$CronJobActivity {
  const CronJobActivity._();

  const factory CronJobActivity({CronAction? doing, HermesFailure? failure}) =
      _CronJobActivity;

  bool get idle => doing == null;
}
