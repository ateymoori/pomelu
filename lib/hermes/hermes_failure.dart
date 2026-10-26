import 'hermes_constants.dart';
import 'hermes_log.dart';

/// Typed failures of the SDK. Presentation maps them to text.
sealed class HermesFailure implements Exception {
  const HermesFailure(this.message, {this.cause});

  /// What went wrong, for logs.
  final String message;

  /// The underlying error or response body, if any; [toString] shows it
  /// with secrets taken out.
  final Object? cause;

  // Written out: `runtimeType` names do not survive obfuscation.
  String get _name => switch (this) {
    OutcomeUnknownFailure() => 'OutcomeUnknownFailure',
    NetworkFailure() => 'NetworkFailure',
    UnauthorizedFailure() => 'UnauthorizedFailure',
    HostRefusedFailure() => 'HostRefusedFailure',
    ForbiddenFailure() => 'ForbiddenFailure',
    ProtocolFailure() => 'ProtocolFailure',
    TitleInUseFailure() => 'TitleInUseFailure',
    ServerFailure() => 'ServerFailure',
    NotSupportedFailure() => 'NotSupportedFailure',
    GatewayTooOldFailure() => 'GatewayTooOldFailure',
    CancelledFailure() => 'CancelledFailure',
  };

  @override
  String toString() => cause == null
      ? '$_name: $message'
      : '$_name: $message (${redactSecrets('$cause')})';
}

/// The gateway could not be reached.
base class NetworkFailure extends HermesFailure {
  /// A network failure.
  const NetworkFailure(super.message, {super.cause});

  /// No gateway is set up.
  static const NetworkFailure notConfigured = NetworkFailure(
    'no gateway configured',
  );

  /// The gateway is set up, but its socket is not up.
  static const NetworkFailure notConnected = NetworkFailure(
    'gateway not connected',
  );
}

/// The request went out, but no answer came: the gateway may have acted on
/// it, so a non-idempotent call must not be resent blindly.
final class OutcomeUnknownFailure extends NetworkFailure {
  /// A failure after the request may have reached the gateway.
  const OutcomeUnknownFailure(super.message, {super.cause});
}

/// 401, or a socket closed with an auth close code.
final class UnauthorizedFailure extends HermesFailure {
  /// An auth rejection.
  const UnauthorizedFailure(super.message, {super.cause});
}

/// 403.
base class ForbiddenFailure extends HermesFailure {
  /// A permission rejection.
  const ForbiddenFailure(super.message, {super.cause});
}

/// The gateway's Host / Origin guard refused the address itself: signing
/// in cannot help, another address can.
final class HostRefusedFailure extends ForbiddenFailure {
  /// A refusal of the address.
  const HostRefusedFailure(super.message, {super.cause});
}

/// A payload of the wrong shape.
final class ProtocolFailure extends HermesFailure {
  /// A malformed payload.
  const ProtocolFailure(super.message, {super.cause});
}

/// A JSON-RPC error ([rpcCode]) or an HTTP error status ([httpStatus]).
base class ServerFailure extends HermesFailure {
  /// A failure the gateway reported.
  const ServerFailure(
    super.message, {
    this.rpcCode,
    this.httpStatus,
    this.data,
    super.cause,
  });

  /// JSON-RPC error code; null for a REST failure.
  final int? rpcCode;

  /// HTTP status; null for a JSON-RPC error.
  final int? httpStatus;

  /// The error's data or the response body.
  final Object? data;
}

/// `session.title` refused a title another session holds.
final class TitleInUseFailure extends ServerFailure {
  /// A title conflict.
  const TitleInUseFailure(super.message, {super.rpcCode, super.data});
}

/// `prompt.submit` refused the turn ([HermesProtocol.errSessionBusy]).
final class SessionBusyFailure extends ServerFailure {
  /// A refused turn; [reason] is the gateway's `data.reason`.
  const SessionBusyFailure(super.message, {this.reason, super.data})
    : super(rpcCode: HermesProtocol.errSessionBusy);

  final String? reason;

  /// The chat is open in another gateway process (a desktop window, a
  /// terminal), rather than the gateway being full.
  bool get openElsewhere => reason == HermesProtocol.sessionNotOwned;
}

/// The gateway has no such route (404): it is older than the feature, so a
/// retry cannot help.
final class NotSupportedFailure extends HermesFailure {
  /// A route this gateway lacks.
  const NotSupportedFailure(super.message, {super.cause});
}

/// The gateway is older than `HermesProtocol.minGatewayVersion`.
final class GatewayTooOldFailure extends HermesFailure {
  /// A gateway of [version], older than [minimum].
  const GatewayTooOldFailure(this.version, this.minimum)
    : super('gateway $version is older than $minimum');

  /// The gateway's version.
  final String version;

  /// The oldest supported version.
  final String minimum;
}

/// The caller cancelled.
final class CancelledFailure extends HermesFailure {
  /// A cancellation.
  const CancelledFailure([super.message = 'cancelled']);
}
