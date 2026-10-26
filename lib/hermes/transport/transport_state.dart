/// Socket lifecycle as the transport sees it.
enum TransportState {
  /// No socket, and none wanted (or the gateway refused the credential).
  disconnected,

  /// First dial, or a forced redial.
  connecting,

  /// Frames flow.
  connected,

  /// The socket dropped; a redial waits on the backoff.
  reconnecting,
}
