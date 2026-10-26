import '../../../hermes/models/bot_cron_job.dart';

/// The schedules the Cron tab words itself; [other] shows the gateway's text.
enum CronCadence {
  everyMinutes,
  everyHours,
  everyDays,
  daily,
  weekly,
  once,
  other,
}

/// A job's schedule in parts the screen words. Only what it reads without
/// doubt: a step, a month or a day of the month stays the raw expression.
///
/// A cron expression is the gateway's wall time, in a zone the API does not
/// say; so the time (and the weekdays, when the run crosses midnight) is read
/// off `next_run_at` in the phone's time. With no next run the expression's
/// time stays, marked as the gateway's ([gatewayClock]).
class CronScheduleSummary {
  const CronScheduleSummary._(
    this.cadence, {
    this.count = 0,
    this.hour = 0,
    this.minute = 0,
    this.weekdays = const [],
    this.at,
    this.text = '',
    this.gatewayClock = false,
  });

  final CronCadence cadence;

  final int count;

  final int hour;
  final int minute;

  /// Monday 1 to Sunday 7, in order.
  final List<int> weekdays;

  final DateTime? at;

  final String text;

  final bool gatewayClock;

  /// [toLocal] puts an instant in the phone's zone (a test fixes one).
  factory CronScheduleSummary.of(
    BotCronJob job, {
    DateTime Function(DateTime)? toLocal,
  }) {
    final schedule = job.schedule;
    final other = CronScheduleSummary._(
      CronCadence.other,
      text: [
        job.scheduleDisplay,
        schedule?.display ?? '',
        schedule?.expr ?? '',
      ].firstWhere((t) => t.trim().isNotEmpty, orElse: () => ''),
    );
    if (schedule == null) return other;

    switch (schedule.kind) {
      case 'interval' when schedule.minutes > 0:
        final m = schedule.minutes;
        if (m % Duration.minutesPerDay == 0) {
          return CronScheduleSummary._(
            CronCadence.everyDays,
            count: m ~/ Duration.minutesPerDay,
          );
        }
        if (m % Duration.minutesPerHour == 0) {
          return CronScheduleSummary._(
            CronCadence.everyHours,
            count: m ~/ Duration.minutesPerHour,
          );
        }
        return CronScheduleSummary._(CronCadence.everyMinutes, count: m);
      case 'once' when schedule.runAt != null:
        return CronScheduleSummary._(CronCadence.once, at: schedule.runAt);
      case 'cron':
        final wall = _fromExpression(schedule.expr);
        if (wall == null) return other;
        final next = job.nextRunAt;
        return next == null
            ? wall._onGatewayClock()
            : wall._inPhoneTime((toLocal ?? _local)(next));
    }
    return other;
  }

  static DateTime _local(DateTime t) => t.toLocal();

  CronScheduleSummary _onGatewayClock() => CronScheduleSummary._(
    cadence,
    hour: hour,
    minute: minute,
    weekdays: weekdays,
    gatewayClock: true,
  );

  /// The schedule in the phone's time, the clocks' offset read off the next
  /// run [local]; zones differ by under a day.
  CronScheduleSummary _inPhoneTime(DateTime local) {
    const day = Duration.minutesPerDay;
    final wall = hour * Duration.minutesPerHour + minute;
    final phone = local.hour * Duration.minutesPerHour + local.minute;
    // The shortest way round the clock: -12 h < offset <= 12 h.
    final offset = (phone - wall + day ~/ 2 - 1) % day - day ~/ 2 + 1;
    final moved = wall + offset;
    final dayShift = moved < 0 ? -1 : (moved >= day ? 1 : 0);
    return CronScheduleSummary._(
      cadence,
      hour: local.hour,
      minute: local.minute,
      weekdays: [
        for (final d in weekdays) (d - 1 + dayShift) % DateTime.daysPerWeek + 1,
      ]..sort(),
    );
  }

  /// `M H * * *` and `M H * * days`, or null for any other expression.
  static CronScheduleSummary? _fromExpression(String expr) {
    final f = expr.trim().split(RegExp(r'\s+'));
    if (f.length != 5 || f[2] != '*' || f[3] != '*') return null;
    final minute = _number(f[0], max: 59);
    final hour = _number(f[1], max: 23);
    if (minute == null || hour == null) return null;
    if (f[4] == '*') {
      return CronScheduleSummary._(
        CronCadence.daily,
        hour: hour,
        minute: minute,
      );
    }
    final days = _weekdays(f[4]);
    if (days == null) return null;
    return CronScheduleSummary._(
      CronCadence.weekly,
      hour: hour,
      minute: minute,
      weekdays: days,
    );
  }

  static int? _number(String s, {required int max}) {
    final n = RegExp(r'^\d{1,2}$').hasMatch(s) ? int.parse(s) : null;
    return n != null && n <= max ? n : null;
  }

  /// `1,3,5` or `1-5` (0 and 7 are Sunday) as sorted Monday-first numbers.
  static List<int>? _weekdays(String field) {
    final days = <int>{};
    for (final part in field.split(',')) {
      final range = part.split('-');
      final from = _number(range.first, max: 7);
      final to = range.length == 2 ? _number(range.last, max: 7) : from;
      if (range.length > 2 || from == null || to == null || from > to) {
        return null;
      }
      for (var d = from; d <= to; d++) {
        days.add(d == 0 ? 7 : d);
      }
    }
    return days.toList()..sort();
  }
}
