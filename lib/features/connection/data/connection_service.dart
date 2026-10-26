import 'dart:async';

import '../../../core/config/app_config.dart';
import '../../../core/utils/app_logger.dart';
import '../../../hermes/auth/auth_credential.dart';
import '../../../hermes/auth/hermes_auth.dart';
import '../../../hermes/client/connection_state.dart';
import '../../../hermes/client/hermes_client.dart';
import '../../../hermes/hermes_failure.dart';
import '../../../hermes/hermes_log.dart';
import '../../../hermes/transport/hermes_http.dart';
import '../domain/connection_probe.dart';

/// Builds the throwaway client "Test connection" dials with.
typedef TestClientFactory = HermesClient Function(
  Uri base,
  AuthCredential credential,
);

/// One-off gateway calls of the settings page; the seam its tests fake.
abstract interface class ConnectionService {
  /// What the gateway at [base] says about itself, before any sign-in.
  Future<ProbeResult> probe(Uri base);

  /// The session token an un-gated gateway shows on `/`, or null.
  Future<SessionTokenCredential?> discoverToken(Uri base);

  /// Username and password sign-in.
  Future<BearerCredential> signInBasic({
    required Uri base,
    required String provider,
    required String username,
    required String password,
  });

  /// The HTTP leg, then a real socket dial that must reach `gateway.ready`.
  Future<TestResult> test(Uri base, AuthCredential cred);
}

/// [ConnectionService] against a real gateway.
class GatewayConnectionService implements ConnectionService {
  /// The connection test dials through [clientFactory].
  const GatewayConnectionService({TestClientFactory? clientFactory})
    : _clientFactory = clientFactory ?? _defaultClient;

  final TestClientFactory _clientFactory;

  static HermesClient _defaultClient(Uri base, AuthCredential cred) =>
      HermesClient(
        baseUrl: base,
        credential: () => cred,
        onCredentialRotated: (_) async {},
      );

  /// [op] with an HTTP client for [base], closed afterwards.
  Future<T> _withAuth<T>(
    Uri base,
    Future<T> Function(HermesAuth auth) op, [
    AuthCredential cred = const NoCredential(),
  ]) async {
    final http = HermesHttp(baseUrl: base, credential: () => cred);
    try {
      return await op(HermesAuth(http));
    } finally {
      http.close();
    }
  }

  @override
  Future<ProbeResult> probe(Uri base) => _withAuth(base, (auth) async {
    try {
      final status = await auth.status();
      var providers = const <AuthProvider>[];
      if (status.authRequired) {
        try {
          providers = await auth.providers();
        } on HermesFailure catch (e) {
          // The form still works with the default provider.
          log.w('auth providers lookup failed', error: safeErrorText(e));
        }
      }
      return ProbeResult(reachable: true, status: status, providers: providers);
    } on HermesFailure catch (e) {
      return ProbeResult(reachable: false, failure: e);
    }
  });

  @override
  Future<SessionTokenCredential?> discoverToken(Uri base) =>
      _withAuth(base, (auth) async {
        try {
          return await auth.discoverSessionCredential();
        } on HermesFailure catch (e) {
          log.w('session token discovery failed', error: safeErrorText(e));
          return null;
        }
      });

  @override
  Future<BearerCredential> signInBasic({
    required Uri base,
    required String provider,
    required String username,
    required String password,
  }) => _withAuth(
    base,
    (auth) => auth.passwordLogin(
      provider: provider,
      username: username,
      password: password,
    ),
  );

  @override
  Future<TestResult> test(Uri base, AuthCredential cred) async {
    final String version;
    try {
      version = (await _withAuth(base, (a) => a.status(), cred)).version;
    } on HermesFailure catch (e) {
      return TestResult(httpOk: false, wsOk: false, failure: e);
    }
    final client = _clientFactory(base, cred);
    TestResult wsFailed(HermesFailure failure) => TestResult(
      httpOk: true,
      wsOk: false,
      version: version,
      failure: failure,
      detail: client.lastCloseReason,
    );
    final done = Completer<TestResult>();
    void finish(TestResult r) {
      if (!done.isCompleted) done.complete(r);
    }

    final sub = client.states.listen(
      (s) => switch (s) {
        Connected() => finish(
          TestResult(httpOk: true, wsOk: true, version: version),
        ),
        AuthRequired(:final failure) => finish(
          wsFailed(failure ?? const UnauthorizedFailure('credential rejected')),
        ),
        Disconnected(:final failure?) => finish(wsFailed(failure)),
        // The first dial failed; the close says why.
        Reconnecting() => finish(
          wsFailed(
            client.lastFailure ?? const NetworkFailure('socket dropped'),
          ),
        ),
        _ => null,
      },
    );
    try {
      unawaited(client.connect());
      return await done.future.timeout(
        AppConfig.connectionTestBudget,
        onTimeout: () => wsFailed(const NetworkFailure('timeout')),
      );
    } finally {
      await sub.cancel();
      await client.dispose();
    }
  }
}
