import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/status.dart' as ws_status;

import '../hermes_constants.dart';
import '../hermes_failure.dart';
import '../rpc/message_channel.dart';
import 'redial_backoff.dart';
import 'transport_close.dart';
import 'transport_state.dart';
import 'ws_connection.dart';

export 'transport_close.dart';
export 'transport_state.dart';
export 'ws_connection.dart';

/// WebSocket [MessageChannel] that redials on a jittered exponential
/// backoff, and stops when the credential or the address is refused.
class WebSocketTransport implements MessageChannel {
  /// Builds each dial with [dialBuilder]. [hostRefused] is asked after an
  /// upgrade refused with 403: true when the Host guard refused it. The
  /// [connector], [stableAfter] and [random] are for tests.
  WebSocketTransport({
    required this.dialBuilder,
    WsConnector? connector,
    this.stableAfter = HermesTimeouts.backoffStable,
    this.hostRefused,
    Random? random,
  }) : _connector = connector ?? connectIo,
       _backoff = RedialBackoff(random);
  final Future<WsDial> Function() dialBuilder;
  final Duration stableAfter;
  final Future<bool> Function()? hostRefused;
  final WsConnector _connector;
  final RedialBackoff _backoff;
  final _incoming = StreamController<String>.broadcast();
  final _states = StreamController<TransportState>.broadcast();
  final _closes = StreamController<TransportClose>.broadcast();

  WsConnection? _connection;
  StreamSubscription<Object?>? _sub;
  Timer? _reconnectTimer;
  Timer? _stableTimer;
  TransportState _state = TransportState.disconnected;
  bool _want = false;
  bool _authStopped = false;
  bool _opening = false;
  bool _disposed = false;

  /// Numbers the dials: one a newer dial replaced drops what it opens.
  int _dial = 0;
  TransportClose? _lastClose;
  int _inboundFrames = 0;
  int _generation = 0;

  @override
  Stream<String> get incoming => _incoming.stream;

  Stream<TransportState> get states => _states.stream;

  Stream<TransportClose> get closes => _closes.stream;

  TransportClose? get lastClose => _lastClose;

  bool get isConnected => _state == TransportState.connected;

  int get attempt => _backoff.attempt;

  int get inboundFrames => _inboundFrames;

  int get generation => _generation;

  /// Opens the socket and keeps it open until [disconnect]. A no-op while
  /// one is open.
  Future<void> connect() async {
    if (_disposed) return;
    _want = true;
    _authStopped = false;
    if (isConnected) return;
    _reconnectTimer?.cancel();
    _backoff.reset();
    await _open();
  }

  /// Redials at once, also after a refused credential (the caller has a new
  /// one). A dial under way is dropped, not waited for: one begun in the
  /// background or on the old network can hang until its timeout. Nothing
  /// after [disconnect].
  Future<void> reconnectNow() async {
    if (_disposed || (!_want && !_authStopped)) return;
    _want = true;
    _authStopped = false;
    _reconnectTimer?.cancel();
    _backoff.reset();
    _teardown();
    await _open(replace: true);
  }

  /// The gateway said ready; after [stableAfter] the backoff starts over.
  void markReady() {
    if (!isConnected) return;
    _stableTimer?.cancel();
    final generation = _generation;
    _stableTimer = Timer(stableAfter, () {
      if (isConnected && generation == _generation) _backoff.reset();
    });
  }

  /// Drops an open socket as dead and lets the backoff redial.
  void invalidate(String reason) {
    if (_want && isConnected) _onClosed(TransportClose(reason: reason));
  }

  /// Closes the socket and stops redialling.
  Future<void> disconnect() async {
    _want = false;
    _authStopped = false;
    _reconnectTimer?.cancel();
    _teardown();
    _setState(TransportState.disconnected);
  }

  @override
  void send(String frame) {
    final connection = _connection;
    if (connection == null || !isConnected) {
      throw const NetworkFailure('socket not connected');
    }
    try {
      connection.send(frame);
    } on Object catch (e) {
      throw NetworkFailure('socket write failed', cause: e);
    }
  }

  /// Disconnects for good and closes every stream.
  Future<void> dispose() async {
    _disposed = true;
    await disconnect();
    await _incoming.close();
    await _states.close();
    await _closes.close();
  }

  Future<void> _open({bool replace = false}) async {
    if ((_opening && !replace) || !_want || _disposed) return;
    final dial = ++_dial;
    _opening = true;
    try {
      await _dialOnce(dial);
    } finally {
      if (dial == _dial) _opening = false;
    }
  }

  Future<void> _dialOnce(int dial) async {
    bool dropped() => dial != _dial || !_want || _disposed;
    _setState(
      _backoff.attempt == 0
          ? TransportState.connecting
          : TransportState.reconnecting,
    );
    try {
      final built = await dialBuilder();
      if (dropped()) return;
      final connection = _connector(built, HermesTimeouts.wsConnect);
      await connection.ready;
      if (dropped()) {
        _closeQuietly(connection);
        return;
      }
      _connection = connection;
      _generation++;
      _lastClose = null;
      _sub = connection.messages.listen(
        (data) {
          _inboundFrames++;
          if (data is String) {
            _incoming.add(data);
          } else if (data is List<int>) {
            _incoming.add(utf8.decode(data, allowMalformed: true));
          }
        },
        // A replaced socket's late close must not tear its successor down.
        onDone: () {
          if (!identical(_connection, connection)) return;
          _onClosed(
            TransportClose(
              code: connection.closeCode,
              reason: connection.closeReason,
            ),
          );
        },
        onError: (Object e) {
          if (!identical(_connection, connection)) return;
          _onClosed(TransportClose(error: e, httpStatus: upgradeStatusOf(e)));
        },
        cancelOnError: true,
      );
      _setState(TransportState.connected);
    } on HermesFailure catch (e) {
      if (dial != _dial) return;
      final auth = e is UnauthorizedFailure || e is ForbiddenFailure;
      _onClosed(
        TransportClose(
          error: e,
          httpStatus: auth ? HermesHttpStatus.unauthorized : null,
        ),
      );
    } on Object catch (e) {
      if (dial != _dial) return;
      final status = upgradeStatusOf(e);
      var guard = false;
      if (status == HermesHttpStatus.forbidden) {
        try {
          guard = await hostRefused?.call() ?? false;
        } on Object {
          guard = false;
        }
      }
      if (_disposed || dial != _dial) return;
      _onClosed(
        TransportClose(error: e, httpStatus: status, hostRefused: guard),
      );
    }
  }

  void _onClosed(TransportClose close) {
    if (_disposed) return;
    _lastClose = close;
    _closes.add(close);
    _teardown();
    if (!_want || close.stopsRedial) {
      _authStopped = _want && close.stopsRedial;
      _want = _want && !close.stopsRedial;
      _setState(TransportState.disconnected);
      return;
    }
    _setState(TransportState.reconnecting);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_backoff.next(), _open);
  }

  void _teardown() {
    _stableTimer?.cancel();
    final connection = _connection;
    unawaited(_sub?.cancel());
    _sub = null;
    _connection = null;
    if (connection != null) _closeQuietly(connection);
  }

  /// Starts the close handshake without waiting for a peer that may be gone.
  void _closeQuietly(WsConnection connection) => unawaited(
    Future<void>.sync(() => connection.close(ws_status.normalClosure))
        .then<void>((_) {}, onError: (Object _) {}),
  );

  void _setState(TransportState s) {
    if (_state == s || _states.isClosed) return;
    _state = s;
    _states.add(s);
  }
}
