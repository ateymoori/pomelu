import 'dart:async';

import '../events/event_payloads.dart';
import '../events/gateway_event.dart';
import '../hermes_constants.dart';

/// What the gateway says about a session outside its transcript, which the
/// app acts on with no chat screen open: notices, background results, and
/// the stored id and bot behind a runtime id (for deep links), and that a
/// session store moved (`sessions.changed`).
class SessionSignals {
  StreamSubscription<GatewayEvent>? _sub;
  final _notices = StreamController<GatewayNotice>.broadcast();
  final _noticeClears = StreamController<String>.broadcast();
  final _backgrounds = StreamController<BackgroundResult>.broadcast();
  final _storeChanges = StreamController<void>.broadcast();
  final Map<String, SessionRef> _refs = {};

  Stream<GatewayNotice> get notices => _notices.stream;

  Stream<String> get noticeClears => _noticeClears.stream;

  Stream<BackgroundResult> get backgrounds => _backgrounds.stream;

  /// Some session was written: by this app, another client, a cron job.
  Stream<void> get storeChanges => _storeChanges.stream;

  /// The stored id and bot of [runtimeId], from `session.info`; the newest
  /// [HermesLimits.sessionRefCache] are kept.
  SessionRef? refFor(String runtimeId) => _refs[runtimeId];

  /// Start folding [events]. Replaces any previous subscription.
  void attach(Stream<GatewayEvent> events) {
    unawaited(_sub?.cancel());
    _sub = events.listen(handle);
  }

  /// Folds one event.
  void handle(GatewayEvent e) {
    switch (e.type) {
      case EventNames.sessionInfo:
        final ref = SessionRef.fromEvent(e);
        if (ref != null) _remember(ref);
      case EventNames.notificationShow:
        final n = GatewayNotice.fromEvent(e);
        if (n != null) _notices.add(n);
      case EventNames.notificationClear:
        final key = GatewayNotice.clearedKey(e);
        if (key != null) _noticeClears.add(key);
      case EventNames.backgroundComplete:
        final r = BackgroundResult.fromEvent(e);
        if (r != null) _backgrounds.add(r);
      case EventNames.sessionsChanged:
        _storeChanges.add(null);
    }
  }

  void _remember(SessionRef ref) {
    final existing = _refs.remove(ref.runtimeId);
    _refs[ref.runtimeId] = existing == null ? ref : existing.merge(ref);
    if (_refs.length > HermesLimits.sessionRefCache) {
      _refs.remove(_refs.keys.first);
    }
  }

  /// Stops folding and closes the streams.
  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    await _notices.close();
    await _noticeClears.close();
    await _backgrounds.close();
    await _storeChanges.close();
  }
}
