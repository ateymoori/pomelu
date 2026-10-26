import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/bot_details/presentation/widgets/bot_details_sheet.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/bot_cron_job.dart';

import '../../support/app_host.dart';
import '../../support/fake_bot_api.dart';
import '../../support/fixtures.dart';

const _news = 'a1b2c3d4e5f6';

/// A gateway that keeps the fixture jobs.
FakeBotApi _api() =>
    FakeBotApi(jobs: fixtureList('cron_jobs.json', BotCronJob.fromJson));

Future<void> _open(WidgetTester tester, FakeBotApi api) async {
  // Tall enough for the whole list: rows below the fold are not built.
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpApp(
    tester,
    const BotDetailsSheet(profile: 'atlas'),
    overrides: [hermesApiProvider.overrideWithValue(api)],
  );
  await tester.pumpAndSettle();
}

Future<void> _openCron(WidgetTester tester, FakeBotApi api) async {
  await _open(tester, api);
  await tester.tap(find.text('Cron'));
  await tester.pumpAndSettle();
}

/// The switch of the job titled [title].
Finder _switchOf(String title) => find.descendant(
  of: find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == title,
  ),
  matching: find.byType(Switch),
);

Finder _inDialog(String text) =>
    find.descendant(of: find.byType(Dialog), matching: find.text(text));

void main() {
  testWidgets('every job shows its schedule in plain words', (tester) async {
    await _openCron(tester, _api());

    expect(find.text('daily-news'), findsOneWidget);
    expect(find.textContaining('Daily at'), findsOneWidget);
    expect(find.textContaining('Mon–Fri at'), findsOneWidget);
    expect(find.textContaining('Every 5 minutes'), findsOneWidget);
    expect(find.textContaining('Once, Jan 12'), findsOneWidget);
    // A schedule it cannot read without doubt stays what the gateway says.
    expect(find.textContaining('*/10 8-18 * * 1-5'), findsOneWidget);
  });

  testWidgets('next run, paused and completed read as such', (tester) async {
    await _openCron(tester, _api());

    expect(find.textContaining('Next: Jan 15'), findsWidgets);
    expect(find.textContaining('Paused'), findsOneWidget);
    expect(find.textContaining('Completed'), findsOneWidget);
    expect(find.text('Not run yet'), findsOneWidget);
  });

  testWidgets('a bad last run shows what went wrong', (tester) async {
    await _openCron(tester, _api());

    expect(find.textContaining('· OK'), findsWidgets);
    expect(find.textContaining('· Failed'), findsOneWidget);
    expect(find.text('Script exited with code 1'), findsOneWidget);
    expect(find.textContaining('· Delivery failed'), findsOneWidget);
    expect(find.text('telegram: 502 Bad Gateway'), findsOneWidget);
  });

  testWidgets('the switch pauses a job and starts it again', (tester) async {
    final api = _api();
    await _openCron(tester, api);

    await tester.tap(_switchOf('daily-news'));
    await tester.pumpAndSettle();
    expect(api.calls, contains('pause:atlas:$_news'));
    expect(tester.widget<Switch>(_switchOf('daily-news')).value, isFalse);
    expect(find.textContaining('Paused'), findsNWidgets(2));

    await tester.tap(_switchOf('daily-news'));
    await tester.pumpAndSettle();
    expect(api.calls, contains('resume:atlas:$_news'));
    expect(tester.widget<Switch>(_switchOf('daily-news')).value, isTrue);
    expect(find.textContaining('Paused'), findsOneWidget);
  });

  testWidgets('run now waits for the run, then shows its result', (
    tester,
  ) async {
    final api = _api()..runGate = Completer<void>();
    await _openCron(tester, api);

    await tester.tap(find.byTooltip('Run daily-news now'));
    await tester.pump();
    expect(api.calls, contains('run:atlas:$_news'));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Nothing else can be done to this job while it runs.
    expect(tester.widget<Switch>(_switchOf('daily-news')).onChanged, isNull);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, CupertinoIcons.trash).first,
          )
          .onPressed,
      isNull,
    );

    api.runGate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('Last run: Jan 20'), findsOneWidget);
    expect(tester.widget<Switch>(_switchOf('daily-news')).onChanged, isNotNull);
  });

  testWidgets('a run outlives a tab change: no second run can start', (
    tester,
  ) async {
    final api = _api()..runGate = Completer<void>();
    await _openCron(tester, api);
    await tester.tap(find.byTooltip('Run daily-news now'));
    await tester.pump();

    // Away and back: the tab, and its list, are built anew.
    await tester.tap(find.text('Skills'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Cron'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final run = find.descendant(
      of: find.byTooltip('Run daily-news now'),
      matching: find.byType(IconButton),
    );
    expect(tester.widget<IconButton>(run).onPressed, isNull);

    api.runGate!.complete();
    await tester.pumpAndSettle();
    expect(api.calls.where((c) => c.startsWith('run:')), hasLength(1));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('Last run: Jan 20'), findsOneWidget);
  });

  testWidgets('a confirmed delete removes the job', (tester) async {
    final api = _api();
    await _openCron(tester, api);

    await tester.tap(find.byTooltip('Delete daily-news'));
    await tester.pumpAndSettle();
    await tester.tap(_inDialog('Delete'));
    await tester.pumpAndSettle();

    expect(api.calls, contains('delete:atlas:$_news'));
    expect(find.text('daily-news'), findsNothing);
    expect(find.text('every-five'), findsOneWidget);
  });

  testWidgets('a failed action says why on the job and changes nothing', (
    tester,
  ) async {
    final api = _api()
      ..cronFailure = const ServerFailure(
        'Job is already running',
        httpStatus: 409,
      );
    await _openCron(tester, api);

    await tester.tap(find.byTooltip('Run daily-news now'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Job is already running'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.widget<Switch>(_switchOf('daily-news')).onChanged, isNotNull);
    expect(find.text('daily-news'), findsOneWidget);

    // The next try clears the message.
    api.cronFailure = null;
    await tester.tap(find.byTooltip('Run daily-news now'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Job is already running'), findsNothing);
  });

  testWidgets('a failed load can be retried', (tester) async {
    final api = _api()..cronListFailure = const NetworkFailure('gateway away');
    await _open(tester, api);
    await tester.tap(find.text('Cron'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load'), findsOneWidget);
    expect(find.text('Cannot reach the gateway'), findsOneWidget);

    api.cronListFailure = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load'), findsNothing);
    expect(find.text('daily-news'), findsOneWidget);
  });

  testWidgets('closing the sheet while a run is going is harmless', (
    tester,
  ) async {
    final api = _api()..runGate = Completer<void>();
    await _openCron(tester, api);
    await tester.tap(find.byTooltip('Run daily-news now'));
    await tester.pump();

    await tester.pumpWidget(const SizedBox());
    api.runGate!.complete();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
