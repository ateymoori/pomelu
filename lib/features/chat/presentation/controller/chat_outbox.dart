part of '../chat_controller.dart';

mixin _Outbox on _$ChatController, _Session {
  /// Accepts a turn; offline it waits for the next connection. False when it
  /// was not taken: empty, a full queue, or no gateway.
  Future<bool> send(
    String text, {
    List<LocalAttachment> attachments = const [],
  }) async {
    final run = _live;
    final entry = OutboxEntry(
      id: 'user-${newId()}',
      createdAt: DateTime.now().toUtc(),
      text: text.trim(),
      attachments: List.unmodifiable(attachments),
    );
    if (run == null || entry.isEmpty || isQueueFull()) return false;
    state = state.copyWith(error: null);
    _commit(run, Outbox.enqueue(state.outbox, entry));
    // The bots written to most lead the share sheet's top row.
    unawaited(ref.read(appShortcutsProvider).used(target.profile));
    await _drain(run);
    return true;
  }

  bool isQueueFull() => ref.mounted && state.outbox.length >= Outbox.maxEntries;

  /// Queued or failed, and not the one going out right now. A turn sending,
  /// or sent and unconfirmed, is out of the user's hands.
  bool canAmend(String id) =>
      _live != null &&
      _run!.delivering != id &&
      (Outbox.find(state.outbox, id)?.isAmendable ?? false);

  /// Text of an unsent turn, for the edit sheet.
  String draftOf(String id) =>
      ref.mounted ? Outbox.find(state.outbox, id)?.text ?? '' : '';

  /// The manual "try again" of a failed turn. False when it went out meanwhile.
  Future<bool> retry(String id) => _amend(id, Outbox.fresh);

  /// Same slot, new words, fresh budget. Empty words with no files discard.
  Future<bool> editAndResend(String id, String text) {
    final entry = Outbox.find(state.outbox, id);
    if (text.trim().isEmpty && (entry?.attachments.isEmpty ?? true)) {
      return discard(id);
    }
    return _amend(id, (e) => Outbox.fresh(e, text: text.trim()));
  }

  Future<bool> _amend(String id, OutboxEntry Function(OutboxEntry) f) async {
    if (!canAmend(id)) return false;
    final run = _run!;
    _commit(run, Outbox.update(state.outbox, id, f));
    await _drain(run);
    return true;
  }

  /// The only way an unsent turn disappears: the user said so.
  Future<bool> discard(String id) async {
    if (!canAmend(id)) return false;
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != id).toList(),
    );
    _commit(_run!, Outbox.remove(state.outbox, id));
    return true;
  }

  void _commit(_Run run, List<OutboxEntry> queue) {
    unawaited(run.store.saveOutbox(target.key, queue));
    if (!run.live) return;
    state = state.copyWith(
      outbox: queue,
      messages: Outbox.project(state.messages, queue),
    );
  }

  void _settle(_Run run, List<OutboxEntry> Function(List<OutboxEntry>) change) {
    if (run.live) return _commit(run, change(state.outbox));
    final key = target.key;
    unawaited(run.store.saveOutbox(key, change(run.store.outbox(key))));
  }

  bool _canSend(_Run run) =>
      run.live && state.canDeliver && !run.deleting && !state.running;

  @override
  Future<void> _drain(_Run run) async {
    if (!run.live) return;
    // A drain asked for while one runs makes it go round once more: the
    // connection may have come back meanwhile.
    if (run.draining) {
      run.drainAgain = true;
      return;
    }
    run.draining = true;
    try {
      do {
        run.drainAgain = false;
        while (_canSend(run)) {
          final next = Outbox.next(state.outbox);
          if (next == null || !await _deliver(run, next)) break;
        }
      } while (run.drainAgain && _canSend(run));
    } finally {
      run.draining = false;
    }
  }

  Future<bool> _deliver(_Run run, OutboxEntry entry) async {
    final id = entry.id;
    run.delivering = id;
    _commit(run, Outbox.update(state.outbox, id, Outbox.sending));
    state = state.copyWith(running: true, error: null, stopRequested: false);
    var submitted = false;
    void done() {
      if (run.live) state = state.copyWith(upload: null, running: false);
    }

    try {
      run.staging = true;
      final total = entry.attachments.length;
      final refs = await _onSession(
        run,
        (rt) => Attachments.stage(
          run.api,
          rt,
          entry.attachments,
          onProgress: (i, name) {
            if (run.live) {
              state = state.copyWith(
                upload: (done: i, total: total, name: name),
              );
            }
          },
        ),
      );
      run.staging = false;
      if (!run.live) return false;
      // Stop pressed during the upload: nothing reached the agent.
      if (state.stopRequested) {
        state = state.copyWith(stopRequested: false);
        done();
        _commit(
          run,
          Outbox.update(
            state.outbox,
            id,
            (e) => Outbox.failed(e, OutboxFailure.stopped),
          ),
        );
        return false;
      }
      final words = [...refs, if (entry.text.isNotEmpty) entry.text];
      final prompt = words.isNotEmpty
          ? words.join('\n\n')
          : (entry.attachments.any((a) => a.isImage)
                ? AppConfig.imageOnlyPrompt
                : '');
      // From here the agent may act without us ever hearing: written down
      // first, so a kill leaves it for settling.
      _commit(
        run,
        Outbox.update(
          state.outbox,
          id,
          (e) => e.copyWith(status: OutboxStatus.submitted, sentText: prompt),
        ),
      );
      submitted = true;
      await _onSession(
        run,
        (rt) => run.api.submitPrompt(
          runtimeId: rt,
          profile: target.profile,
          text: prompt,
        ),
      );
      // Acknowledged, even if the chat closed meanwhile.
      _settle(run, (q) => Outbox.remove(q, id));
      if (run.live) state = state.copyWith(upload: null);
      return run.live;
    } on OutcomeUnknownFailure catch (e) {
      if (!submitted) return _requeue(run, id, e, done);
      // The frame went out and nothing came back: ask the gateway first.
      log.w('prompt.submit outcome unknown', error: e);
      done();
      if (run.live && state.online) unawaited(_reopen(run));
      return false;
    } on NetworkFailure catch (e) {
      return _requeue(run, id, e, done);
    } on CancelledFailure {
      // Closed mid-delivery: the next open requeues or settles the entry.
      return false;
    } on HermesFailure catch (e) {
      log.w('the gateway refused a turn', error: e);
      _settle(
        run,
        (q) => Outbox.update(
          q,
          id,
          (x) => Outbox.failed(x, OutboxFailure.refused),
        ),
      );
      done();
      // The banner says why; "Not sent" alone leaves the user guessing.
      if (run.live) state = state.copyWith(error: e);
      return true;
    } on Object catch (e, st) {
      // A file that cannot be read, say: never left marked as going out.
      log.e('delivering a turn failed', error: e, stackTrace: st);
      _settle(
        run,
        (q) =>
            Outbox.update(q, id, (x) => Outbox.failed(x, OutboxFailure.local)),
      );
      done();
      return true;
    } finally {
      run.delivering = null;
      run.staging = false;
    }
  }

  bool _requeue(_Run run, String id, NetworkFailure e, void Function() done) {
    log.d('a turn waits for the connection: ${e.message}');
    _settle(run, (q) => Outbox.update(q, id, Outbox.requeued));
    done();
    return false;
  }

  @override
  void _reconcile(_Run run) {
    final waiting = [
      for (final e in state.outbox)
        if (e.isSubmitted && e.id != run.delivering) e,
    ];
    if (waiting.isEmpty) return;
    final queued = {for (final e in state.outbox) e.id};
    final delivered = Outbox.delivered(waiting, [
      for (final m in state.messages)
        if (m.isUser && !queued.contains(m.id)) m,
    ]);
    var q = state.outbox;
    for (final e in waiting) {
      q = delivered.contains(e.id)
          ? Outbox.remove(q, e.id)
          : Outbox.update(
              q,
              e.id,
              (x) => Outbox.failed(x, OutboxFailure.unconfirmed),
            );
    }
    // The transcript holds their real rows already.
    state = state.copyWith(
      messages: state.messages.where((m) => !delivered.contains(m.id)).toList(),
    );
    _commit(run, q);
  }
}
