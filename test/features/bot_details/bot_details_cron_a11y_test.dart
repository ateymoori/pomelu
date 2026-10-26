import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/hermes_failure.dart';

import '../../support/fake_bot_api.dart';
import 'bot_details_a11y_harness.dart';

void main() {
  group('cron', () {
    testWidgets('every button names its job', (tester) async {
      final handle = tester.ensureSemantics();
      final api = FakeBotApi(jobs: [job('daily-news'), job('weekly-mail')]);
      await open(tester, api, tab: 'Cron');

      for (final name in ['daily-news', 'weekly-mail']) {
        expect(find.byTooltip('Run $name now'), findsOneWidget);
        expect(find.byTooltip('Delete $name'), findsOneWidget);
        expect(
          tester.getSemantics(find.bySemanticsLabel('Run $name now')),
          isSemantics(
            label: 'Run $name now',
            isButton: true,
            hasTapAction: true,
          ),
        );
        expect(
          tester.getSemantics(find.bySemanticsLabel('Delete $name')),
          isSemantics(
            label: 'Delete $name',
            isButton: true,
            hasTapAction: true,
          ),
        );
      }
      handle.dispose();
    });

    testWidgets('a failed action is a live region', (tester) async {
      final handle = tester.ensureSemantics();
      final api = FakeBotApi(jobs: [job('daily-news')])
        ..cronFailure = const ServerFailure(
          'Job is already running',
          httpStatus: 409,
        );
      await open(tester, api, tab: 'Cron');

      await tester.tap(find.byTooltip('Run daily-news now'));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.textContaining('Job is already running')),
        isSemantics(isLiveRegion: true),
      );
      handle.dispose();
    });

    testWidgets('known statuses are worded, an unknown one is shown as is', (
      tester,
    ) async {
      final api = FakeBotApi(
        jobs: [
          job('a-job', status: 'error'),
          job('b-job', status: 'delivery_failed'),
          job('c-job', status: 'quota_exceeded'),
        ],
      );
      await open(tester, api, tab: 'Cron');

      expect(find.textContaining('· Failed'), findsOneWidget);
      expect(find.textContaining('· Delivery failed'), findsOneWidget);
      // Not capitalised, not reworded: it is the gateway's word.
      expect(find.textContaining('· quota_exceeded'), findsOneWidget);
    });

    testWidgets('the schedule and next run are joined by the translation', (
      tester,
    ) async {
      await open(tester, FakeBotApi(jobs: [job('a-job')]), tab: 'Cron');

      expect(
        find.textContaining(RegExp('Every 5 minutes · Next: Jan 15')),
        findsOneWidget,
      );
    });
  });
}
