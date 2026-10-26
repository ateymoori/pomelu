import 'package:freezed_annotation/freezed_annotation.dart';

import '../hermes_constants.dart';
import '../hermes_failure.dart';
import '../models/json_converters.dart';

part 'auth_credential.freezed.dart';
part 'auth_credential.g.dart';

/// The origin of [base] as a credential names it: scheme, lowercase host and
/// port (the default one written out), `https://gw.example.com:443`.
String gatewayOrigin(Uri base) =>
    '${base.scheme}://${base.host.toLowerCase()}:${base.port}';

/// The credential [read] gives, for the gateway at [base] only: an
/// [UnauthorizedFailure] for one bound to another gateway, a
/// [CancelledFailure] when it cannot be read (its owner is gone).
AuthCredential credentialFor(Uri base, AuthCredential Function() read) {
  final AuthCredential cred;
  try {
    cred = read();
  } on HermesFailure {
    rethrow;
  } on Object catch (e) {
    throw CancelledFailure('credential unavailable: ${e.runtimeType}');
  }
  if (!cred.fits(base)) {
    throw const UnauthorizedFailure('credential belongs to another gateway');
  }
  return cred;
}

/// How requests are authenticated against one gateway.
///
/// A credential may be bound to the gateway it was issued by ([origin]); a
/// client for another gateway refuses it ([fits]), so a token never goes to a
/// host that did not issue it, even while the app switches gateways.
sealed class AuthCredential {
  const AuthCredential();

  /// Headers that authenticate one HTTP request.
  Map<String, String> httpHeaders();

  bool get isEmpty;

  /// The [gatewayOrigin] of the gateway that issued this credential, or
  /// empty when it is not bound to one (stored by an older version).
  String get origin;

  /// Whether this credential may be sent to the gateway at [base]: it is
  /// bound to that origin, or to none.
  bool fits(Uri base) => origin.isEmpty || origin == gatewayOrigin(base);
}

/// No credential yet (or the gateway is un-gated and the token is unknown).
final class NoCredential extends AuthCredential {
  const NoCredential();

  @override
  Map<String, String> httpHeaders() => const {};

  @override
  bool get isEmpty => true;

  @override
  String get origin => '';
}

/// Un-gated (loopback) gateway: the per-process dashboard session token.
///
/// Its JSON is what the app stores, so the keys stay as they are.
@freezed
abstract class SessionTokenCredential extends AuthCredential
    with _$SessionTokenCredential {
  const SessionTokenCredential._();

  /// The token of the gateway at [origin]. No loose converters: a stored
  /// token that is no string is unreadable.
  const factory SessionTokenCredential(
    String token, {
    @Default('') String origin,
  }) = _SessionTokenCredential;

  /// Reads a stored credential.
  factory SessionTokenCredential.fromJson(Map<String, dynamic> json) =>
      _$SessionTokenCredentialFromJson(json);

  @override
  Map<String, String> httpHeaders() => {
    HermesProtocol.sessionTokenHeader: token,
  };

  @override
  bool get isEmpty => token.isEmpty;

  @override
  String toString() => 'SessionTokenCredential(***, origin: $origin)';
}

/// Gated gateway: JWT access token from password login (or native flow).
/// The WebSocket needs a ticket minted with it.
///
/// Its JSON is what the app stores, so the keys stay as they are.
@freezed
abstract class BearerCredential extends AuthCredential with _$BearerCredential {
  const BearerCredential._();

  /// A signed-in user's token pair.
  const factory BearerCredential({
    @LooseString() required String accessToken,

    @LooseStringOrNull() String? refreshToken,

    @LooseString() @Default('') String provider,

    @LooseDateTime() DateTime? expiresAt,

    @LooseString() @Default('') String username,

    @LooseString() @Default('') String origin,
  }) = _BearerCredential;

  /// Reads a stored credential.
  factory BearerCredential.fromJson(Map<String, dynamic> json) =>
      _$BearerCredentialFromJson(json);

  @override
  Map<String, String> httpHeaders() => {'Authorization': 'Bearer $accessToken'};

  @override
  bool get isEmpty => accessToken.isEmpty;

  /// The tokens stay out of the text, so a log line, a failure message or a
  /// debugger cannot leak them.
  @override
  String toString() =>
      'BearerCredential(provider: $provider, username: $username, '
      'origin: $origin, expiresAt: $expiresAt, accessToken: ***, '
      'refreshToken: ***)';

  /// Whether [accessToken] expires within [skew] of [now].
  bool needsRefresh(
    DateTime now, {
    Duration skew = HermesTimeouts.refreshSkew,
  }) {
    final e = expiresAt;
    if (e == null) return false;
    return !now.add(skew).isBefore(e);
  }
}
