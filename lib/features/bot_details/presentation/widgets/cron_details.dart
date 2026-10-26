import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/models/bot_cron_job.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/cron_schedule_summary.dart';

/// When the job runs, how the last run went, and what it is told to do.
class CronJobDetails extends StatelessWidget {
  const CronJobDetails({required this.job, super.key});

  final BotCronJob job;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final quiet = theme.bodySmall?.copyWith(color: colors.textSecondary);

    final schedule = cronScheduleText(context, CronScheduleSummary.of(job));
    final (next, nextColor) = switch (job) {
      BotCronJob(isPaused: true) => (l10n.botCronPaused, colors.warning),
      BotCronJob(isCompleted: true) => (l10n.botCronCompleted, null),
      BotCronJob(:final nextRunAt?) => (
        l10n.botCronNext(cronWhenText(context, nextRunAt)),
        null,
      ),
      _ => (null, null),
    };
    final ranAt = job.lastRunAt;
    final failed = job.lastRunFailed;
    final detail = job.lastDetail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: quiet,
            children: next == null
                ? [TextSpan(text: schedule)]
                : _scheduleAndNext(
                    l10n.botCronScheduleAndNext(schedule, next),
                    next,
                    nextColor,
                  ),
          ),
        ),
        SizedBox(height: spacing.xxs),
        Text(
          ranAt == null
              ? l10n.botCronNeverRan
              : l10n.botCronLastRun(
                  cronWhenText(context, ranAt),
                  failed
                      ? _statusWord(l10n, job.lastStatus)
                      : l10n.botCronStatusOk,
                ),
          style: quiet?.copyWith(color: failed ? colors.danger : null),
        ),
        if (failed && detail.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: spacing.xxs),
            child: Text(
              detail,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: quiet?.copyWith(color: colors.danger),
            ),
          ),
        if (job.name.trim().isNotEmpty && job.prompt.trim().isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: spacing.xs),
            child: Text(
              job.prompt.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: quiet,
            ),
          ),
      ],
    );
  }

  /// An unknown status shows as the gateway wrote it.
  static String _statusWord(AppLocalizations l10n, String status) =>
      switch (status) {
        'error' => l10n.botCronStatusError,
        'delivery_failed' => l10n.botCronStatusDeliveryFailed,
        _ => status,
      };

  /// [joined] with [next] in [color]; the translation decides the order.
  static List<InlineSpan> _scheduleAndNext(
    String joined,
    String next,
    Color? color,
  ) {
    final at = joined.lastIndexOf(next);
    if (at < 0 || color == null) return [TextSpan(text: joined)];
    return [
      TextSpan(text: joined.substring(0, at)),
      TextSpan(
        text: next,
        style: TextStyle(color: color),
      ),
      TextSpan(text: joined.substring(at + next.length)),
    ];
  }
}

/// `Daily at 06:30`, `Mon–Fri at 09:00`, `Every 5 minutes`, or the
/// gateway's text.
String cronScheduleText(BuildContext context, CronScheduleSummary summary) {
  final l10n = context.l10n;
  final text = _scheduleText(context, summary);
  return summary.gatewayClock ? l10n.botCronGatewayClock(text) : text;
}

String _scheduleText(BuildContext context, CronScheduleSummary summary) {
  final l10n = context.l10n;
  return switch (summary.cadence) {
    CronCadence.everyMinutes => l10n.botCronEveryMinutes(summary.count),
    CronCadence.everyHours => l10n.botCronEveryHours(summary.count),
    CronCadence.everyDays => l10n.botCronEveryDays(summary.count),
    CronCadence.daily => l10n.botCronDaily(
      _timeOfDay(context, summary.hour, summary.minute),
    ),
    CronCadence.weekly => l10n.botCronWeekly(
      _weekdays(context, summary.weekdays),
      _timeOfDay(context, summary.hour, summary.minute),
    ),
    CronCadence.once => l10n.botCronOnce(cronWhenText(context, summary.at!)),
    CronCadence.other => summary.text,
  };
}

/// `Today, 06:30`, `Tomorrow, 06:30`, `Oct 9, 06:30`. [now] is for tests.
String cronWhenText(BuildContext context, DateTime moment, {DateTime? now}) {
  final l10n = context.l10n;
  final local = moment.toLocal();
  final days = Format.calendarDays(now ?? DateTime.now(), local);
  final day = switch (days) {
    0 => l10n.timeToday,
    -1 => l10n.timeYesterday,
    1 => l10n.timeTomorrow,
    _ => DateFormat.MMMd(_locale(context)).format(local),
  };
  return l10n.botCronWhen(day, _timeOfDay(context, local.hour, local.minute));
}

String _locale(BuildContext context) =>
    Localizations.localeOf(context).toString();

String _timeOfDay(BuildContext context, int hour, int minute) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: hour, minute: minute),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

/// `Mon, Wed, Fri`; three days or more in a row as `Mon–Fri`.
String _weekdays(BuildContext context, List<int> days) {
  // 1 January 2024 was a Monday.
  final name = DateFormat.E(_locale(context));
  String of(int day) => name.format(DateTime(2024, 1, day));
  final l10n = context.l10n;
  final inARow = days.length >= 3 && days.last - days.first == days.length - 1;
  return inARow
      ? l10n.botCronWeekdayRange(of(days.first), of(days.last))
      : days.map(of).join(l10n.botCronListSeparator);
}
