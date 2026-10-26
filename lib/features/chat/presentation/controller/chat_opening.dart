part of '../chat_controller.dart';

/// Opens the bot's one chat once the gateway is up: the session titled
/// [HermesProtocol.botChatTitle], made when the bot has none.
mixin _Opening on _$ChatController, _Session {
  @override
  Future<void> _open(_Run run) =>
      run.opening ??= _openOnce(run).whenComplete(() {
        run.opening = null;
        if (!run.openAgain) return;
        run.openAgain = false;
        if (!run.live || state.runtimeId.isNotEmpty) return;
        state = state.copyWith(error: null, loading: true);
        unawaited(_open(run));
      });

  Future<void> _openOnce(_Run run) async {
    try {
      if (!run.client.isConnected) {
        final up = await run.client.states
            .firstWhere(
              (s) => s is Connected,
              orElse: () => const Disconnected(),
            )
            .timeout(HermesTimeouts.wsConnect);
        if (up is! Connected) throw NetworkFailure.notConnected;
      }
      if (!run.live) return;
      final generation = run.generation;
      await _bind(run, await _openBotChat(run), expected: generation);
    } on HermesFailure catch (e) {
      _openFailed(run, e);
    } on TimeoutException {
      _openFailed(run, NetworkFailure.notConnected);
    } on Object catch (e, st) {
      // A bug must not leave the chat loading for ever.
      log.e('opening the chat failed', error: e, stackTrace: st);
      _openFailed(run, ProtocolFailure('opening the chat failed', cause: e));
    }
  }

  void _openFailed(_Run run, HermesFailure e) {
    if (run.live) state = state.copyWith(loading: false, error: e);
  }

  Future<SessionResume> _openBotChat(_Run run) async {
    const title = HermesProtocol.botChatTitle;
    final profile = target.profile;
    Future<SessionResume> resume(SessionSummary s) =>
        run.api.resumeSession(storedId: s.openId, profile: profile);
    final existing = await run.api.findByTitle(profile, title);
    if (existing != null) return resume(existing);
    final created = await run.api.createSession(
      profile: profile,
      title: title,
      hidden: true,
      followProfileConfig: true,
    );
    try {
      await run.api.setTitle(created.sessionId, title);
    } on TitleInUseFailure {
      // Another writer claimed the title: adopt the winner.
      final winner = await run.api.findByTitle(profile, title);
      if (winner != null) return resume(winner);
      rethrow;
    }
    return created;
  }
}
