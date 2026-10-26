import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/theme/tokens.dart';
import 'package:hermes/features/bot_details/presentation/widgets/bot_details_sheet.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/hermes/models/bot_cron_job.dart';
import 'package:hermes/hermes/models/bot_skill.dart';
import 'package:hermes/hermes/models/bot_toolset.dart';

import '../../support/app_host.dart';
import '../../support/fake_bot_api.dart';
import '../../support/fixtures.dart';

/// A gateway whose `SOUL.md` save waits until [gate] completes.
class SlowSaveApi extends FakeBotApi {
  SlowSaveApi({super.remoteSoul});

  final Completer<void> gate = Completer<void>();

  @override
  Future<void> saveSoul(String profile, String content) async {
    await gate.future;
    return super.saveSoul(profile, content);
  }
}

/// A gateway whose skills list waits until [gate] completes.
class SlowListApi extends FakeBotApi {
  SlowListApi({super.skillList});

  final Completer<void> gate = Completer<void>();

  @override
  Future<List<BotSkill>> skills(String profile) async {
    await gate.future;
    return super.skills(profile);
  }
}

final HermesTokens tokens = HermesTokens.light();

BotCronJob job(String name, {String status = 'ok'}) => BotCronJob.fromJson({
  'id': 'id-$name',
  'name': name,
  'prompt': 'Do it.',
  'schedule': {'kind': 'interval', 'minutes': 5, 'display': 'every 5m'},
  'state': 'scheduled',
  'next_run_at': '2031-01-15T12:05:00+00:00',
  'last_run_at': '2031-01-15T12:00:00+00:00',
  'last_status': status,
  'last_error': 'It broke.',
});

Future<void> open(
  WidgetTester tester,
  FakeBotApi api, {
  String? tab,
  Size window = const Size(800, 1600),
  double textScale = 1,
}) async {
  tester.view.physicalSize = window;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpApp(
    tester,
    const BotDetailsSheet(profile: 'atlas'),
    textScale: textScale,
    overrides: [hermesApiProvider.overrideWithValue(api)],
  );
  await tester.pumpAndSettle();
  if (tab != null) {
    await tester.tap(find.text(tab));
    await tester.pumpAndSettle();
  }
}

FakeBotApi capabilities() => FakeBotApi(
  skillList: fixtureList('skills.json', BotSkill.fromJson),
  toolsetList: fixtureList('toolsets.json', BotToolset.fromJson),
);
