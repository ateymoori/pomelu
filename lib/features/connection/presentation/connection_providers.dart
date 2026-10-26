import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/secret_store.dart';
import '../../../core/utils/app_logger.dart';
import '../../../hermes/api/hermes_api.dart';
import '../../../hermes/auth/auth_credential.dart';
import '../../../hermes/client/connection_state.dart';
import '../../../hermes/client/hermes_client.dart';
import '../../../hermes/hermes_log.dart';
import '../../../hermes/requests/server_request_router.dart';
import '../../settings/domain/preference_keys.dart';
import '../data/connection_service.dart';
import '../data/credential_storage.dart';
import '../data/gateway_settings.dart';
import '../domain/gateway_config.dart';

export 'connection_supervisor.dart';

part 'connection_providers.g.dart';

@Riverpod(keepAlive: true)
SecureCredentialStorage credentialStorage(Ref ref) =>
    SecureCredentialStorage(ref.watch(secretStoreProvider));

@Riverpod(keepAlive: true)
ConnectionService connectionService(Ref ref) =>
    const GatewayConnectionService();

/// Loaded before `runApp`; overridden in main.dart.
final initialCredentialProvider = Provider<AuthCredential>(
  (ref) =>
      throw UnimplementedError('initialCredentialProvider must be overridden'),
);

/// The stored gateway settings; null until the user configures one.
@Riverpod(keepAlive: true)
class GatewayConfigNotifier extends _$GatewayConfigNotifier {
  KeyValueStore get _kv => ref.read(keyValueStoreProvider);

  @override
  GatewayConfig? build() => readGatewayConfig(_kv);

  /// Stores [config] with its URL normalized, as a later launch reads it.
  Future<void> save(GatewayConfig config) async {
    final normalized = config.copyWith(url: config.normalizedUrl);
    await _kv.setString(PreferenceKeys.gatewayUrl, normalized.url);
    await _kv.setString(PreferenceKeys.gatewayAuthMode, config.authMode.name);
    await _kv.setString(PreferenceKeys.gatewayUsername, config.username);
    state = normalized;
  }

  /// Forgets the gateway and its secrets.
  Future<void> clear() async {
    await _kv.remove(PreferenceKeys.gatewayUrl);
    await _kv.remove(PreferenceKeys.gatewayAuthMode);
    await _kv.remove(PreferenceKeys.gatewayUsername);
    await ref.read(credentialStorageProvider).savePassword(null);
    await ref.read(credentialProvider.notifier).set(const NoCredential());
    state = null;
  }
}

/// The live credential of the configured gateway.
@Riverpod(keepAlive: true)
class CredentialNotifier extends _$CredentialNotifier {
  @override
  AuthCredential build() => ref.read(initialCredentialProvider);

  Future<void> set(AuthCredential c) async {
    state = c;
    await ref.read(credentialStorageProvider).save(c);
  }

  /// Takes the stored credential: the background check may have renewed
  /// it while the app was away, and the old refresh token is spent.
  Future<void> reload() async {
    final stored = await ref.read(credentialStorageProvider).load();
    if (ref.mounted && !stored.isEmpty && stored != state) state = stored;
  }

  /// Takes a credential a client renewed, unless it belongs to another
  /// gateway than the one held now: a client of the gateway the app is
  /// leaving must not overwrite the new one's credential.
  Future<void> rotate(AuthCredential c) async {
    final held = state.origin;
    if (held.isNotEmpty && c.origin.isNotEmpty && held != c.origin) {
      log.w('dropped a renewed credential of another gateway');
      return;
    }
    await set(c);
  }
}

/// One client per gateway address, connected at once; rebuilt (the old one
/// disposed) when the address changes.
@Riverpod(keepAlive: true)
HermesClient? hermesClient(Ref ref) {
  final uri = ref.watch(gatewayConfigProvider.select((c) => c?.uri));
  if (uri == null) return null;
  final client = HermesClient(
    baseUrl: uri,
    // A disposed provider throws on read; the client types that.
    credential: () => ref.read(credentialProvider),
    onCredentialRotated: (c) async {
      if (ref.mounted) await ref.read(credentialProvider.notifier).rotate(c);
    },
    log: (m, [e]) =>
        log.w('hermes: ${redactSecrets(m)}', error: safeErrorText(e)),
  );
  ref.onDispose(() => unawaited(client.dispose()));
  unawaited(client.connect());
  return client;
}

/// The questions the agent is blocked on; null with no gateway.
@Riverpod(keepAlive: true)
ServerRequestRouter? serverRequestRouter(Ref ref) =>
    ref.watch(hermesClientProvider)?.requests;

@Riverpod(keepAlive: true)
HermesApi? hermesApi(Ref ref) {
  final c = ref.watch(hermesClientProvider);
  return c == null ? null : HermesApi(c);
}

/// Connection state, seeded with the current value.
@Riverpod(keepAlive: true)
Stream<HermesConnectionState> connectionState(Ref ref) async* {
  final client = ref.watch(hermesClientProvider);
  if (client == null) {
    yield const Disconnected();
    return;
  }
  yield client.state;
  yield* client.states;
}

/// Network changes, a provider of its own so tests can feed it.
final connectivityChangesProvider = Provider<Stream<List<ConnectivityResult>>>(
  (ref) => Connectivity().onConnectivityChanged,
);
