import 'package:web_socket_channel/web_socket_channel.dart';

import '../hermes_constants.dart';
import '../hermes_failure.dart';
import '../hermes_log.dart';

/// Why a connection closed, for the UI and the reconnect policy.
class TransportClose {
  const TransportClose({
    this.code,
    this.reason,
    this.error,
    this.httpStatus,
    this.hostRefused = false,
  });
  final int? code;
  final String? reason;

  /// The raw error. Its text may hold the socket URL and token: show it only
  /// through [describe] or [toString].
  final Object? error;
  final int? httpStatus;
  final bool hostRefused;

  bool get stopsRedial => isAuthFailure || hostRefused;

  /// Whether the gateway refused the credential (HTTP 401/403, a close
  /// code of [HermesProtocol.authCloseCodes]).
  bool get isAuthFailure =>
      !hostRefused &&
      (httpStatus == HermesHttpStatus.unauthorized ||
          httpStatus == HermesHttpStatus.forbidden ||
          HermesProtocol.authCloseCodes.contains(code));

  /// The failure this close stands for.
  HermesFailure get failure {
    final error = this.error;
    if (hostRefused) {
      return HostRefusedFailure(
        'the gateway refused this address (Host / Origin guard)',
        cause: this,
      );
    }
    if (error is HermesFailure) return error;
    if (isAuthFailure) {
      return UnauthorizedFailure('gateway rejected credential', cause: this);
    }
    return NetworkFailure('$this', cause: this);
  }

  /// A short account for a person (`HTTP 403`, `close 1011: going away`),
  /// secrets hidden; null when nothing was reported.
  String? describe() {
    final error = this.error;
    final parts = [
      if (hostRefused) 'host refused',
      if (httpStatus != null) 'HTTP $httpStatus',
      if (code != null) 'close $code',
      if (reason?.trim() case final r? when r.isNotEmpty) r,
      if (error is HermesFailure)
        error.message
      else if (error != null)
        '$error'.split('\n').first.trim(),
    ];
    if (parts.isEmpty) return null;
    final text = redactSecrets(parts.join(': '));
    const max = HermesLimits.closeReasonChars;
    return text.length <= max ? text : '${text.substring(0, max)}…';
  }

  @override
  String toString() => redactSecrets(
    'TransportClose(code: $code, http: $httpStatus, reason: $reason, '
    'hostRefused: $hostRefused, error: $error)',
  );
}

/// HTTP status of a refused upgrade, from the socket library's error text
/// (`... HTTP status code: 403`); only the labelled number counts.
int? upgradeStatusOf(Object e) {
  final inner = e is WebSocketChannelException ? e.inner ?? e : e;
  final m = RegExp(
    r'status code:\s*(\d{3})',
    caseSensitive: false,
  ).firstMatch('$inner');
  return m == null ? null : int.parse(m[1]!);
}
