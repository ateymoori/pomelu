import 'dart:async';
import 'dart:convert';

import '../hermes_constants.dart';
import '../hermes_failure.dart';
import '../hermes_log.dart';
import 'json_offload.dart';
import 'json_rpc_error.dart';
import 'message_channel.dart';

/// A server notification.
final class JsonRpcNotification {
  const JsonRpcNotification(this.method, this.params);
  final String method;
  final Map<String, dynamic> params;
}

/// Answers a server request later, with [JsonRpcClient.respond]. A thrown
/// [JsonRpcError] is the error reply; any other throw is
/// [HermesProtocol.errServer].
typedef DeferredRequestHandler = void Function(
  Object id,
  Map<String, dynamic> params,
);

/// JSON-RPC 2.0 over a [MessageChannel]: calls matched by id, server
/// notifications as a stream, server requests to registered handlers.
class JsonRpcClient {
  /// A client over [_channel]; [log] hears about frames it drops.
  JsonRpcClient(this._channel, {HermesLog? log}) : _log = log ?? discardLog {
    _sub = _channel.incoming.listen(
      _onFrame,
      onError: (Object e) =>
          failAllPending(OutcomeUnknownFailure('channel error', cause: e)),
    );
  }
  final MessageChannel _channel;
  final HermesLog _log;
  final _pending =
      <Object, ({Completer<Object?> done, Timer timer, String method})>{};
  final _notifications = StreamController<JsonRpcNotification>.broadcast();
  final _handlers = <String, DeferredRequestHandler>{};
  late final StreamSubscription<String> _sub;

  /// Frames decoding apart, in order: later frames wait behind them.
  Future<void>? _decoding;
  int _nextId = 1;
  bool _closed = false;

  Stream<JsonRpcNotification> get notifications => _notifications.stream;

  /// Whether a call of one of [methods] is in flight.
  bool hasPending(Set<String> methods) =>
      _pending.values.any((p) => methods.contains(p.method));

  /// Routes server requests of [method] to [handler].
  void registerDeferredHandler(String method, DeferredRequestHandler handler) =>
      _handlers[method] = handler;

  /// Answers the server request [id]. Throws [NetworkFailure] on a dead
  /// socket: the gateway re-delivers the request after the reconnect.
  void respond(Object id, Object? result) => _send({
    'jsonrpc': HermesProtocol.jsonRpcVersion,
    'id': id,
    'result': result,
  });

  /// [respond], but false instead of a throw on a dead socket.
  bool tryRespond(Object id, Object? result) => _try(() => respond(id, result));

  /// Error answer to [id]; false on a dead socket.
  bool tryRespondError(Object id, JsonRpcError error) => _try(
    () => _send({
      'jsonrpc': HermesProtocol.jsonRpcVersion,
      'id': id,
      'error': error.toJson(),
    }),
  );

  bool _try(void Function() send) {
    try {
      send();
      return true;
    } on NetworkFailure {
      return false;
    }
  }

  void _send(Map<String, Object?> frame) {
    if (_closed) throw const NetworkFailure('rpc client closed');
    _channel.send(jsonEncode(frame));
  }

  /// Calls [method] and waits for its result.
  ///
  /// [ProtocolFailure] for params that are no JSON; [NetworkFailure] when the
  /// frame never left; [OutcomeUnknownFailure] for a timeout or a drop after
  /// it was written. Large [Base64Bytes] params are encoded apart; the
  /// timeout starts once the frame goes out.
  Future<Object?> call(
    String method, [
    Map<String, dynamic> params = const {},
    Duration? timeout,
  ]) async {
    if (_closed) throw const NetworkFailure('rpc client closed');
    final id = _nextId++;
    final request = {
      'jsonrpc': HermesProtocol.jsonRpcVersion,
      'id': id,
      'method': method,
      'params': params,
    };
    final String frame;
    try {
      frame = encodesApart(params)
          ? await encodeJsonApart(request)
          : jsonEncode(request);
    } on Object catch (e) {
      throw ProtocolFailure('params of $method cannot be encoded', cause: e);
    }
    if (_closed) throw const NetworkFailure('rpc client closed');
    final done = Completer<Object?>();
    final timer = Timer(timeout ?? HermesTimeouts.rpc, () {
      if (_pending.remove(id) != null) {
        done.completeError(OutcomeUnknownFailure('timeout calling $method'));
      }
    });
    _pending[id] = (done: done, timer: timer, method: method);
    try {
      _channel.send(frame);
    } on Object catch (e) {
      _pending.remove(id);
      timer.cancel();
      throw NetworkFailure('send failed for $method', cause: e);
    }
    return done.future;
  }

  /// [call] that expects an object result (empty for null).
  Future<Map<String, dynamic>> callMap(
    String method, [
    Map<String, dynamic> params = const {},
    Duration? timeout,
  ]) async {
    final r = await call(method, params, timeout);
    if (r == null) return const {};
    if (r is Map<String, dynamic>) return r;
    throw ProtocolFailure('$method returned ${r.runtimeType}, not an object');
  }

  /// Fails every call in flight (the socket dropped).
  void failAllPending(HermesFailure failure) {
    final pending = [..._pending.values];
    _pending.clear();
    for (final p in pending) {
      p.timer.cancel();
      p.done.completeError(failure);
    }
  }

  /// Fails what is in flight and stops; later calls fail at once.
  Future<void> close() async {
    _closed = true;
    failAllPending(const OutcomeUnknownFailure('rpc client closed'));
    await _sub.cancel();
    await _notifications.close();
  }

  /// A large frame decodes on a short-lived isolate, and every frame after
  /// it waits its turn.
  void _onFrame(String raw) {
    final ahead = _decoding;
    if (ahead == null && raw.length < HermesLimits.offloadJsonBytes) {
      _handle(() => jsonDecode(raw));
      return;
    }
    late final Future<void> mine;
    mine = (ahead ?? Future<void>.value())
        .then((_) => decodeJsonApart(raw))
        .then<void>(
          (decoded) => _handle(() => decoded),
          onError: (Object e) => _log('dropped a bad frame', e),
        )
        .whenComplete(() {
          if (identical(_decoding, mine)) _decoding = null;
        });
    _decoding = mine;
  }

  /// Garbage is dropped and the socket stays; a bad entry of a batch drops
  /// only itself.
  void _handle(Object? Function() decode) {
    if (_closed) return;
    final Object? decoded;
    try {
      decoded = decode();
    } on Object catch (e) {
      _log('dropped a bad frame', e);
      return;
    }
    for (final m in decoded is List ? decoded : [decoded]) {
      try {
        _dispatch(m);
      } on Object catch (e) {
        _log('dropped a bad frame', e);
      }
    }
  }

  void _dispatch(Object? m) {
    if (m is! Map<String, dynamic>) {
      throw const ProtocolFailure('frame is not a JSON object');
    }
    final id = m['id'];
    final method = m['method'];
    if (method is String) {
      final params = m['params'];
      final map = params is Map<String, dynamic> ? params : <String, dynamic>{};
      if (id == null) {
        _notifications.add(JsonRpcNotification(method, map));
      } else {
        _serverRequest(id as Object, method, map);
      }
      return;
    }
    final error = m['error'];
    if (error == null && !m.containsKey('result')) {
      throw const ProtocolFailure('unrecognized JSON-RPC frame');
    }
    if (error != null && error is! Map<String, dynamic>) {
      throw const ProtocolFailure('error member is not an object');
    }
    final p = _pending.remove(id);
    if (p == null) return;
    p.timer.cancel();
    if (error is Map<String, dynamic>) {
      final code = error['code'];
      p.done.completeError(
        ServerFailure(
          error['message']?.toString() ?? 'unknown error',
          rpcCode: code is num ? code.toInt() : -1,
          data: error['data'],
        ),
      );
    } else {
      p.done.complete(m['result']);
    }
  }

  void _serverRequest(Object id, String method, Map<String, dynamic> params) {
    final handler = _handlers[method];
    try {
      if (handler == null) {
        throw JsonRpcError(
          code: HermesProtocol.errMethodNotFound,
          message: 'Method not found: $method',
        );
      }
      handler(id, params);
    } on Object catch (e) {
      final error = e is JsonRpcError
          ? e
          : JsonRpcError(code: HermesProtocol.errServer, message: '$e');
      if (!tryRespondError(id, error)) _log('could not reply to $id');
    }
  }
}
