part of 'hermes_client.dart';

/// Turns gateway frames into [HermesClient.events]: drops repeats by
/// per-session `seq`, and after every `gateway.ready` replays what the
/// watched sessions missed and rebinds them to the new socket. Live frames
/// of a session wait while it replays, so none overtakes the replay.
class _Replay {
  _Replay(this._c);

  final HermesClient _c;

  WebSocketTransport get _transport => _c._transport;

  /// `last_seen` no session reaches: the gateway replays nothing and only
  /// reports `latest_seq`.
  static const int _seqProbe = 0x7fffffff;

  String _replayEpoch = '';
  final Map<String, int> _lastSeq = {};
  final Set<String> _watched = {};
  final Set<String> _replaying = {};
  final Map<String, List<GatewayEvent>> _held = {};
  final Set<String> _heldOverflow = {};

  /// Newest seq of a session that had no watermark; it becomes one once the
  /// held frames are through.
  final Map<String, int> _seed = {};

  /// See [HermesClient.watchSession].
  void watchSession(String runtimeId) {
    if (_watched.add(runtimeId)) unawaited(_seedWatermark(runtimeId));
  }

  /// See [HermesClient.unwatchSession].
  void unwatchSession(String runtimeId) {
    _watched.remove(runtimeId);
    _lastSeq.remove(runtimeId);
    _replaying.remove(runtimeId);
    _held.remove(runtimeId);
  }

  void onNotification(JsonRpcNotification n) {
    if (n.method != HermesMethods.event) return;
    final ev = GatewayEvent.fromParams(n.params);
    if (ev == null) return;
    if (ev.type == EventNames.gatewayReady) {
      unawaited(_onReady(ev));
    } else if (ev.isSessionScoped && _replaying.contains(ev.sessionId)) {
      final parked = _held.putIfAbsent(ev.sessionId, () => []);
      if (parked.length >= HermesLimits.heldEventsMax) {
        _heldOverflow.add(ev.sessionId);
      } else {
        parked.add(ev);
      }
    } else {
      _dispatchIfNewer(ev);
    }
  }

  void _emit(GatewayEvent ev) {
    if (!_c._disposed) _c._events.add(ev);
  }

  void _dispatchIfNewer(GatewayEvent ev) {
    final seq = ev.seq;
    if (seq != null && _watched.contains(ev.sessionId)) {
      if (seq <= (_lastSeq[ev.sessionId] ?? 0)) return;
      _lastSeq[ev.sessionId] = seq;
    }
    if (ev.type == EventNames.requestCancel) _c.requests.cancel(ev.text('id'));
    _emit(ev);
  }

  Future<void> _onReady(GatewayEvent ev) async {
    _c._liveness.readySeen();
    final generation = _transport.generation;
    final epoch = ev.text('replay_epoch');
    final changed = _replayEpoch.isNotEmpty && epoch != _replayEpoch;
    if (changed) _lastSeq.clear();
    _replayEpoch = epoch;
    _replaying
      ..clear()
      ..addAll(_watched);
    _held.clear();
    _heldOverflow.clear();
    _seed.clear();
    // First on the socket: the flag is per connection. A gateway that never
    // heard it fails the agent's questions at once instead of asking.
    try {
      await _c.call(HermesMethods.clientCapabilities, const {
        'server_requests': true,
      }, HermesTimeouts.rpcLiveness);
    } on HermesFailure catch (e) {
      _c.log('client.capabilities failed', e);
    }
    if (!_current(generation)) return;
    // Only watched sessions replay: questions of the rest would never be
    // confirmed again.
    _c.requests.retainSessions(_watched);
    _c._setState(Connected(replayEpoch: epoch));
    _transport.markReady();
    _c._checks.onGatewayProcess(epoch);
    _emit(ev);
    await Future.wait([
      for (final id in [..._watched]) _replaySession(id, generation, changed),
    ]);
  }

  bool _current(int generation) =>
      !_c._disposed &&
      _transport.isConnected &&
      _transport.generation == generation;

  Future<void> _replaySession(String id, int generation, bool changed) async {
    try {
      if (changed) {
        _truncated(id);
      } else {
        await _catchUp(id, generation);
      }
      if (!_current(generation)) return;
      await _rebind(id, generation);
    } on NetworkFailure catch (e) {
      // The frames never left, twice: the socket is half dead.
      _c.log('replay failed for $id', e);
      if (_current(generation)) _transport.invalidate('replay failed');
    } on HermesFailure catch (e) {
      _c.log('replay failed for $id', e);
    } finally {
      if (_transport.generation == generation) _release(id);
    }
  }

  Future<int?> _latestSeq(
    String id,
    int? seen,
    int generation, {
    bool seeding = false,
  }) async {
    final res = await _retryOnce(
      generation,
      () => _c.call(HermesMethods.sessionEventsSince, {
        'session_id': id,
        'last_seen': seen ?? _seqProbe,
      }, HermesTimeouts.rpcReplay),
    );
    if (seen != null) {
      for (final raw in res['events'] is List ? res['events'] as List : []) {
        if (raw is Map<String, dynamic>) {
          final e = GatewayEvent.fromParams(raw);
          if (e != null) _dispatchIfNewer(e);
        }
      }
    }
    if (!seeding && res['truncated'] == true) _truncated(id);
    return const LooseIntOrNull().fromJson(res['latest_seq']);
  }

  Future<void> _seedWatermark(String id) async {
    if (!_transport.isConnected || _lastSeq.containsKey(id)) return;
    try {
      final latest = await _latestSeq(
        id,
        null,
        _transport.generation,
        seeding: true,
      );
      if (latest == null || latest <= 0 || !_watched.contains(id)) return;
      if (latest > (_lastSeq[id] ?? 0)) _lastSeq[id] = latest;
    } on HermesFailure catch (e) {
      _c.log('could not seed the watermark of $id', e);
    }
  }

  /// The events of [id] after its watermark. With none yet, the ring holds
  /// history the transcript already has: only the newest number is taken.
  Future<void> _catchUp(String id, int generation) async {
    final seen = _lastSeq[id];
    try {
      final latest = await _latestSeq(id, seen, generation);
      if (seen == null && latest != null && latest > 0) _seed[id] = latest;
    } on ServerFailure catch (e) {
      _c.log('replay refused for $id', e);
      _truncated(id);
    } on OutcomeUnknownFailure catch (e) {
      // A slow gateway, not a gone one: a redial would meet it again.
      // Reload the transcript instead.
      if (!_current(generation)) rethrow;
      _c.log('replay timed out for $id', e);
      _truncated(id);
    }
  }

  Future<void> _rebind(String id, int generation) async {
    try {
      final snapshot = await _retryOnce(
        generation,
        () => _c.call(HermesMethods.sessionActivate, {
          'session_id': id,
          'cols': HermesLimits.terminalCols,
          'omit_messages': true,
        }),
      );
      _c.requests.replay(id, snapshot['open_requests']);
    } on ServerFailure catch (e) {
      _c.requests.replay(id, const <Object?>[]);
      _lost(id, e.rpcCode, e.message);
    } on OutcomeUnknownFailure catch (e) {
      if (!_current(generation)) rethrow;
      _c.log('rebind timed out for $id', e);
      _lost(id, null, e.message);
    }
  }

  void _lost(String id, int? code, String message) => _emit(
    GatewayEvent(
      type: SyntheticEvents.sessionLost,
      sessionId: id,
      payload: {'code': code, 'message': message},
    ),
  );

  /// One more try for a failed link while the socket is the same; both
  /// replay calls are safe to repeat.
  Future<T> _retryOnce<T>(int generation, Future<T> Function() op) async {
    try {
      return await op();
    } on NetworkFailure catch (e) {
      if (!_current(generation)) rethrow;
      _c.log('replay call failed, trying once more', e);
      return op();
    }
  }

  /// The replay of [id] is over: let its held frames through, then count
  /// from the gateway's newest. Frames beyond the cap were dropped: reload.
  void _release(String id) {
    _replaying.remove(id);
    final overflow = _heldOverflow.remove(id);
    (_held.remove(id) ?? const <GatewayEvent>[]).forEach(_dispatchIfNewer);
    final seed = _seed.remove(id);
    if (seed != null && _watched.contains(id) && seed > (_lastSeq[id] ?? 0)) {
      _lastSeq[id] = seed;
    }
    if (overflow) _truncated(id);
  }

  void _truncated(String id) =>
      _emit(GatewayEvent(type: SyntheticEvents.replayTruncated, sessionId: id));
}
