part of 'hermes_api.dart';

/// The dashboard's own REST routes: a bot's details (skills, tools,
/// `SOUL.md`, cron jobs) and the gateway actions (restart, update). A
/// gateway without a route answers 404, thrown as a [NotSupportedFailure];
/// a 404 for one job is a [ServerFailure] (that job is gone).
mixin _DashboardRoutes {
  HermesClient get _client;

  List<T> _rows<T>(
    Object? raw,
    T Function(Map<String, dynamic>) fromJson,
    String what, [
    bool Function(T)? keep,
  ]);

  Future<List<Map<String, dynamic>>> _list(
    String what,
    String path,
    String profile,
  ) => _optionalRoute(
    what,
    () => _client.http.jsonList(path, query: {'profile': profile}),
  );

  /// A bot's skills (read only).
  Future<List<BotSkill>> skills(String profile) async => _rows(
    await _list('skills', HermesPaths.skills, profile),
    BotSkill.fromJson,
    'skill',
    (s) => s.name.isNotEmpty,
  );

  /// A bot's toolsets with their tools (read only).
  Future<List<BotToolset>> toolsets(String profile) async => _rows(
    await _list('toolsets', HermesPaths.toolsets, profile),
    BotToolset.fromJson,
    'toolset',
    (t) => t.name.isNotEmpty,
  );

  /// A bot's `SOUL.md`.
  Future<BotSoul> soul(String profile) async => parseObject(
    await _optionalRoute(
      'bot instructions',
      () => _client.http.json('GET', HermesPaths.profileSoul(profile)),
    ),
    BotSoul.fromJson,
    what: 'bot instructions',
  );

  /// Replaces a bot's `SOUL.md` (written atomically; new sessions read it).
  Future<void> saveSoul(String profile, String content) => _optionalRoute(
    'bot instructions',
    () => _client.http.json(
      'PUT',
      HermesPaths.profileSoul(profile),
      body: {'content': content},
    ),
  );

  /// A bot's scheduled jobs.
  Future<List<BotCronJob>> cronJobs(String profile) async => _rows(
    await _list('cron jobs', HermesPaths.cronJobs, profile),
    BotCronJob.fromJson,
    'cron job',
    (j) => j.id.isNotEmpty,
  );

  /// Pauses a job; returns it as it is now.
  Future<BotCronJob> pauseCronJob(String profile, String id) =>
      _cronAction(profile, id, 'pause');

  /// Starts a paused job again.
  Future<BotCronJob> resumeCronJob(String profile, String id) =>
      _cronAction(profile, id, 'resume');

  /// Runs a job now; the gateway answers when the run ends.
  Future<BotCronJob> runCronJob(String profile, String id) =>
      _cronAction(profile, id, 'trigger', HermesTimeouts.cronRun);

  /// Removes a job for good.
  Future<void> deleteCronJob(String profile, String id) => _client.http.send(
    'DELETE',
    HermesPaths.cronJob(id),
    query: {'profile': profile},
  );

  Future<BotCronJob> _cronAction(
    String profile,
    String id,
    String action, [
    Duration? timeout,
  ]) async => parseObject(
    await _client.http.json(
      'POST',
      HermesPaths.cronJob(id, action),
      body: const {},
      query: {'profile': profile},
      timeout: timeout,
    ),
    BotCronJob.fromJson,
    what: 'cron job',
  );

  Future<T> _post<T>(
    String what,
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async => parseObject(
    await _optionalRoute(
      what,
      () => _client.http.json('POST', path, body: const {}),
    ),
    fromJson,
    what: what,
  );

  /// Starts a gateway restart; follow it with [awaitAction].
  Future<GatewayAction> restartGateway() => _post(
    'gateway restart',
    HermesPaths.gatewayRestart,
    GatewayAction.fromJson,
  );

  /// Starts `hermes update`; [GatewayAction.ok] is false when the install
  /// cannot be updated in place. Follow it with [awaitAction].
  Future<GatewayAction> startUpdate() =>
      _post('update', HermesPaths.hermesUpdate, GatewayAction.fromJson);

  /// Whether an update is available; [force] skips the gateway's cache.
  Future<UpdateCheck> checkUpdate({bool force = true}) async => parseObject(
    await _optionalRoute(
      'update check',
      () => _client.http.json(
        'GET',
        HermesPaths.hermesUpdateCheck,
        query: {if (force) 'force': 'true'},
      ),
    ),
    UpdateCheck.fromJson,
    what: 'update check',
  );

  /// One poll of a background action.
  Future<ActionStatus> actionStatus(String name) async => parseObject(
    await _client.http.json(
      'GET',
      HermesPaths.actionStatus(name),
      query: {'lines': '${HermesLimits.actionLogLines}'},
    ),
    ActionStatus.fromJson,
    what: 'action status',
  );

  /// Polls [actionStatus] until the action [name] finished, reporting each
  /// poll to [onProgress].
  ///
  /// The action may restart the dashboard itself, so a failed poll is
  /// skipped (and logged), up to [HermesLimits.actionPollMaxFailures] in a
  /// row. Failures that waiting cannot cure (forbidden, no such route or
  /// action, a malformed answer) end the wait at once. "Not running" with
  /// no exit code [HermesLimits.actionNoResultPolls] times in a row is an
  /// [OutcomeUnknownFailure]: the action is lost. [cancelled] true ends it
  /// with a [CancelledFailure]; [timeout] with a [NetworkFailure].
  Future<ActionStatus> awaitAction(
    String name, {
    required Duration timeout,
    void Function(ActionStatus status)? onProgress,
    Future<void> Function(Duration) wait = Future.delayed,
    bool Function()? cancelled,
  }) async {
    final waited = Stopwatch()..start();
    var failures = 0;
    var noResult = 0;
    while (true) {
      if (cancelled?.call() ?? false) throw const CancelledFailure();
      ActionStatus? status;
      try {
        status = await actionStatus(name);
        failures = 0;
      } on HermesFailure catch (e) {
        final hopeless =
            e is ForbiddenFailure ||
            e is ProtocolFailure ||
            e is CancelledFailure ||
            (e is ServerFailure && e.httpStatus == HermesHttpStatus.notFound);
        if (hopeless || ++failures >= HermesLimits.actionPollMaxFailures) {
          rethrow;
        }
        _client.log('skipped a poll of $name', e);
      }
      if (status != null) {
        onProgress?.call(status);
        if (status.finished) return status;
        noResult = status.running ? 0 : noResult + 1;
        if (noResult >= HermesLimits.actionNoResultPolls) {
          throw OutcomeUnknownFailure('$name: no process and no result');
        }
      }
      if (waited.elapsed >= timeout) {
        throw NetworkFailure(
          '$name did not finish in ${timeout.inMinutes} min',
        );
      }
      await wait(HermesTimeouts.actionPoll);
    }
  }
}
