import '../hermes_failure.dart';

/// User-visible connection state of the gateway client.
sealed class HermesConnectionState {
  const HermesConnectionState();
}

/// No socket, by request or after a failure.
final class Disconnected extends HermesConnectionState {
  const Disconnected({this.failure});
  final HermesFailure? failure;
}

/// The first dial is under way.
final class Connecting extends HermesConnectionState {
  const Connecting();
}

/// The socket dropped; the client redials on a backoff.
final class Reconnecting extends HermesConnectionState {
  const Reconnecting({required this.attempt});
  final int attempt;
}

/// The gateway said ready on the open socket.
final class Connected extends HermesConnectionState {
  const Connected({required this.replayEpoch});

  /// Identity of the gateway's event numbering; a new value means the seqs
  /// restarted.
  final String replayEpoch;
}

/// The gateway rejected the credential; user action required.
final class AuthRequired extends HermesConnectionState {
  const AuthRequired({this.failure});
  final HermesFailure? failure;
}
