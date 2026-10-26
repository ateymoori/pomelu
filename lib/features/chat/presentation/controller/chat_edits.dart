part of '../chat_controller.dart';

/// How [_Edits.deleteFrom] ended.
enum DeleteOutcome {
  removed,

  /// A turn runs or unsent turns wait: try again later.
  busy,

  /// The row has no durable gateway row yet.
  unsaved,
  failed,
}

mixin _Edits on _$ChatController, _Session, _Outbox, _Conversations {
  /// Deletes the turn of [id] and every turn after it, from the agent's
  /// context too. The gateway only undoes the last turn, so it undoes turn
  /// by turn, reading the history after each step, until the opening row is
  /// gone; only then is it [DeleteOutcome.removed].
  Future<DeleteOutcome> deleteFrom(String id) async {
    final run = _live;
    if (run == null || !state.isReady || run.deleting) {
      return DeleteOutcome.failed;
    }
    if (state.running || state.outbox.isNotEmpty) return DeleteOutcome.busy;
    final opener = await _durableRow(run, id, opens: true);
    if (opener == null) return DeleteOutcome.unsaved;
    if (!run.live) return DeleteOutcome.failed;
    run.deleting = true;
    var gone = false;
    try {
      var left =
          Transcript.turnsFrom(
            state.messages,
            state.messages.indexWhere((m) => m.id == opener.id),
          ) +
          AppConfig.deleteUndoSlack;
      while (true) {
        final rows = await _onSession(run, run.api.history);
        if (!rows.any((r) => r.durableId == opener.rowId)) {
          gone = true;
          break;
        }
        if (left-- <= 0 || await _onSession(run, run.api.undoLastTurn) == 0) {
          break;
        }
      }
      return gone ? DeleteOutcome.removed : DeleteOutcome.failed;
    } on CancelledFailure {
      return DeleteOutcome.failed;
    } on HermesFailure catch (e) {
      log.w('delete from message failed', error: e);
      if (run.live) state = state.copyWith(error: e);
      return DeleteOutcome.failed;
    } finally {
      run.deleting = false;
      if (run.live) {
        // Command rows of the deleted part go with it.
        final since = opener.timestamp;
        if (gone && since != null) {
          state = state.copyWith(
            messages: [
              for (final m in state.messages)
                if (!m.isCommand || (m.timestamp?.isBefore(since) ?? true)) m,
            ],
          );
        }
        await _reload(run);
        unawaited(_drain(run));
      }
    }
  }

  /// Hides [id] on this phone only; the gateway keeps it. Returns the row id
  /// to [show] it again, or null when it has no durable id yet.
  Future<int?> hide(String id) async {
    final run = _live;
    if (run == null || state.running) return null;
    final rowId = (await _durableRow(run, id))?.rowId;
    if (rowId == null || !run.live) return null;
    _setHidden(run, {...state.hidden, rowId});
    return rowId;
  }

  void show(int rowId) {
    if (_live case final run?) {
      _setHidden(run, {...state.hidden}..remove(rowId));
    }
  }

  void showAllHidden() {
    if (_live case final run?) _setHidden(run, const {});
  }

  void _setHidden(_Run run, Set<int> ids) {
    state = state.copyWith(hidden: Set.unmodifiable(ids));
    unawaited(run.store.saveHidden(target.key, ids));
  }

  Future<ChatMessage?> _durableRow(
    _Run run,
    String id, {
    bool opens = false,
  }) async {
    final before = state.messages;
    final at = before.indexWhere((m) => m.id == id);
    final index = at < 0
        ? null
        : (opens ? Transcript.turnStart(before, at) : at);
    if (index == null) return null;
    final row = before[index];
    if (row.rowId != null) return row;
    if (state.running) return null;
    await _reload(run);
    if (!run.live) return null;
    final match = Transcript.matchReloaded(row, before, state.messages);
    return match?.rowId == null ? null : match;
  }
}
