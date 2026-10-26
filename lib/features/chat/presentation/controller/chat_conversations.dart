part of '../chat_controller.dart';

mixin _Conversations on _$ChatController, _Session, _Outbox, _Stop {
  Future<SessionSummary> _stored(_Run run, String id) =>
      run.api.storedSession(storedId: id, profile: target.profile);

  Future<String?> _previous(_Run run, String storedId) async {
    var row = await _stored(run, storedId);
    for (var hop = 0; hop < AppConfig.conversationWalkLimit; hop++) {
      final parent = row.parentSessionId ?? '';
      if (parent.isEmpty) return _movedAsideBefore(run, row.startedAt);
      row = await _stored(run, parent);
      if (row.endReason != HermesProtocol.compressionEndReason) return row.id;
    }
    return null;
  }

  /// The newest Bot Chat of this bot the gateway moved aside before
  /// [before]: no link leads back to it, yet it is this chat's history.
  Future<String?> _movedAsideBefore(_Run run, DateTime? before) async {
    if (before == null) return null;
    final rows = <SessionSummary>[];
    for (var page = 0; page < AppConfig.movedAsidePages; page++) {
      final batch = await run.api.appSessions(
        profile: target.profile,
        offset: rows.length,
      );
      rows.addAll(batch);
      if (batch.length < HermesLimits.sessionListPage) break;
    }
    final aside = [
      for (final r in rows)
        if (r.title.startsWith(HermesProtocol.movedAsidePrefix) &&
            (r.startedAt?.isBefore(before) ?? false))
          r,
    ]..sort((a, b) => b.startedAt!.compareTo(a.startedAt!));
    return aside.firstOrNull?.id;
  }

  Future<bool> _isCompactionOf(
    _Run run,
    String storedId,
    String ancestor,
  ) async {
    var row = await _stored(run, storedId);
    for (var hop = 0; hop < AppConfig.conversationWalkLimit; hop++) {
      final parent = row.parentSessionId ?? '';
      if (parent.isEmpty) return false;
      row = await _stored(run, parent);
      if (row.endReason != HermesProtocol.compressionEndReason) return false;
      if (row.id == ancestor) return true;
    }
    return false;
  }

  /// Loads the conversation before the oldest one on screen. Scrolling asks
  /// on every frame near the top, so it joins the load running.
  Future<void> loadEarlier() async {
    final run = _live;
    if (run == null) return;
    return run.loadingEarlier ??= _loadEarlier(run)
        .whenComplete(() => run.loadingEarlier = null);
  }

  Future<void> _loadEarlier(_Run run) async {
    final failedAt = run.earlierFailedAt;
    if (state.earlierDone ||
        (failedAt != null &&
            DateTime.now().difference(failedAt) <
                AppConfig.earlierRetryAfter)) {
      return;
    }
    final from = state.earlierCursor.isNotEmpty
        ? state.earlierCursor
        : state.storedId;
    if (from.isEmpty) return;
    try {
      final previous = await _previous(run, from);
      if (!run.live) return;
      if (previous == null) {
        state = state.copyWith(earlierDone: true);
        return;
      }
      final rows = await run.api.storedMessages(
        storedId: previous,
        profile: target.profile,
      );
      if (!run.live) return;
      run.earlierFailedAt = null;
      state = state.copyWith(
        earlier: [
          ...Transcript.asEarlier(previous, Transcript.fromHistory(rows)),
          ...state.earlier,
        ],
        earlierCursor: previous,
      );
    } on HermesFailure catch (e) {
      log.w('earlier conversation load failed', error: e);
      run.earlierFailedAt = DateTime.now();
    }
  }

  /// A new conversation (`+`, `/new`, `/reset`, `/clear`): what is on screen
  /// moves above a "New conversation" line. A double tap makes one.
  Future<void> startOver() async {
    final run = _live;
    if (run == null) return;
    return run.startingOver ??= _startOver(run)
        .whenComplete(() => run.startingOver = null);
  }

  Future<void> _startOver(_Run run) async {
    if (!state.isReady) return;
    if (state.running) await stop();
    if (!run.live) return;
    // Unanswered turns belong to the conversation that ends: settle them
    // against it, not against the empty new one.
    if (state.outbox.any((e) => e.isSubmitted)) {
      await _reload(run);
      if (!run.live) return;
      _reconcile(run);
    }
    final before = state;
    state = state.copyWith(
      earlier: [
        ...state.earlier,
        ...Transcript.asEarlier(state.storedId, state.messages),
      ],
      messages: const [],
      earlierCursor: state.earlierCursor.isEmpty
          ? state.storedId
          : state.earlierCursor,
      loading: true,
    );
    try {
      final created = await _startNext(run, before.runtimeId, before.storedId);
      await _bind(run, created);
    } on HermesFailure catch (e) {
      if (run.live) state = before.copyWith(error: e);
    }
  }

  Future<SessionResume> _startNext(
    _Run run,
    String runtimeId,
    String storedId,
  ) async {
    final api = run.api;
    final profile = target.profile;
    final created = await api.createSession(
      profile: profile,
      title: HermesProtocol.botChatTitle,
      hidden: true,
      followProfileConfig: true,
      parentSessionId: storedId,
    );
    var archived = false;
    try {
      await api.archiveSession(sessionId: runtimeId, profile: profile);
      archived = true;
      await api.setTitle(created.sessionId, HermesProtocol.botChatTitle);
      return created;
    } on HermesFailure {
      try {
        await api.archiveSession(
          sessionId: created.sessionId,
          profile: profile,
        );
      } on HermesFailure catch (e) {
        log.w('a stray session was left behind', error: e);
      }
      if (archived) {
        try {
          await api.archiveSession(
            sessionId: runtimeId,
            profile: profile,
            archived: false,
          );
        } on HermesFailure catch (e) {
          log.e('the old Bot Chat could not be put back', error: e);
          rethrow;
        }
      }
      rethrow;
    }
  }

  @override
  void _scheduleFollow(_Run run) {
    run.follow?.cancel();
    run.follow = Timer(
      AppConfig.transcriptFollowDelay,
      () => unawaited(_followChanges(run)),
    );
  }

  Future<void> _followChanges(_Run run) async {
    if (!run.live || _busy(run)) return;
    SessionSummary? current;
    try {
      current = await run.api.findByTitle(
        target.profile,
        HermesProtocol.botChatTitle,
      );
    } on HermesFailure catch (e) {
      log.w('bot chat lookup failed', error: e);
    }
    if (!run.live || _busy(run)) return;
    final elsewhere =
        current != null &&
        current.openId != state.storedId &&
        current.id != state.storedId;
    if (elsewhere && await _followNewConversation(run, current.openId)) return;
    final count = current?.messageCount ?? 0;
    if (!elsewhere && count > 0 && count == run.seenCount) return;
    if (await _reload(run, onlyIfChanged: true) && run.live && count > 0) {
      run.seenCount = count;
    }
  }

  Future<bool> _followNewConversation(_Run run, String id) async {
    final generation = run.generation;
    try {
      if (await _isCompactionOf(run, id, state.storedId)) return false;
      if (!run.live || _busy(run)) return false;
      final r = await run.api.resumeSession(
        storedId: id,
        profile: target.profile,
      );
      if (!run.live || generation != run.generation) return false;
      state = state.copyWith(
        earlier: const [],
        earlierCursor: '',
        earlierDone: false,
      );
      await _bind(run, r, expected: generation);
      return true;
    } on HermesFailure catch (e) {
      log.w('new conversation from another device failed', error: e);
      return false;
    }
  }
}
