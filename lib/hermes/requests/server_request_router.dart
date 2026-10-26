import 'dart:async';

import '../hermes_constants.dart';
import '../hermes_log.dart';
import '../rpc/json_rpc_client.dart';
import '../rpc/json_rpc_error.dart';
import 'server_request.dart';

/// Requests the app shows and answers from a card.
const Set<String> _interactive = {'clarify', 'approval', 'sudo', 'secret'};

/// One-string prompts the app does not show; answered "skipped".
const Set<String> _skipped = {
  'vault.unlock_prompt',
  'vault.save_login',
  'vault.code',
  'display.install.sudo',
};

/// Desktop window bridges; answered [HermesProtocol.errNotShown].
const Set<String> _notShown = {
  'terminal.read',
  'preview.read',
  'window.read',
  'preview.act',
  'tour',
  'setup_beat',
  'theme.apply',
  'theme.pick',
};

/// Holds the questions the agent is blocked on and answers the gateway.
///
/// Every request method the gateway may send is taken over, as an
/// unanswered one blocks the agent until its deadline. A request lives until
/// answered, withdrawn ([cancel]) or no longer listed by a reconnect
/// snapshot ([replay]). An answer on a dead socket fails and leaves it open:
/// the gateway re-delivers it after the reconnect.
class ServerRequestRouter {
  /// An empty router; [attach] it to the connection's RPC client.
  ServerRequestRouter({HermesLog? log}) : _log = log ?? discardLog;
  final HermesLog _log;
  late final JsonRpcClient _rpc;

  /// Open requests by id, oldest first, with the id as it came on the wire
  /// (a number must be answered with the number).
  final Map<String, ({ServerRequest request, Object wireId})> _open = {};
  final _changes = StreamController<void>.broadcast(sync: true);
  final _arrivals = StreamController<ServerRequest>.broadcast();
  final _closed = StreamController<String>.broadcast();

  /// Takes over every request method the gateway may send on [rpc].
  void attach(JsonRpcClient rpc) {
    _rpc = rpc;
    for (final method in {..._interactive, ..._skipped, ..._notShown}) {
      rpc.registerDeferredHandler(
        method,
        (id, params) => _accept(id, method, params, replayed: false),
      );
    }
  }

  Stream<ServerRequest> get arrivals => _arrivals.stream;

  Stream<String> get closed => _closed.stream;

  /// The oldest open request of [sessionId], or null.
  ServerRequest? pendingFor(String sessionId) {
    for (final e in _open.values) {
      if (e.request.sessionId == sessionId) return e.request;
    }
    return null;
  }

  /// [pendingFor] now and on each change.
  Stream<ServerRequest?> watch(String sessionId) {
    late final StreamController<ServerRequest?> out;
    StreamSubscription<void>? sub;
    out = StreamController<ServerRequest?>(
      onListen: () {
        out.add(pendingFor(sessionId));
        sub = _changes.stream.listen(
          (_) => out.add(pendingFor(sessionId)),
          onDone: () => unawaited(out.close()),
        );
      },
      onCancel: () => sub?.cancel(),
    );
    return out.stream.distinct();
  }

  // Each answer returns whether the question is settled: false only when
  // the socket is down. One already closed (a double tap) counts as settled.

  /// Answers a clarify request (qid → answer, null = skipped).
  bool answerClarify(String id, Map<String, String?> answers) =>
      _answer<ClarifyRequest>(id, {'answers': answers});

  /// Cancels a clarify request.
  bool cancelClarify(String id) => _answer<ClarifyRequest>(id, const {});

  /// Answers an approval with one of its choices.
  bool answerApproval(String id, String choice) =>
      _answer<ApprovalRequest>(id, {'choice': choice});

  /// Answers a masked-input request; empty means skipped.
  bool answerInput(String id, String value) =>
      _answer<InputRequest>(id, {'value': value});

  bool _answer<T extends ServerRequest>(String id, Map<String, Object?> res) {
    final open = _open[id];
    if (open == null || open.request is! T) return true;
    if (!_reply(_rpc.tryRespond(open.wireId, res), id)) return false;
    _close(id);
    return true;
  }

  /// The gateway withdrew request [id] (`request.cancel`).
  void cancel(String id) => _close(id);

  /// Makes the open requests of [sessionId] match a reconnect snapshot
  /// (`open_requests`): listed ones open as if just arrived, the rest go.
  void replay(String sessionId, Object? entries) {
    final listed = <String>{};
    for (final entry in entries is List ? entries : const []) {
      if (entry is! Map) continue;
      final Object? id = entry['id'];
      final Object? method = entry['method'];
      final Object? params = entry['params'];
      if (id == null || method is! String) continue;
      _accept(
        id,
        method,
        params is Map<String, dynamic> ? params : const {},
        replayed: true,
      );
      if (_open.containsKey('$id')) listed.add('$id');
    }
    _closeWhere((r) => r.sessionId == sessionId && !listed.contains(r.id));
  }

  /// Forgets requests of sessions outside [sessions]: a new connection only
  /// replays the watched ones.
  void retainSessions(Set<String> sessions) =>
      _closeWhere((r) => !sessions.contains(r.sessionId));

  /// Drops every open request and closes the streams.
  Future<void> dispose() async {
    _open.clear();
    await _changes.close();
    await _arrivals.close();
    await _closed.close();
  }

  void _accept(
    Object rawId,
    String method,
    Map<String, dynamic> params, {
    required bool replayed,
  }) {
    final id = '$rawId';
    if (_skipped.contains(method)) {
      _reply(_rpc.tryRespond(rawId, const {'value': ''}), id);
      return;
    }
    final request = _interactive.contains(method)
        ? ServerRequest.parse(id, method, params)
        : null;
    if (request == null) {
      final error = _notShown.contains(method)
          ? const JsonRpcError(
              code: HermesProtocol.errNotShown,
              message: 'This client does not show this request.',
            )
          : _interactive.contains(method)
          ? const JsonRpcError(
              code: HermesProtocol.errInvalidParams,
              message: 'request cannot be shown',
            )
          : JsonRpcError(
              code: HermesProtocol.errMethodNotFound,
              message: 'Method not found: $method',
            );
      _reply(_rpc.tryRespondError(rawId, error), id);
      return;
    }
    final isNew = !_open.containsKey(id);
    _open[id] = (request: request, wireId: rawId);
    _changes.add(null);
    if (isNew && !replayed) _arrivals.add(request);
  }

  bool _reply(bool sent, String id) {
    if (!sent) _log('could not reply to $id');
    return sent;
  }

  void _closeWhere(bool Function(ServerRequest r) test) => [
    for (final e in _open.values)
      if (test(e.request)) e.request.id,
  ].forEach(_close);

  void _close(String id) {
    if (_open.remove(id) == null) return;
    _changes.add(null);
    _closed.add(id);
  }
}
