import 'dart:async';
import 'dart:io';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// One dial: built fresh per attempt, as a gated gateway needs a new ticket.
class WsDial {
  const WsDial({
    required this.uri,
    this.headers = const {},
    this.protocols = const [],
  });
  final Uri uri;
  final Map<String, String> headers;
  final List<String> protocols;
}

/// One WebSocket: frames in, text frames out. The seam a test fakes.
abstract interface class WsConnection {
  Future<void> get ready;

  Stream<Object?> get messages;

  /// Queues one text frame.
  void send(String frame);

  /// The peer's close code.
  int? get closeCode;

  String? get closeReason;

  /// Starts the close handshake.
  Future<void> close(int code);
}

/// Opens a [WsConnection]; [WsConnection.ready] says when it is up.
typedef WsConnector = WsConnection Function(WsDial dial, Duration timeout);

final class _ChannelConnection implements WsConnection {
  _ChannelConnection(this._channel);
  final WebSocketChannel _channel;

  @override
  Future<void> get ready => _channel.ready;

  @override
  Stream<Object?> get messages => _channel.stream.cast<Object?>();

  @override
  void send(String frame) => _channel.sink.add(frame);

  @override
  int? get closeCode => _channel.closeCode;

  @override
  String? get closeReason => _channel.closeReason;

  @override
  Future<void> close(int code) => _channel.sink.close(code);
}

/// The real [WsConnector]. A socket that lands after [timeout] is closed.
WsConnection connectIo(WsDial dial, Duration timeout) {
  final socket = WebSocket.connect(
    dial.uri.toString(),
    headers: dial.headers.isEmpty ? null : dial.headers,
    protocols: dial.protocols.isEmpty ? null : dial.protocols,
  );
  final bounded = socket.timeout(
    timeout,
    onTimeout: () {
      unawaited(socket.then((s) => s.close(), onError: (Object _) {}));
      throw TimeoutException('websocket upgrade', timeout);
    },
  );
  return _ChannelConnection(IOWebSocketChannel(bounded));
}
