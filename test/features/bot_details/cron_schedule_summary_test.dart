import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/bot_details/domain/cron_schedule_summary.dart';
import 'package:hermes/hermes/models/bot_cron_job.dart';
import 'package:hermes/hermes/models/cron_schedule.dart';

CronScheduleSummary _cron(String expr, {String display = ''}) =>
    CronScheduleSummary.of(
      BotCronJob(
        id: 'j',
        scheduleDisplay: display,
        schedule: CronSchedule(kind: 'cron', expr: expr),
      ),
    );

CronScheduleSummary _every(int minutes) => CronScheduleSummary.of(
  BotCronJob(
    id: 'j',
    schedule: CronSchedule(kind: 'interval', minutes: minutes),
  ),
);

void main() {
  group('interval', () {
    test('minutes, hours and days', () {
      expect(_every(5).cadence, CronCadence.everyMinutes);
      expect(_every(5).count, 5);
      expect(_every(90).cadence, CronCadence.everyMinutes);
      expect(_every(120).cadence, CronCadence.everyHours);
      expect(_every(120).count, 2);
      expect(_every(2880).cadence, CronCadence.everyDays);
      expect(_every(2880).count, 2);
    });

    test('no minutes falls back to the gateway text', () {
      final s = CronScheduleSummary.of(
        const BotCronJob(
          id: 'j',
          scheduleDisplay: 'every ?',
          schedule: CronSchedule(kind: 'interval'),
        ),
      );
      expect(s.cadence, CronCadence.other);
      expect(s.text, 'every ?');
    });
  });

  group('cron expression', () {
    test('every day at a time', () {
      final s = _cron('30 6 * * *');
      expect(s.cadence, CronCadence.daily);
      expect((s.hour, s.minute), (6, 30));
    });

    test('a list of days, Sunday as 0 or 7 and last', () {
      final s = _cron('0 9 * * 0,3,1');
      expect(s.cadence, CronCadence.weekly);
      expect(s.weekdays, [1, 3, 7]);
      expect(_cron('0 9 * * 7').weekdays, [7]);
    });

    test('anything it cannot read without doubt stays the raw text', () {
      for (final expr in [
        '*/10 * * * *',
        '0 */6 * * *',
        '0 9 1 * *',
        '0 9 * 3 *',
        '0 9 * * mon',
        '0 9 * * 5-1',
        '61 9 * * *',
        '0 25 * * *',
        '0 9 * * 1-3-5',
        '0 9 * * *  2099',
        '0 9 * *',
      ]) {
        final s = _cron(expr, display: expr);
        expect(s.cadence, CronCadence.other, reason: expr);
        expect(s.text, expr, reason: expr);
      }
    });
  });

  test('a one-shot has its moment', () {
    final at = DateTime.utc(2031, 1, 12, 12);
    final s = CronScheduleSummary.of(
      BotCronJob(
        id: 'j',
        schedule: CronSchedule(kind: 'once', runAt: at),
      ),
    );
    expect(s.cadence, CronCadence.once);
    expect(s.at, at);
  });
}
