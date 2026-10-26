import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../hermes/auth/hermes_auth.dart';
import '../../../hermes/hermes_failure.dart';
import '../../../hermes/models/gateway_status.dart';

part 'connection_probe.freezed.dart';

/// What we learn about a gateway URL before signing in.
@freezed
abstract class ProbeResult with _$ProbeResult {
  const ProbeResult._();

  const factory ProbeResult({
    required bool reachable,
    GatewayStatus? status,
    @Default(<AuthProvider>[]) List<AuthProvider> providers,

    /// Why the gateway could not be reached; the screen words it.
    HermesFailure? failure,
  }) = _ProbeResult;

  bool get gated => status?.authRequired ?? false;

  AuthProvider? get passwordProvider =>
      providers.where((p) => p.supportsPassword).firstOrNull;
}

/// Outcome of "Test connection": both HTTP and WebSocket legs.
@freezed
abstract class TestResult with _$TestResult {
  const TestResult._();

  const factory TestResult({
    required bool httpOk,
    required bool wsOk,
    String? version,

    /// Why a leg failed; the screen words it.
    HermesFailure? failure,

    /// How the socket closed, as the transport saw it (`HTTP 403`,
    /// `close 4401`, `timeout`), secrets taken out; null when it said nothing.
    String? detail,
  }) = _TestResult;

  bool get ok => httpOk && wsOk;
}
