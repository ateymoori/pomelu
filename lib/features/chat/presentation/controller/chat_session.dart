part of '../chat_controller.dart';

mixin _Session on _$ChatController {
  _Run? _run;

  _Run? get _live => (_run?.live ?? false) ? _run : null;

  Future<void> _drain(_Run run);
  Future<void> _open(_Run run);
  void _reconcile(_Run run);
  void _cancelStopGuard(_Run run);
  void _scheduleFollow(_Run run);

  bool _busy(_Run run) =>
      state.loading ||
      state.running ||
      state.stopRequested ||
      state.queuedCount > 0 ||
      run.draining ||
      run.deleting;

  Future<void> _reopen(_Run run) =>
      run.reopening ??= _reopenOnce(run).whenComplete(() {
        run.reopening = null;
        if (!run.reopenAgain) return;
        run.reopenAgain = false;
        if (run.live) unawaited(_reopen(run));
      });

  Future<void> _reopenOnce(_Run run) async {
    if (!run.live || state.storedId.isEmpty) return;
    final generation = run.generation;
    try {
      final r = await run.api.resumeSession(
        storedId: state.storedId,
        profile: target.profile,
      );
      await _bind(run, r, expected: generation);
    } on HermesFailure catch (e) {
      if (run.live && generation == run.generation) {
        state = state.copyWith(error: e);
      }
    }
  }

  Future<void> _bind(_Run run, SessionResume r, {int? expected}) async {
    if (!run.live || (expected != null && expected != run.generation)) return;
    final generation = ++run.generation;
    bool stale() => !run.live || generation != run.generation;
    final old = state.runtimeId;
    if (old.isNotEmpty && old != r.sessionId) run.client.unwatchSession(old);
    run.client.watchSession(r.sessionId);
    run.watched = r.sessionId;
    run.client.requests.replay(r.sessionId, r.openRequests);
    // Events wait while the transcript loads: applied now, the load would
    // overwrite them. Swapped without a gap, so no event is applied twice.
    final held = run.held = <GatewayEvent>[];
    final previous = run.events;
    run.events = run.client.events.listen((ev) {
      if (identical(run.held, held)) {
        held.add(ev);
      } else {
        _onEvent(run, ev);
      }
    });
    unawaited(previous?.cancel());

    final inline = !(r.messagesOmitted || r.hydrating);
    final idle = !r.running;
    state = state.copyWith(
      runtimeId: r.sessionId,
      storedId: r.storedId,
      running: r.running,
      // A stop pressed during an upload stays: the delivery has to see it.
      stopRequested: (!idle || run.staging) && state.stopRequested,
      thinkingLabel: idle ? '' : state.thinkingLabel,
      statusLine: idle ? '' : state.statusLine,
      model: r.info?.model ?? state.model,
      effort: r.info?.reasoningEffort ?? state.effort,
      provider: r.info?.provider ?? state.provider,
      openingUsage: SessionUsage.fromMap(r.sessionId, r.info?.usage),
      // An idle session's plan is a finished turn's.
      plan: idle ? null : r.todoState,
      messages: inline
          ? Transcript.withCommands(
              Transcript.fromHistory(r.messages),
              state.messages,
            )
          : state.messages,
      error: null,
      historyStale: false,
    );
    if (!inline) {
      try {
        final rows = await _hydratedHistory(run, r, stale);
        if (stale()) return;
        state = state.copyWith(
          messages: Transcript.withCommands(
            Transcript.fromHistory(rows),
            state.messages,
          ),
        );
      } on HermesFailure catch (e) {
        log.w('history load failed', error: e);
        if (stale()) return;
        // Not a blank chat in silence: keep what is shown, read it later.
        state = state.copyWith(error: e, historyStale: true);
      }
    }
    run.seenCount = r.messageCount;
    state = Transcript.restoreInflight(state, r, DateTime.now().toUtc());
    run.held = null;
    for (final ev in held) {
      _onEvent(run, ev);
    }
    if (!run.live) return;
    if (!state.historyStale) _reconcile(run);
    state = state.copyWith(
      messages: Outbox.project(state.messages, state.outbox),
      loading: false,
    );
    unawaited(_drain(run));
  }

  Future<List<SessionMessage>> _hydratedHistory(
    _Run run,
    SessionResume r,
    bool Function() stale,
  ) async {
    final deadline = DateTime.now().add(AppConfig.historyHydrateBudget);
    while (true) {
      final rows = await run.api.history(r.sessionId);
      // The gateway reads the transcript from its database, and leaves some
      // stored rows out: any row read means it is there. Fewer rows than
      // `message_count` can be all there is.
      if (!r.hydrating ||
          rows.isNotEmpty ||
          r.messageCount == 0 ||
          DateTime.now().isAfter(deadline)) {
        return rows;
      }
      await Future<void>.delayed(AppConfig.historyHydratePoll);
      if (stale()) return const [];
    }
  }

  Future<bool> _reload(_Run run, {bool onlyIfChanged = false}) async {
    final runtimeId = state.runtimeId;
    if (!run.live || runtimeId.isEmpty) return false;
    if (onlyIfChanged && _busy(run)) return false;
    try {
      final fresh = Transcript.fromHistory(await run.api.history(runtimeId));
      if (!run.live || state.runtimeId != runtimeId) return false;
      if (state.historyStale) {
        state = state.copyWith(historyStale: false, error: null);
      }
      if (onlyIfChanged) {
        if (_busy(run)) return false;
        if (Transcript.sameConversation(state.messages, fresh)) return true;
      }
      // A reply that started while the history was on the wire stays.
      final live = state.streamingMessage;
      final rows = [
        ...Transcript.withCommands(fresh, state.messages),
        if (live != null && !fresh.any((m) => m.id == live.id)) live,
      ];
      state = state.copyWith(messages: Outbox.project(rows, state.outbox));
      _reconcile(run);
      return true;
    } on HermesFailure catch (e) {
      log.w('history reload failed', error: e);
      return false;
    }
  }

  /// Runs [call] with the bound runtime id, and once more after a resume when
  /// that id went stale. A chat closed meanwhile is a [CancelledFailure].
  Future<T> _onSession<T>(_Run run, Future<T> Function(String id) call) async {
    String id() {
      if (!run.live) throw const CancelledFailure();
      return state.runtimeId;
    }

    try {
      return await call(id());
    } on ServerFailure catch (e) {
      if (e.rpcCode != HermesProtocol.errSessionNotFound &&
          e.rpcCode != HermesProtocol.errSessionGone) {
        rethrow;
      }
      await _reopen(run);
      return call(id());
    }
  }

  void _onConnection(_Run run, HermesConnectionState s) {
    final online = s is Connected;
    if (!run.live || online == state.online) return;
    state = state.copyWith(online: online);
    if (!online) {
      // A dead socket sends no end of turn: a running one is gone from view.
      _cancelStopGuard(run);
      state = state.copyWith(running: false, stopRequested: false);
      return;
    }
    if (state.runtimeId.isEmpty) {
      if (run.opening != null) run.openAgain = true;
      unawaited(_open(run));
    } else if (state.historyStale ||
        state.outbox.any((e) => e.isSubmitted && e.id != run.delivering)) {
      // Resuming also says what the gateway holds of an unanswered turn.
      if (run.reopening != null) run.reopenAgain = true;
      unawaited(_reopen(run));
    } else {
      unawaited(_drain(run));
      // Replies that landed while the socket was down, or a conversation
      // another device started meanwhile.
      _scheduleFollow(run);
    }
  }

  void _onEvent(_Run run, GatewayEvent ev) {
    final rt = state.runtimeId;
    if (!run.live || rt.isEmpty) return;
    switch (ev.type) {
      case EventNames.sessionsChanged:
        _scheduleFollow(run);
      case EventNames.sessionReclaimed:
        if (ev.reclaimedSession == rt) unawaited(_reopen(run));
      case _ when ev.sessionId != rt:
        return;
      case SyntheticEvents.sessionLost:
        unawaited(_reopen(run));
      case SyntheticEvents.replayTruncated:
        unawaited(_reload(run));
      case EventNames.sessionResumeProgress:
        if (ev.resumeDone) unawaited(_reload(run));
      default:
        final wasRunning = state.running;
        state = ChatReducer.apply(state, ev, DateTime.now().toUtc());
        if (state.running) return;
        _cancelStopGuard(run);
        // A turn typed while this one ran goes out now.
        if (wasRunning) unawaited(_drain(run));
    }
  }
}
