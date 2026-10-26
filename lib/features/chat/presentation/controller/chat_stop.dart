part of '../chat_controller.dart';

/// Stopping the running turn, with a guard for a gateway that never ends it.
mixin _Stop on _$ChatController, _Session {
  /// Stops the running turn. The gateway ends it with `message.complete`;
  /// the guard frees the composer when that never comes.
  Future<void> stop() async {
    final run = _live;
    final runtimeId = state.runtimeId;
    if (run == null || !state.running || runtimeId.isEmpty) return;
    state = state.copyWith(stopRequested: true);
    // Still uploading: the delivery sees the flag and never submits.
    if (run.staging) return;
    run.stopGuard?.cancel();
    run.stopGuard = Timer(AppConfig.interruptGrace, () {
      if (run.live && state.stopRequested) {
        state = state.copyWith(running: false, stopRequested: false);
      }
    });
    try {
      await run.api.interrupt(runtimeId);
    } on HermesFailure catch (e) {
      run.stopGuard?.cancel();
      if (run.live) state = state.copyWith(stopRequested: false, error: e);
    }
  }

  @override
  void _cancelStopGuard(_Run run) {
    run.stopGuard?.cancel();
    run.stopGuard = null;
  }
}
