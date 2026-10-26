import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/bot_details/domain/cron_schedule_summary.dart';
import 'package:hermes/hermes/models/bot_cron_job.dart';
import 'package:hermes/hermes/models/cron_schedule.dart';

/// A phone [hours] east of UTC.
DateTime Function(DateTime) _phoneAt(int hours) =>
    (t) => t.toUtc().add(Duration(hours: hours));

/// Cron [expr] on the gateway's clock, next running at the UTC instant [next].
CronScheduleSummary _job(
  String expr,
  DateTime? next, {
  required int phoneOffset,
}) => CronScheduleSummary.of(
  BotCronJob(
    id: 'j',
    schedule: CronSchedule(kind: 'cron', expr: expr),
    nextRunAt: next,
  ),
  toLocal: _phoneAt(phoneOffset),
);

void main() {
  test('same zone: the expression time stands', () {
    // Gateway on UTC, phone on UTC.
    final s = _job(
      '20 6 * * *',
      DateTime.utc(2031, 1, 15, 6, 20),
      phoneOffset: 0,
    );
    expect((s.hour, s.minute), (6, 20));
    expect(s.gatewayClock, isFalse);
  });

  test('a gateway on UTC, a phone two hours east: the phone time', () {
    final s = _job(
      '20 6 * * *',
      DateTime.utc(2031, 1, 15, 6, 20),
      phoneOffset: 2,
    );
    expect((s.hour, s.minute), (8, 20));
  });

  test('weekdays move with a run that crosses midnight', () {
    // Gateway on UTC: Mon–Fri at 23:30. Phone two hours east: Tue–Sat 01:30.
    // 15 Jan 2031 is a Wednesday.
    final later = _job(
      '30 23 * * 1-5',
      DateTime.utc(2031, 1, 15, 23, 30),
      phoneOffset: 2,
    );
    expect((later.hour, later.minute), (1, 30));
    expect(later.weekdays, [2, 3, 4, 5, 6]);

    // Gateway on UTC: Mon and Sun at 01:00. Phone five hours west: Sun and
    // Sat at 20:00.
    final earlier = _job(
      '0 1 * * 1,0',
      DateTime.utc(2031, 1, 19, 1),
      phoneOffset: -5,
    );
    expect((earlier.hour, earlier.minute), (20, 0));
    expect(earlier.weekdays, [6, 7]);
  });

  test("with no next run the time is the gateway's, and says so", () {
    final s = _job('20 6 * * *', null, phoneOffset: 2);
    expect((s.hour, s.minute), (6, 20));
    expect(s.gatewayClock, isTrue);
  });
}
