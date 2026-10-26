import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// One HTTP request as the gateway saw it.
typedef SeenRequest = ({
  String method,
  String path,
  Map<String, String> query,
  HttpHeaders headers,
  Object? body,
});

/// A canned HTTP answer. [cookies] become `Set-Cookie` headers, [headers]
/// plain ones (`location`, ...).
typedef HttpReply = ({
  int status,
  Object? body,
  List<String> cookies,
  Map<String, String> headers,
});

/// Builds an [HttpReply].
HttpReply reply(
  Object? body, {
  int status = 200,
  List<String> cookies = const [],
  Map<String, String> headers = const {},
}) => (status: status, body: body, cookies: cookies, headers: headers);

/// What an RPC handler answers: a result, an error, or no answer at all.
sealed class RpcAnswer {
  const RpcAnswer();
}

/// Answers with `result`, after [delay].
final class RpcResult extends RpcAnswer {
  const RpcResult(this.result, {this.delay = Duration.zero});
  final Object? result;
  final Duration delay;
}

/// Answers with a JSON-RPC error.
final class RpcError extends RpcAnswer {
  const RpcError(this.code, this.message, {this.data});
  final int code;
  final String message;
  final Object? data;
}

/// Never answers.
final class RpcSilence extends RpcAnswer {
  const RpcSilence();
}

/// Answers when [result] completes: the test decides the moment.
final class RpcDeferred extends RpcAnswer {
  const RpcDeferred(this.result);
  final Future<Object?> result;
}

/// A scripted Hermes gateway on a loopback port: REST routes plus the
/// JSON-RPC WebSocket at `/api/ws`. Records everything the client sends.
class LoopbackGateway {
  late final HttpServer _server;

  /// REST answers by `'METHOD /path'`. A missing route is a 404.
  final Map<String, FutureOr<HttpReply> Function(SeenRequest)> routes = {};

  /// RPC answers by method. A missing method answers `{}`.
  final Map<String, RpcAnswer Function(Map<String, dynamic> params)> rpc = {};

  /// Every HTTP request except WebSocket upgrades.
  final List<SeenRequest> requests = [];

  /// Every RPC request the client sent, in order, across all sockets.
  final List<({String method, Map<String, dynamic> params})> calls = [];

  /// Open sockets, oldest first.
  final List<WebSocket> sockets = [];

  /// `replay_epoch` of the next `gateway.ready`.
  String epoch = 'epoch-1';

  /// When false, a new socket gets no `gateway.ready`.
  bool sendReady = true;

  final _upgrades = StreamController<WebSocket>.broadcast();
  final _calls =
      StreamController<
        ({String method, Map<String, dynamic> params})
      >.broadcast();

  /// Fires for every accepted WebSocket.
  Stream<WebSocket> get upgrades => _upgrades.stream;

  /// Fires for every RPC request.
  Stream<({String method, Map<String, dynamic> params})> get callStream =>
      _calls.stream;

  /// Base URL of the gateway.
  Uri get url => Uri.parse('http://127.0.0.1:${_server.port}');

  /// RPC methods called so far.
  List<String> get methods => [for (final c in calls) c.method];

  /// Binds the port and starts serving.
  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen(_onRequest);
  }

  Future<void> _onRequest(HttpRequest request) async {
    if (request.uri.path == '/api/ws' &&
        WebSocketTransformer.isUpgradeRequest(request)) {
      final ws = await WebSocketTransformer.upgrade(request);
      sockets.add(ws);
      _upgrades.add(ws);
      ws.listen((data) => _onFrame(ws, data as String), onError: (_) {});
      if (sendReady) {
        sendEvent('gateway.ready', payload: {'replay_epoch': epoch}, to: ws);
      }
      return;
    }
    final text = await utf8.decoder.bind(request).join();
    final seen = (
      method: request.method,
      path: request.uri.path,
      query: request.uri.queryParameters,
      headers: request.headers,
      body: text.isEmpty ? null : _tryJson(text),
    );
    requests.add(seen);
    final handler = routes['${request.method} ${request.uri.path}'];
    final answer = handler == null
        ? reply({'detail': 'Not Found'}, status: 404)
        : await handler(seen);
    final res = request.response..statusCode = answer.status;
    for (final c in answer.cookies) {
      res.headers.add(HttpHeaders.setCookieHeader, c);
    }
    answer.headers.forEach(res.headers.set);
    final body = answer.body;
    if (body is String) {
      res.headers.contentType = ContentType.html;
      res.write(body);
    } else if (body != null) {
      res.headers.contentType = ContentType.json;
      res.write(jsonEncode(body));
    }
    await res.close();
  }

  static Object? _tryJson(String text) {
    try {
      return jsonDecode(text);
    } on FormatException {
      return text;
    }
  }

  void _onFrame(WebSocket ws, String raw) {
    final frame = jsonDecode(raw) as Map<String, dynamic>;
    final method = frame['method'];
    final id = frame['id'];
    if (method is! String || id == null) return;
    final params = (frame['params'] as Map<String, dynamic>?) ?? {};
    final call = (method: method, params: params);
    calls.add(call);
    _calls.add(call);
    final answer =
        rpc[method]?.call(params) ?? const RpcResult(<String, dynamic>{});
    switch (answer) {
      case RpcSilence():
        return;
      case RpcError(:final code, :final message, :final data):
        _write(ws, {
          'jsonrpc': '2.0',
          'id': id,
          'error': {'code': code, 'message': message, 'data': ?data},
        });
      case RpcDeferred(:final result):
        unawaited(
          result.then(
            (value) =>
                _write(ws, {'jsonrpc': '2.0', 'id': id, 'result': value}),
          ),
        );
      case RpcResult(:final result, :final delay):
        final frame = {'jsonrpc': '2.0', 'id': id, 'result': result};
        if (delay == Duration.zero) {
          _write(ws, frame);
        } else {
          Timer(delay, () => _write(ws, frame));
        }
    }
  }

  void _write(WebSocket ws, Map<String, dynamic> frame) {
    if (ws.readyState != WebSocket.open) return;
    try {
      ws.add(jsonEncode(frame));
      // dart:io reports an add to a socket closed after the check above as a
      // StateError, and there is no other way to ask; it is not a bug here.
      // ignore: avoid_catching_errors
    } on StateError {
      // The client closed it a moment ago.
    }
  }

  /// Pushes one gateway event on [to] (default: the newest socket).
  void sendEvent(
    String type, {
    String sessionId = '',
    int? seq,
    Map<String, dynamic>? payload,
    WebSocket? to,
  }) => _write(to ?? sockets.last, {
    'jsonrpc': '2.0',
    'method': 'event',
    'params': {
      'type': type,
      'session_id': sessionId,
      'seq': ?seq,
      'payload': ?payload,
    },
  });

  /// Waits for the next RPC call of [method].
  Future<Map<String, dynamic>> nextCall(String method) => callStream
      .firstWhere((c) => c.method == method)
      .then((c) => c.params)
      .timeout(const Duration(seconds: 5));

  /// Closes every socket and the port.
  Future<void> stop() async {
    for (final ws in sockets) {
      await ws.close();
    }
    await _server.close(force: true);
    await _upgrades.close();
    await _calls.close();
  }
}
