import 'dart:async';

import '../auth/auth_credential.dart';
import '../auth/hermes_auth.dart';
import '../events/gateway_event.dart';
import '../hermes_constants.dart';
import '../hermes_failure.dart';
import '../hermes_log.dart';
import '../models/gateway_status.dart';
import '../models/json_converters.dart';
import '../requests/server_request_router.dart';
import '../rpc/json_rpc_client.dart';
import '../transport/hermes_http.dart';
import '../transport/websocket_transport.dart';
import 'connection_state.dart';

export '../events/gateway_event.dart' show SyntheticEvents;
export '../hermes_log.dart' show HermesLog;

part 'client_auth.dart';
part 'client_checks.dart';
part 'client_liveness.dart';
part 'client_replay.dart';

/// One live connection to one Hermes gateway: HTTP, the WebSocket, JSON-RPC,
/// the heartbeat, token renewal and replay after a reconnect. Features use
/// [call] and [events]; they never see frames.
class HermesClient {
  /// A client for [baseUrl]. [credential] is read per request and per dial;
  /// [onCredentialRotated] must store a renewed or discovered one. The
  /// timings, [connector], [stableAfter] and [status] are for tests.
  HermesClient({
    required this.baseUrl,
    required this._credential,
    required this._onCredentialRotated,
    HermesLog? log,
    this._heartbeatInterval = HermesTimeouts.heartbeatInterval,
    this._heartbeatDeadline = HermesTimeouts.heartbeatDeadline,
    this._readyTimeout = HermesTimeouts.gatewayReady,
    Duration stableAfter = HermesTimeouts.backoffStable,
    WsConnector? connector,
    Future<GatewayStatus> Function()? status,
  }) : log = log ?? discardLog {
    http = HermesHttp(
      baseUrl: baseUrl,
      credential: _credential,
      onUnauthorized: _renewal.tryRefresh,
    );
    auth = HermesAuth(http);
    _status = status ?? auth.status;
    _transport = WebSocketTransport(
      dialBuilder: _renewal.buildDial,
      connector: connector,
      stableAfter: stableAfter,
      hostRefused: _checks.hostRefused,
    );
    _rpc = JsonRpcClient(_transport, log: this.log);
    requests = ServerRequestRouter(log: this.log)..attach(_rpc);
    _subs = [
      _rpc.notifications.listen(_replay.onNotification),
      _transport.states.listen(_onTransportState),
      _transport.closes.listen(
        // A close prints with its secrets taken out.
        (c) => this.log('socket closed: $c'),
      ),
    ];
  }

  /// Gateway base URL, possibly with a proxy path prefix.
  final Uri baseUrl;

  /// The log the app gave this client.
  final HermesLog log;

  final AuthCredential Function() _credential;
  final Future<void> Function(AuthCredential) _onCredentialRotated;
  final Duration _heartbeatInterval;
  final Duration _heartbeatDeadline;
  final Duration _readyTimeout;
  late final Future<GatewayStatus> Function() _status;

  /// REST routes of the same gateway, with the same credential.
  late final HermesHttp http;

  /// Sign-in, refresh and ws tickets.
  late final HermesAuth auth;

  /// The questions the agent is blocked on, and their answers.
  late final ServerRequestRouter requests;

  late final WebSocketTransport _transport;
  late final JsonRpcClient _rpc;
  late final List<StreamSubscription<Object?>> _subs;
  late final _renewal = _Renewal(this);
  late final _liveness = _Liveness(this);
  late final _checks = _GatewayChecks(this);
  late final _replay = _Replay(this);

  final _events = StreamController<GatewayEvent>.broadcast();
  final _states = StreamController<HermesConnectionState>.broadcast();
  HermesConnectionState _state = const Disconnected();
  bool _disposed = false;

  /// Gateway events after replay de-duplication, plus [SyntheticEvents].
  Stream<GatewayEvent> get events => _events.stream;

  /// Every change of [state].
  Stream<HermesConnectionState> get states => _states.stream;

  /// Where the connection is now.
  HermesConnectionState get state => _state;

  /// Whether the gateway said ready on the open socket.
  bool get isConnected => _state is Connected;

  /// How the last socket closed, secrets taken out; null before any close
  /// and once a new socket is up.
  String? get lastCloseReason => _transport.lastClose?.describe();

  /// The failure the last close stands for.
  HermesFailure? get lastFailure => _transport.lastClose?.failure;

  /// Opens the socket and keeps it open (redialling) until [disconnect].
  Future<void> connect() async {
    if (_disposed) return;
    if (!_transport.isConnected) _setState(const Connecting());
    await _transport.connect();
  }

  /// Closes the socket and stops redialling.
  Future<void> disconnect() async {
    if (_disposed) return;
    _liveness.stop();
    await _transport.disconnect();
    _setState(const Disconnected());
  }

  /// Redials at once (app resumed, network changed, new credential). Calls
  /// on the old socket fail. Nothing after [disconnect].
  Future<void> reconnectNow() async {
    if (!_disposed) await _transport.reconnectNow();
  }

  /// Disconnects for good and closes every stream.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _liveness.stop();
    http.close();
    for (final s in _subs) {
      await s.cancel();
    }
    await _rpc.close();
    await _transport.dispose();
    await requests.dispose();
    await _events.close();
    await _states.close();
  }

  /// Marks a session open in the UI: reconnects replay and rebind it. The
  /// first watch asks the gateway for its newest event number, so a later
  /// reconnect replays from there.
  void watchSession(String runtimeId) => _replay.watchSession(runtimeId);

  /// Undoes [watchSession].
  void unwatchSession(String runtimeId) => _replay.unwatchSession(runtimeId);

  /// Looks for the new session token of an un-gated gateway (a restarted
  /// dashboard shows it on its index page) and keeps it through
  /// `onCredentialRotated`. True when one other than the held token was
  /// found.
  Future<bool> rediscoverSessionToken() async {
    final held = _renewal.read();
    return _renewal.rediscover(held is SessionTokenCredential ? held : null);
  }

  /// Calls [method] and returns its object result. A call whose frame never
  /// left fails with a [NetworkFailure]; once written, a timeout or a drop is
  /// an [OutcomeUnknownFailure].
  Future<Map<String, dynamic>> call(
    String method, [
    Map<String, dynamic> params = const {},
    Duration? timeout,
  ]) => _rpc.callMap(method, params, timeout);

  /// Cheap liveness probe; `-32601` (an older gateway) is alive too.
  Future<bool> probeAlive() async {
    try {
      await _rpc.call(HermesMethods.ping, const {}, HermesTimeouts.rpcLiveness);
      return true;
    } on ServerFailure catch (e) {
      return e.rpcCode == HermesProtocol.errMethodNotFound;
    } on HermesFailure {
      return false;
    }
  }

  // ------------------------------------------------------------ states

  void _onTransportState(TransportState s) {
    switch (s) {
      case TransportState.connecting:
        // A forced redial replaces a live socket without a close.
        _onSocketLost();
        _setState(const Connecting());
      case TransportState.reconnecting:
        _onSocketLost();
        _setState(Reconnecting(attempt: _transport.attempt));
      case TransportState.disconnected:
        _onSocketLost();
        final close = _transport.lastClose;
        if (close != null && close.isAuthFailure) {
          _setState(AuthRequired(failure: close.failure));
        } else if (close != null && close.hostRefused) {
          _setState(Disconnected(failure: close.failure));
        } else if (_state is! Disconnected) {
          _setState(
            Disconnected(failure: close?.error == null ? null : close!.failure),
          );
        }
      case TransportState.connected:
        _liveness.awaitReady();
    }
  }

  void _onSocketLost() {
    _liveness.stop();
    _rpc.failAllPending(const OutcomeUnknownFailure('socket dropped'));
  }

  void _setState(HermesConnectionState s) {
    if (_disposed) return;
    _state = s;
    _states.add(s);
  }
}

/// Waiting for the gateway; an extension, so a fake client gets it too.
extension WhenConnected on HermesClient {
  /// Completes once the gateway is [Connected]: at once when it is, unless
  /// [next], which waits for the next connection. Throws
  /// [NetworkFailure.notConnected] when [timeout] passes or the client goes
  /// away first; with [failOnSignIn], an [UnauthorizedFailure] once the
  /// gateway wants a sign-in.
  Future<void> whenConnected({
    Duration? timeout,
    bool next = false,
    bool failOnSignIn = false,
  }) async {
    bool settles(HermesConnectionState s) =>
        s is Connected || (failOnSignIn && s is AuthRequired);
    var reached = state;
    if (next || !settles(reached)) {
      final wait = states.firstWhere(
        settles,
        orElse: () => const Disconnected(),
      );
      try {
        reached = await (timeout == null ? wait : wait.timeout(timeout));
      } on TimeoutException {
        throw NetworkFailure.notConnected;
      }
    }
    if (reached is AuthRequired) {
      throw const UnauthorizedFailure('sign-in required');
    }
    if (reached is! Connected) throw NetworkFailure.notConnected;
  }
}
