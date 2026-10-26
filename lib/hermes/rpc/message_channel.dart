import '../hermes_failure.dart';

/// Moves text frames both ways (a WebSocket, or a fake).
abstract interface class MessageChannel {
  Stream<String> get incoming;

  /// Sends one frame; throws [NetworkFailure] when the channel is down.
  void send(String frame);
}
