import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../hermes/api/hermes_api.dart';
import '../../../hermes/hermes_failure.dart';
import '../../../hermes/models/bot_cron_job.dart';
import '../../../hermes/models/bot_skill.dart';
import '../../../hermes/models/bot_soul.dart';
import '../../../hermes/models/bot_toolset.dart';
import '../../connection/presentation/connection_providers.dart';
import '../domain/cron_job_activity.dart';

part 'bot_details_providers.g.dart';

/// [api], or a failure the sheet shows with Retry.
HermesApi _connected(HermesApi? api) =>
    api ?? (throw NetworkFailure.notConnected);

HermesApi _gateway(Ref ref) => _connected(ref.watch(hermesApiProvider));

/// Read each time the sheet opens: cheap, and the dashboard may change them.
@riverpod
Future<List<BotSkill>> botSkills(Ref ref, String profile) =>
    _gateway(ref).skills(profile);

@riverpod
Future<List<BotToolset>> botToolsets(Ref ref, String profile) =>
    _gateway(ref).toolsets(profile);

/// `SOUL.md`; invalidated after a save.
@riverpod
Future<BotSoul> botSoul(Ref ref, String profile) => _gateway(ref).soul(profile);

/// A save of [profile]'s `SOUL.md` from the editor: loading while it runs,
/// the failure after one that did not go through.
@riverpod
class SoulSave extends _$SoulSave {
  @override
  AsyncValue<void> build(String profile) => const AsyncData(null);

  /// Writes [text]. The agent, the dashboard or another phone may have
  /// written the file since the editor opened on [base]: then
  /// [confirmReplace] decides. True once the gateway has the text.
  Future<bool> save(
    String text, {
    required String base,
    required Future<bool> Function() confirmReplace,
  }) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    try {
      final api = _connected(ref.read(hermesApiProvider));
      final current = await api.soul(profile);
      if (current.content != base) {
        if (!ref.mounted) return false;
        state = const AsyncData(null);
        if (!await confirmReplace() || !ref.mounted) return false;
        state = const AsyncLoading();
      }
      await api.saveSoul(profile, text);
      if (ref.mounted) state = const AsyncData(null);
      return true;
    } on HermesFailure catch (e, st) {
      if (ref.mounted) state = AsyncError(e, st);
      return false;
    }
  }
}

/// The jobs as the gateway last said; their actions live in [CronJobActions].
@riverpod
class BotCronJobs extends _$BotCronJobs {
  @override
  Future<List<BotCronJob>> build(String profile) =>
      _gateway(ref).cronJobs(profile);

  void replace(BotCronJob job) => _update(
    (jobs) => [
      for (final j in jobs)
        if (j.id == job.id) job else j,
    ],
  );

  void drop(String id) => _update(
    (jobs) => [
      for (final j in jobs)
        if (j.id != id) j,
    ],
  );

  void _update(List<BotCronJob> Function(List<BotCronJob>) change) {
    final jobs = state.value;
    if (jobs != null) state = AsyncData(change(jobs));
  }
}

/// Pause, resume, run now and delete of job [jobId]. Kept alive: a run takes
/// minutes and the tab can close and open meanwhile, and the job stays busy,
/// so no second run starts. The list changes only from the gateway's answer.
@Riverpod(keepAlive: true)
class CronJobActions extends _$CronJobActions {
  @override
  CronJobActivity build(String profile, String jobId) =>
      const CronJobActivity();

  Future<void> setPaused({required bool paused}) =>
      _perform(CronAction.pause, (api) async {
        _replace(
          await (paused
              ? api.pauseCronJob(profile, jobId)
              : api.resumeCronJob(profile, jobId)),
        );
      });

  /// Ends when the run ends.
  Future<void> runNow() => _perform(CronAction.run, (api) async {
    _replace(await api.runCronJob(profile, jobId));
  });

  Future<void> remove() => _perform(CronAction.delete, (api) async {
    await api.deleteCronJob(profile, jobId);
    _list((jobs) => jobs.drop(jobId));
  });

  Future<void> _perform(
    CronAction action,
    Future<void> Function(HermesApi api) act,
  ) async {
    if (!state.idle) return;
    state = CronJobActivity(doing: action);
    try {
      await act(_connected(ref.read(hermesApiProvider)));
      if (ref.mounted) state = const CronJobActivity();
    } on HermesFailure catch (e) {
      if (ref.mounted) state = CronJobActivity(failure: e);
    }
  }

  void _replace(BotCronJob job) => _list((jobs) => jobs.replace(job));

  /// Only a shown list: a closed tab reads it fresh anyway.
  void _list(void Function(BotCronJobs jobs) change) {
    if (!ref.mounted) return;
    final list = botCronJobsProvider(profile);
    if (ref.exists(list)) change(ref.read(list.notifier));
  }
}
