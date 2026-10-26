import 'dart:async';
import 'dart:convert';

import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/rpc/message_channel.dart';

/// A [MessageChannel] the test drives by hand: [receive] plays a frame from
/// the gateway, [sent] keeps every frame the client wrote.
class FakeChannel implements MessageChannel {
  /// Source of [incoming].
  final controller = StreamController<String>.broadcast();

  /// Every frame sent, decoded, in order.
  final sent = <Map<String, dynamic>>[];

  /// While true `send` throws, like the transport does with no socket.
  bool down = false;

  @override
  Stream<String> get incoming => controller.stream;

  @override
  void send(String frame) {
    if (down) throw const NetworkFailure('socket not connected');
    sent.add(jsonDecode(frame) as Map<String, dynamic>);
  }

  /// Plays [obj] as a frame from the gateway.
  void receive(Map<String, dynamic> obj) => controller.add(jsonEncode(obj));
}
