import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/transport/websocket_transport.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'support/loopback_gateway.dart';

/// The socket and its redials, over a real loopback socket.
void main() {
  test('a refused upgrade yields its labelled HTTP status, nothing else', () {
    const refused = WebSocketException(
      "Connection to 'http://127.0.0.1:403/api/ws?token=abc#' was not "
      'upgraded to websocket, HTTP status code: 403',
    );
    expect(upgradeStatusOf(WebSocketChannelException.from(refused)), 403);
    for (final text in [
      'port 4401 closed',
      'failed after 503 ms',
      'HTTP 401',
    ]) {
      expect(upgradeStatusOf(WebSocketException(text)), isNull, reason: text);
    }
  });

  group('over a loopback socket', () {
    late LoopbackGateway gateway;
    late WebSocketTransport transport;
    Future<WsDial> Function()? dial;
    WsDial wsDial() => WsDial(
      uri: gateway.url.replace(scheme: 'ws', path: '/api/ws'),
    );

    setUp(() async {
      gateway = LoopbackGateway()..sendReady = false;
      await gateway.start();
      dial = null;
      transport = WebSocketTransport(
        dialBuilder: () => dial?.call() ?? Future.value(wsDial()),
      );
    });

    tearDown(() async {
      await transport.dispose();
      await gateway.stop();
    });

    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 100));

    test('connecting twice at once dials one socket', () async {
      await Future.wait([transport.connect(), transport.connect()]);
      await settle();
      expect(gateway.sockets, hasLength(1));
    });

    test('a replaced socket closing late leaves its successor up', () async {
      await transport.connect();
      final closes = <TransportClose>[];
      transport.closes.listen(closes.add);

      await transport.reconnectNow();
      await gateway.sockets.first.close();
      await settle();

      expect(transport.isConnected, isTrue);
      expect(closes, isEmpty);
      transport.send(jsonEncode({'jsonrpc': '2.0', 'id': 1, 'method': 'p'}));
      await gateway.nextCall('p');
    });

    test('a drop redials, and the new link clears the old reason', () async {
      await transport.connect();
      final redialled = transport.states.firstWhere(
        (s) => s == TransportState.connected,
      );
      await gateway.sockets.first.close();
      await redialled.timeout(const Duration(seconds: 5));
      expect(transport.lastClose, isNull);
    });

    test('a dial built after dispose never opens a socket', () async {
      final ticket = Completer<WsDial>();
      dial = () => ticket.future;
      unawaited(transport.connect());
      await Future<void>.delayed(Duration.zero);
      await transport.dispose();
      ticket.complete(wsDial());
      await settle();
      expect(gateway.sockets, isEmpty);
    });
  });

  test('connectIo times out and closes a socket that lands late', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final hungUp = Completer<void>();
    server.listen((request) async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final ws = await WebSocketTransformer.upgrade(request);
      ws.listen(
        (_) {},
        onError: (Object _) {},
        onDone: () {
          hungUp.complete();
          unawaited(ws.close());
        },
      );
    });

    final connection = connectIo(
      WsDial(uri: Uri.parse('ws://127.0.0.1:${server.port}/api/ws')),
      const Duration(milliseconds: 50),
    );

    await expectLater(connection.ready, throwsA(isA<Object>()));
    await hungUp.future.timeout(const Duration(seconds: 5));
  });
}
