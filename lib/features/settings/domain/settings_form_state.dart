import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../hermes/auth/auth_credential.dart';
import '../../../hermes/client/hermes_client.dart';
import '../../connection/domain/connection_probe.dart';
import '../../connection/domain/gateway_config.dart';

part 'settings_form_state.freezed.dart';

/// What the credential held by the form stands for.
enum CredentialKind { none, token, user }

/// Everything the settings form edits, probes and reports. [error] is the
/// caught failure itself; the widget words it.
@freezed
abstract class SettingsFormState with _$SettingsFormState {
  const SettingsFormState._();

  const factory SettingsFormState({
    @Default('') String url,
    @Default('') String username,
    @Default('') String password,
    @Default('') String token,
    ProbeResult? probe,
    @Default(false) bool probing,
    @Default(false) bool signingIn,
    @Default(false) bool testing,
    @Default(false) bool saving,
    TestResult? testResult,
    String? signedInAs,
    Object? error,
    AuthCredential? pendingCredential,

    /// The stored auth mode while the form shows the saved gateway; it
    /// stands while the probe has no answer.
    @Default(AuthMode.none) AuthMode savedAuthMode,
  }) = _SettingsFormState;

  /// The held credential if it fits the gateway's mode (a bearer when
  /// gated, a session token when not). Before the gateway answered nothing
  /// is known, so it stands as it is: a save while the gateway is down keeps
  /// the account.
  AuthCredential? get effectiveCredential {
    final c = pendingCredential;
    if (c == null || c.isEmpty) return null;
    if (!reachable) return c;
    if (gated) return c is BearerCredential ? c : null;
    return c is SessionTokenCredential ? c : null;
  }

  /// The auth mode the probe and the credential imply; without an answer,
  /// the credential's, else [savedAuthMode].
  AuthMode get authMode {
    if (reachable) {
      if (gated) return AuthMode.basic;
      return effectiveCredential is SessionTokenCredential
          ? AuthMode.token
          : AuthMode.none;
    }
    return switch (effectiveCredential) {
      BearerCredential() => AuthMode.basic,
      SessionTokenCredential() => AuthMode.token,
      _ => savedAuthMode,
    };
  }

  GatewayConfig get config => GatewayConfig(
    url: url.trim(),
    authMode: authMode,
    username: username.trim(),
  );

  /// Plain `http://` to a host on the internet: warn, and confirm before a
  /// password goes out.
  bool get insecure => config.insecure;

  bool get urlValid => config.uri != null;

  bool get reachable => probe?.reachable ?? false;

  bool get gated => probe?.gated ?? false;

  bool get gatewayTooOld =>
      reachable && isGatewayTooOld(probe?.status?.version ?? '');

  /// Gated by a provider this app cannot drive.
  bool get authUnsupported => gated && probe?.passwordProvider == null;

  CredentialKind get credentialKind => switch (effectiveCredential) {
    BearerCredential() => CredentialKind.user,
    SessionTokenCredential() => CredentialKind.token,
    _ => CredentialKind.none,
  };

  /// Un-gated gateway whose token could not be discovered: paste one.
  bool get needsManualToken =>
      reachable &&
      !gated &&
      effectiveCredential == null &&
      testResult != null &&
      !testResult!.ok;

  /// Whether Save would change something; closing the page asks first.
  bool isDirty({
    required GatewayConfig? saved,
    required AuthCredential credential,
  }) {
    final baseline =
        saved ?? const GatewayConfig(url: AppConfig.defaultGatewayUrl);
    final storedToken = credential is SessionTokenCredential
        ? credential.token
        : '';
    return config.normalizedUrl != baseline.normalizedUrl ||
        username.trim() != baseline.username ||
        password.isNotEmpty ||
        token.trim() != storedToken ||
        changesCredential(credential);
  }

  /// Whether Save would replace the stored [credential].
  bool changesCredential(AuthCredential credential) =>
      _key(effectiveCredential) != _key(credential);

  static String _key(AuthCredential? c) => switch (c) {
    BearerCredential(:final accessToken, :final username) =>
      'user:$username:$accessToken',
    SessionTokenCredential(:final token) when token.isNotEmpty =>
      'token:$token',
    _ => '',
  };

  /// This form holding the [stored] sign-in of the [saved] gateway, or none
  /// when [other] says the form names another gateway.
  SettingsFormState withStored(
    GatewayConfig? saved,
    AuthCredential stored, {
    bool other = false,
  }) => other
      ? copyWith(
          pendingCredential: null,
          signedInAs: null,
          token: '',
          savedAuthMode: AuthMode.none,
        )
      : copyWith(
          pendingCredential: stored.isEmpty ? null : stored,
          signedInAs: stored is BearerCredential && stored.username.isNotEmpty
              ? stored.username
              : null,
          token: stored is SessionTokenCredential ? stored.token : '',
          savedAuthMode: saved?.authMode ?? AuthMode.none,
        );

  /// This form with no sign-in held, typed or adopted.
  SettingsFormState withoutSignIn() => copyWith(
    pendingCredential: null,
    signedInAs: null,
    password: '',
    token: '',
    testResult: null,
    error: null,
  );

  /// A request in flight; actions stay disabled.
  bool get busy => probing || signingIn || testing || saving;

  /// A request the user started is in flight: the page stays open. A probe
  /// only reads; closing drops it.
  bool get blocksLeaving => signingIn || testing || saving;

  /// Secrets stay out of logs and debuggers.
  @override
  String toString() =>
      'SettingsFormState(url: $url, username: $username, '
      'password: ${password.isEmpty ? '' : '***'}, '
      'token: ${token.isEmpty ? '' : '***'}, probe: $probe, '
      'busy: $busy, testResult: $testResult, signedInAs: $signedInAs, '
      'error: $error, pendingCredential: $pendingCredential)';
}
