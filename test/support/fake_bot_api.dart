import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/api/hermes_api.dart';
import 'package:hermes/hermes/models/bot_cron_job.dart';
import 'package:hermes/hermes/models/bot_skill.dart';
import 'package:hermes/hermes/models/bot_soul.dart';
import 'package:hermes/hermes/models/bot_toolset.dart';
import 'package:hermes/hermes/models/profile.dart';

import 'throwing.dart';

/// The routes behind the bot details sheet: skills, toolsets, `SOUL.md`,
/// cron jobs, and the bots themselves (create, name, picture, delete). It does what the routes do and logs each call in
/// [calls] (`skills:<profile>`, `pause:<profile>:<id>`, ...).
class FakeBotApi extends Fake implements HermesApi {
  FakeBotApi({
    this.skillList = const [],
    this.toolsetList = const [],
    this.remoteSoul = const BotSoul(),
    List<BotCronJob> jobs = const [],
    List<HermesProfile> bots = const [],
  }) : jobs = [...jobs],
       bots = [...bots];

  /// The bots on the gateway; create, name and delete change them.
  final List<HermesProfile> bots;

  /// Thrown by the bot changes, when set.
  Object? botFailure;

  /// Every call, in order.
  final List<String> calls = [];

  /// Served by `skills`.
  List<BotSkill> skillList;

  /// Served by `toolsets`.
  List<BotToolset> toolsetList;

  /// Thrown by `skills` and `toolsets`, when set.
  Object? capabilitiesFailure;

  /// The `SOUL.md` on the gateway; a save replaces it.
  BotSoul remoteSoul;

  /// Holds a `soul` read until it completes.
  Completer<void>? soulGate;

  /// Thrown by `saveSoul`, when set.
  Object? saveFailure;

  /// Every content saved, in order.
  final List<String> saved = [];

  /// The cron jobs on the gateway; actions change them in place.
  final List<BotCronJob> jobs;

  /// Thrown by every cron action, when set.
  Object? cronFailure;

  /// Thrown when the cron list is asked for, when set.
  Object? cronListFailure;

  /// Holds a cron run until it completes.
  Completer<void>? runGate;

  @override
  Future<List<BotSkill>> skills(String profile) async {
    calls.add('skills:$profile');
    if (capabilitiesFailure != null) throwInjected(capabilitiesFailure!);
    return skillList;
  }

  @override
  Future<List<BotToolset>> toolsets(String profile) async {
    calls.add('toolsets:$profile');
    if (capabilitiesFailure != null) throwInjected(capabilitiesFailure!);
    return toolsetList;
  }

  @override
  Future<BotSoul> soul(String profile) async {
    calls.add('soul:$profile');
    await soulGate?.future;
    return remoteSoul;
  }

  @override
  Future<void> saveSoul(String profile, String content) async {
    calls.add('saveSoul:$profile');
    if (saveFailure != null) throwInjected(saveFailure!);
    saved.add(content);
    remoteSoul = BotSoul(content: content, exists: true);
  }

  @override
  Future<List<BotCronJob>> cronJobs(String profile) async {
    calls.add('list:$profile');
    if (cronListFailure != null) throwInjected(cronListFailure!);
    return [...jobs];
  }

  BotCronJob _change(String id, BotCronJob Function(BotCronJob) change) {
    final i = jobs.indexWhere((j) => j.id == id);
    return jobs[i] = change(jobs[i]);
  }

  @override
  Future<BotCronJob> pauseCronJob(String profile, String id) async {
    calls.add('pause:$profile:$id');
    if (cronFailure != null) throwInjected(cronFailure!);
    return _change(id, (j) => j.copyWith(state: 'paused'));
  }

  @override
  Future<BotCronJob> resumeCronJob(String profile, String id) async {
    calls.add('resume:$profile:$id');
    if (cronFailure != null) throwInjected(cronFailure!);
    return _change(id, (j) => j.copyWith(state: 'scheduled'));
  }

  @override
  Future<BotCronJob> runCronJob(String profile, String id) async {
    calls.add('run:$profile:$id');
    await runGate?.future;
    if (cronFailure != null) throwInjected(cronFailure!);
    return _change(
      id,
      (j) => j.copyWith(
        lastRunAt: DateTime.utc(2031, 1, 20, 12),
        lastStatus: 'ok',
        lastError: '',
      ),
    );
  }

  @override
  Future<void> deleteCronJob(String profile, String id) async {
    calls.add('delete:$profile:$id');
    if (cronFailure != null) throwInjected(cronFailure!);
    jobs.removeWhere((j) => j.id == id);
  }

  @override
  Future<List<HermesProfile>> listProfiles() async => [...bots];

  @override
  Future<void> createProfile(String name) async {
    calls.add('create:$name');
    if (botFailure != null) throwInjected(botFailure!);
    bots.add(HermesProfile(name: name));
  }

  @override
  Future<void> setBotTitle(String name, String title) async {
    calls.add('title:$name:$title');
    if (botFailure != null) throwInjected(botFailure!);
    final i = bots.indexWhere((b) => b.name == name);
    bots[i] = bots[i].copyWith(
      uiMeta: {
        'hermes-bots': {'title': title},
      },
    );
  }

  @override
  Future<void> setAvatar(String name, String? dataUrl) async {
    calls.add('avatar:$name:${dataUrl == null ? 'clear' : 'set'}');
    if (botFailure != null) throwInjected(botFailure!);
  }

  @override
  Future<void> deleteProfile(String name) async {
    calls.add('deleteBot:$name');
    if (botFailure != null) throwInjected(botFailure!);
    bots.removeWhere((b) => b.name == name);
  }
}
