part of 'hermes_client.dart';

/// RPCs whose frame carries a whole file: while one is out the socket is
/// busy writing and cannot answer pings.
const Set<String> _bulkMethods = {
  HermesMethods.imageAttachBytes,
  HermesMethods.fileAttach,
};

/// Drops a socket that never says `gateway.ready`, or that falls silent.
class _Liveness {
  _Liveness(this._c);

  final HermesClient _c;

  Timer? _heartbeat;
  Timer? _readyTimer;
  bool _readySeen = false;
  int _seenFrames = 0;
  int _silentBeats = 0;
  bool _httpProbeInFlight = false;
  bool _httpProbeOk = false;

  WebSocketTransport get _transport => _c._transport;

  /// A fresh socket has `readyTimeout` to say `gateway.ready`.
  void awaitReady() {
    _readyTimer?.cancel();
    if (_readySeen) return;
    _readyTimer = Timer(_c._readyTimeout, () {
      _readyTimer = null;
      _transport.invalidate('no gateway.ready');
    });
  }

  /// The gateway said ready: the heartbeat starts.
  void readySeen() {
    _readySeen = true;
    _readyTimer?.cancel();
    _readyTimer = null;
    _seenFrames = _transport.inboundFrames;
    _silentBeats = 0;
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(_c._heartbeatInterval, (_) => _beat());
  }

  /// Silence counts in beats without an inbound frame, not off a clock (a
  /// timer cannot jump with the wall clock). While a file goes out, the
  /// socket cannot answer pings; a `GET /api/status` per beat stands in, so
  /// a dead network still drops the socket and a slow upload goes on.
  void _beat() {
    final frames = _transport.inboundFrames;
    final uploading = _c._rpc.hasPending(_bulkMethods);
    if (frames != _seenFrames || (uploading && _httpProbeOk)) {
      _seenFrames = frames;
      _silentBeats = 0;
    } else {
      _silentBeats++;
    }
    final deadline = uploading
        ? HermesTimeouts.bulkLivenessDeadline
        : _c._heartbeatDeadline;
    if (_c._heartbeatInterval * _silentBeats >= deadline) {
      _transport.invalidate('heartbeat deadline');
      return;
    }
    if (!_transport.isConnected) return;
    if (!uploading) {
      unawaited(
        _c._rpc
            .call(HermesMethods.gatewayPing, const {}, _c._heartbeatDeadline)
            .catchError((Object _) => null),
      );
      return;
    }
    _httpProbeOk = false;
    if (_httpProbeInFlight) return;
    _httpProbeInFlight = true;
    unawaited(
      _c
          ._status()
          .then<void>(
            (_) => _httpProbeOk = true,
            onError: (Object _) => _httpProbeOk = false,
          )
          .whenComplete(() => _httpProbeInFlight = false),
    );
  }

  void stop() {
    _heartbeat?.cancel();
    _heartbeat = null;
    _readyTimer?.cancel();
    _readyTimer = null;
    _readySeen = false;
  }
}
