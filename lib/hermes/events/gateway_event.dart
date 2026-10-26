import '../models/json_converters.dart';

/// One server notification. `method` is always `"event"` on the wire; the
/// real name is [type]. [payload] is null when the emitter sent none
/// (e.g. `message.start`). Session-less events have an empty [sessionId]
/// and no [seq].
class GatewayEvent {
  const GatewayEvent({
    required this.type,
    required this.sessionId,
    this.seq,
    this.payload,
  });
  final String type;
  final String sessionId;
  final int? seq;
  final Map<String, dynamic>? payload;

  /// Reads the `params` of an `event` notification; null without a type.
  static GatewayEvent? fromParams(Map<String, dynamic> params) {
    final type = params['type'];
    if (type is! String || type.isEmpty) return null;
    final p = params['payload'];
    return GatewayEvent(
      type: type,
      sessionId: const LooseString().fromJson(params['session_id']),
      seq: const LooseIntOrNull().fromJson(params['seq']),
      payload: p is Map<String, dynamic> ? p : null,
    );
  }

  bool get isSessionScoped => sessionId.isNotEmpty;

  /// Payload field [key] as a string; empty when absent.
  String text([String key = 'text']) =>
      const LooseString().fromJson(payload?[key]);

  /// Payload field [key] as a loose boolean; false when absent.
  bool flag(String key) => const LooseBool().fromJson(payload?[key]);

  /// Raw payload field [key].
  Object? operator [](String key) => payload?[key];

  @override
  String toString() => 'GatewayEvent($type, $sessionId, seq: $seq)';
}

/// Event names the client reacts to. Open union: unknown types are ignored.
abstract final class EventNames {
  static const String gatewayReady = 'gateway.ready';
  static const String messageStart = 'message.start';
  static const String messageDelta = 'message.delta';
  static const String messageInterim = 'message.interim';
  static const String messageComplete = 'message.complete';
  static const String reasoningDelta = 'reasoning.delta';
  static const String reasoningAvailable = 'reasoning.available';
  static const String thinkingDelta = 'thinking.delta';
  static const String toolGenerating = 'tool.generating';
  static const String toolStart = 'tool.start';
  static const String toolProgress = 'tool.progress';
  static const String toolComplete = 'tool.complete';
  static const String statusUpdate = 'status.update';

  /// The agent's whole plan after its `todo` tool ran (`{todos, revision}`).
  static const String todoUpdated = 'todo.updated';
  static const String sessionInfo = 'session.info';
  static const String sessionUsage = 'session.usage';
  static const String sessionResumeProgress = 'session.resume_progress';
  static const String sessionReclaimed = 'session.reclaimed';
  static const String sessionsChanged = 'sessions.changed';
  static const String error = 'error';

  /// The backend withdrew an open server → client request (`{id, method,
  /// reason}`): timeout, interrupt, session closed, or another surface answered.
  static const String requestCancel = 'request.cancel';
  static const String notificationShow = 'notification.show';
  static const String notificationClear = 'notification.clear';
  static const String backgroundComplete = 'background.complete';

  /// A bot's screen started or stopped (a full status), or its control
  /// changed hands (`{profile_key, lease}`). Every client gets them, for
  /// every bot of the gateway process.
  static const String displayStatus = 'display.status';
  static const String displayLease = 'display.lease';
}

/// `message.complete.status` values.
abstract final class TurnStatus {
  static const String complete = 'complete';
  static const String interrupted = 'interrupted';
  static const String error = 'error';
}

/// Client-generated events (never on the wire) so features learn about
/// reconnect outcomes through the same stream.
abstract final class SyntheticEvents {
  /// The gateway could not replay everything missed (or the replay epoch
  /// changed): the session's transcript must be reloaded.
  static const String replayTruncated = 'x.replay_truncated';

  /// `session.activate` failed after a reconnect: the live session is gone.
  /// The payload carries the error's `code` and `message`.
  static const String sessionLost = 'x.session_lost';
}
