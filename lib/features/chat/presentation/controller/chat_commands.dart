part of '../chat_controller.dart';

/// Slash commands: each runs as a command row that only this phone shows.
mixin _Commands on _$ChatController, _Session, _Outbox, _Conversations {
  /// Runs [command]; the composer has asked first when it confirms.
  Future<void> runSlash(SlashCommand command) async {
    final run = _live;
    if (run == null) return;
    switch (command) {
      case SlashCommand.newConversation:
        await startOver();
      case SlashCommand.compact:
        if (!state.isReady) return;
        await _command(run, command, (_) async {
          final r = await _onSession(run, run.api.compress);
          if (run.live) await _reload(run);
          return (r.text, r.lockHeld);
        });
      case SlashCommand.restart:
        await _command(run, command, (id) async {
          final started = await run.api.restartGateway();
          if (!started.ok) return (started.refusal, true);
          return _follow(
            run,
            id,
            HermesProtocol.actionGatewayRestart,
            HermesTimeouts.gatewayRestart,
          );
        });
      case SlashCommand.update:
        await _command(run, command, (id) async {
          // An install that is current, or one the dashboard cannot update
          // in place, only gets the gateway's message.
          final check = await run.api.checkUpdate();
          if (!check.updateAvailable || !check.canApply) {
            final lines = [
              check.message,
              check.currentVersion,
              if (!check.canApply) check.updateCommand,
            ].where((l) => l.isNotEmpty);
            return (
              lines.join('\n'),
              check.unknown || (check.updateAvailable && !check.canApply),
            );
          }
          final started = await run.api.startUpdate();
          if (!started.ok) return (started.refusal, true);
          return _follow(
            run,
            id,
            HermesProtocol.actionHermesUpdate,
            HermesTimeouts.hermesUpdate,
          );
        });
    }
  }

  Future<void> _command(
    _Run run,
    SlashCommand command,
    Future<(String, bool)> Function(String id) body,
  ) async {
    final id = 'slash-${newId()}';
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          id: id,
          role: ChatRole.system,
          command: command.slash,
          timestamp: DateTime.now().toUtc(),
          delivery: DeliveryState.sending,
        ),
      ],
    );
    try {
      final (text, failed) = await body(id);
      _note(run, id, text, failed ? DeliveryState.failed : DeliveryState.sent);
    } on CancelledFailure {
      if (run.live) deleteNote(id);
    } on HermesFailure catch (e) {
      log.w('${command.slash} failed', error: e);
      _note(run, id, failureTextFor(platformL10n(), e), DeliveryState.failed);
    }
  }

  void _note(_Run run, String id, String text, DeliveryState delivery) {
    if (!run.live) return;
    state = state.copyWith(
      messages: [
        for (final m in state.messages)
          if (m.id == id) m.copyWith(text: text, delivery: delivery) else m,
      ],
    );
  }

  Future<(String, bool)> _follow(
    _Run run,
    String id,
    String name,
    Duration timeout,
  ) async {
    var seen = '';
    try {
      final done = await run.api.awaitAction(
        name,
        timeout: timeout,
        cancelled: () => !run.live,
        onProgress: (s) {
          seen = s.log;
          _note(run, id, s.log, DeliveryState.sending);
        },
      );
      return (done.log, !done.succeeded);
    } on CancelledFailure {
      return (seen, false);
    }
  }

  /// Removes a command row; it exists only on this phone.
  void deleteNote(String id) {
    if (!ref.mounted) return;
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != id).toList(),
    );
  }
}
