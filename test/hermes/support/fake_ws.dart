import 'dart:async';
import 'dart:convert';

import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/client/hermes_client.dart';
import 'package:hermes/hermes/models/gateway_status.dart';
import 'package:hermes/hermes/transport/websocket_transport.dart';

import 'loopback_gateway.dart'
    show RpcAnswer, RpcDeferred, RpcError, RpcResult, RpcSilence;

/// One socket of a [FakeWsNetwork]: the test plays the gateway through it
/// and reads what the client wrote in [sent]. No clock: runs under
/// `fakeAsync`.
class FakeWsConnection implements WsConnection {
  FakeWsConnection._(this.dial, this._network);

  final WsDial dial;
  final FakeWsNetwork _network;
  final _messages = StreamController<Object?>();
  final _ready = Completer<void>();
  bool _serverClosed = false;
  int? _closeCode;

  /// Every frame the client wrote, decoded, in order.
  final List<Map<String, dynamic>> sent = [];
  bool closedByClient = false;

  /// RPC methods the client called on this socket, in order.
  List<String> get methods => [
    for (final f in sent)
      if (f['method'] is String && f['id'] != null) f['method'] as String,
  ];

  /// The params of every call of [method].
  List<Map<String, dynamic>> callsTo(String method) => [
    for (final f in sent)
      if (f['method'] == method && f['id'] != null)
        f['params'] as Map<String, dynamic>,
  ];

  /// The client's answer to the server request [id].
  Map<String, dynamic>? replyTo(Object id) =>
      sent.where((f) => f['id'] == id && f['method'] == null).firstOrNull;

  /// The id of the newest call of [method].
  Object idOf(String method) =>
      sent.lastWhere((f) => f['method'] == method && f['id'] != null)['id']
          as Object;

  void open() {
    if (!_ready.isCompleted) _ready.complete();
  }

  void failUpgrade(Object error) {
    if (!_ready.isCompleted) _ready.completeError(error);
  }

  void serverSends(Map<String, dynamic> frame) {
    if (!_messages.isClosed) _messages.add(jsonEncode(frame));
  }

  void sendEvent(
    String type, {
    String sessionId = '',
    int? seq,
    Map<String, dynamic>? payload,
  }) => serverSends({
    'jsonrpc': '2.0',
    'method': 'event',
    'params': {
      'type': type,
      'session_id': sessionId,
      'seq': ?seq,
      'payload': ?payload,
    },
  });

  void answer(Object id, Object? result) =>
      serverSends({'jsonrpc': '2.0', 'id': id, 'result': result});

  void serverClose({int? code}) {
    _serverClosed = true;
    _closeCode = code;
    if (!_messages.isClosed) unawaited(_messages.close());
  }

  @override
  Future<void> get ready => _ready.future;

  @override
  Stream<Object?> get messages => _messages.stream;

  @override
  void send(String frame) {
    if (_serverClosed || closedByClient) throw StateError('socket closed');
    final decoded = jsonDecode(frame) as Map<String, dynamic>;
    sent.add(decoded);
    _network._answer(this, decoded);
  }

  @override
  int? get closeCode => _closeCode;

  @override
  String? get closeReason => null;

  @override
  Future<void> close(int code) async {
    closedByClient = true;
    if (!_messages.isClosed) unawaited(_messages.close());
  }
}

/// A scripted network: every dial gets a [FakeWsConnection], opened and
/// greeted with `gateway.ready` unless the test says otherwise.
class FakeWsNetwork {
  final List<FakeWsConnection> connections = [];
  bool autoOpen = true;
  bool autoReady = true;

  /// `replay_epoch` of the next `gateway.ready`.
  String epoch = 'epoch-1';

  /// Runs on a socket right after its `gateway.ready`.
  void Function(FakeWsConnection)? afterReady;

  /// RPC answers by method; a missing one answers `{}`.
  final Map<String, RpcAnswer Function(Map<String, dynamic> params)> rpc = {};

  WsConnector get connector => (dial, timeout) {
    final c = FakeWsConnection._(dial, this);
    connections.add(c);
    if (autoOpen) {
      scheduleMicrotask(() {
        c.open();
        if (!autoReady) return;
        scheduleMicrotask(() {
          c.sendEvent('gateway.ready', payload: {'replay_epoch': epoch});
          afterReady?.call(c);
        });
      });
    }
    return c;
  };

  void _answer(FakeWsConnection c, Map<String, dynamic> frame) {
    final method = frame['method'];
    final id = frame['id'];
    if (method is! String || id == null) return;
    final params = (frame['params'] as Map<String, dynamic>?) ?? const {};
    final answer =
        rpc[method]?.call(params) ?? const RpcResult(<String, dynamic>{});
    switch (answer) {
      case RpcSilence():
        return;
      case RpcDeferred(:final result):
        unawaited(result.then((value) => c.answer(id as Object, value)));
      case RpcError(:final code, :final message):
        scheduleMicrotask(
          () => c.serverSends({
            'jsonrpc': '2.0',
            'id': id,
            'error': {'code': code, 'message': message},
          }),
        );
      case RpcResult(:final result, :final delay):
        if (delay == Duration.zero) {
          scheduleMicrotask(() => c.answer(id as Object, result));
        } else {
          Timer(delay, () => c.answer(id as Object, result));
        }
    }
  }
}

/// A [HermesClient] on [network] with a session token, so a dial needs no
/// HTTP; `GET /api/status` answers [status] (a current gateway by default).
HermesClient fakeClient(
  FakeWsNetwork network, {
  Duration heartbeatInterval = const Duration(seconds: 15),
  Duration heartbeatDeadline = const Duration(seconds: 45),
  Duration readyTimeout = const Duration(seconds: 10),
  Duration stableAfter = const Duration(seconds: 10),
  HermesLog? log,
  Future<GatewayStatus> Function()? status,
}) => HermesClient(
  baseUrl: Uri.parse('http://gateway.test'),
  credential: () => const SessionTokenCredential('tok'),
  onCredentialRotated: (_) async {},
  connector: network.connector,
  heartbeatInterval: heartbeatInterval,
  heartbeatDeadline: heartbeatDeadline,
  readyTimeout: readyTimeout,
  stableAfter: stableAfter,
  log: log,
  status: status ?? () async => const GatewayStatus(version: '0.22.2'),
);
