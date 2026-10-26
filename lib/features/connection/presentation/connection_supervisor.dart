import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/app_logger.dart';
import '../../../hermes/auth/auth_credential.dart';
import '../../../hermes/client/connection_state.dart';
import '../../../hermes/client/hermes_client.dart';
import '../../../hermes/hermes_constants.dart';
import '../../../hermes/hermes_log.dart';
import '../domain/gateway_config.dart';
import 'connection_providers.dart';

part 'connection_supervisor.g.dart';

/// Reconnects on network change and app resume, and signs in again with
/// the saved password when the gateway refuses a stale token.
///
/// A network change during a dial or a sign-in is left alone (it would
/// tear the fresh socket down); while connected only a dead socket is
/// redialled. Silent re-sign-ins are capped at [AppConfig.reauthMaxAttempts]
/// in a row on a doubling [AppConfig.reauthBackoff], so a gateway that takes
/// the password and then refuses the token cannot loop. A re-sign-in for a
/// client that is gone, or no longer `AuthRequired`, does nothing.
@Riverpod(keepAlive: true)
class ConnectionSupervisor extends _$ConnectionSupervisor {
  AppLifecycleListener? _lifecycle;

  /// Bumped on every build: a re-sign-in of an older one is stale.
  int _epoch = 0;
  bool _reauthInFlight = false;
  int _reauthAttempts = 0;

  /// The credential refused last; a new one is dialled as it is.
  String _rejected = '';

  @override
  void build() {
    final client = ref.watch(hermesClientProvider);
    final epoch = ++_epoch;
    _reauthAttempts = 0;
    _reauthInFlight = false;
    _rejected = '';
    if (client == null) return;
    final net = ref
        .watch(connectivityChangesProvider)
        .map((results) => results.toSet())
        .distinct(setEquals)
        .skip(1)
        .listen(
          (networks) => unawaited(_onNetworkChange(client, networks)),
          onError: (Object e) =>
              log.w('connectivity stream failed', error: safeErrorText(e)),
        );
    _lifecycle = AppLifecycleListener(
      onResume: () => unawaited(_onResume(client)),
    );
    final stateSub = client.states.listen((s) {
      if (s is Connected) _reauthAttempts = 0;
      if (s is AuthRequired) {
        _rejected = _key(ref.read(credentialProvider));
        unawaited(_tryReauth(client, epoch));
      }
    });
    ref.onDispose(() {
      unawaited(net.cancel());
      _lifecycle?.dispose();
      unawaited(stateSub.cancel());
    });
  }

  static String _key(AuthCredential c) => switch (c) {
    BearerCredential(:final accessToken) => 'bearer:$accessToken',
    SessionTokenCredential(:final token) => 'token:$token',
    NoCredential() => '',
  };

  Future<void> _onNetworkChange(
    HermesClient client,
    Set<ConnectivityResult> networks,
  ) async {
    if (networks.every((r) => r == ConnectivityResult.none)) return;
    try {
      switch (client.state) {
        case Connecting() || AuthRequired():
          return;
        case Connected():
          if (!await client.probeAlive()) await client.reconnectNow();
        case Reconnecting() || Disconnected():
          await client.reconnectNow();
      }
    } on Object catch (e, st) {
      log.w(
        'reconnect on network change failed',
        error: safeErrorText(e),
        stackTrace: st,
      );
    }
  }

  Future<void> _onResume(HermesClient client) async {
    try {
      if (!client.isConnected || !await client.probeAlive()) {
        await client.reconnectNow();
      }
    } on Object catch (e, st) {
      log.w(
        'reconnect on resume failed',
        error: safeErrorText(e),
        stackTrace: st,
      );
    }
  }

  bool _current(HermesClient client, int epoch) =>
      ref.mounted && epoch == _epoch && client.state is AuthRequired;

  Future<void> _tryReauth(HermesClient client, int epoch) async {
    if (_reauthInFlight) return;
    if (_reauthAttempts >= AppConfig.reauthMaxAttempts) {
      log.w('re-auth gave up after $_reauthAttempts attempts');
      return;
    }
    final attempt = _reauthAttempts++;
    _reauthInFlight = true;
    try {
      if (attempt > 0) {
        await Future<void>.delayed(
          AppConfig.reauthBackoff * (1 << (attempt - 1)),
        );
        if (!_current(client, epoch)) return;
      }
      await _reauth(client, epoch);
    } on Object catch (e, st) {
      log.w('re-auth failed', error: safeErrorText(e), stackTrace: st);
    } finally {
      if (epoch == _epoch) _reauthInFlight = false;
    }
  }

  Future<void> _reauth(HermesClient client, int epoch) async {
    final config = ref.read(gatewayConfigProvider);
    final cred = ref.read(credentialProvider);
    final uri = config?.uri;
    if (config == null || uri == null) return;
    final service = ref.read(connectionServiceProvider);
    if (cred is BearerCredential || config.authMode == AuthMode.basic) {
      final password = await ref.read(credentialStorageProvider).loadPassword();
      if (!_current(client, epoch)) return;
      if (password == null || config.username.isEmpty) return;
      final fresh = await service.signInBasic(
        base: uri,
        provider: cred is BearerCredential && cred.provider.isNotEmpty
            ? cred.provider
            : HermesProtocol.basicProvider,
        username: config.username,
        password: password,
      );
      if (!_current(client, epoch)) return;
      await ref.read(credentialProvider.notifier).set(fresh);
      await client.connect();
    } else if (cred is SessionTokenCredential && _key(cred) != _rejected) {
      // Not refused yet (the user pasted it): dial with it first.
      await client.connect();
    } else if (await client.rediscoverSessionToken() &&
        _current(client, epoch)) {
      // A restarted dashboard shows a new token on its index page; the
      // client kept it.
      await client.connect();
    }
  }

  /// Manual retry, or the nudge after Save: the re-auth count starts over.
  /// [cycle] (a new credential, same gateway) redials a live socket, which
  /// still runs on the old login.
  Future<void> reconnect({bool cycle = false}) async {
    final client = ref.read(hermesClientProvider);
    if (client == null) return;
    _reauthAttempts = 0;
    if (cycle && client.state is! Disconnected) {
      await client.reconnectNow();
    } else if (client.state is AuthRequired) {
      await _tryReauth(client, _epoch);
    } else {
      await client.connect();
    }
  }
}
