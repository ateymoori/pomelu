// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(credentialStorage)
final credentialStorageProvider = CredentialStorageProvider._();

final class CredentialStorageProvider
    extends
        $FunctionalProvider<
          SecureCredentialStorage,
          SecureCredentialStorage,
          SecureCredentialStorage
        >
    with $Provider<SecureCredentialStorage> {
  CredentialStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'credentialStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$credentialStorageHash();

  @$internal
  @override
  $ProviderElement<SecureCredentialStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SecureCredentialStorage create(Ref ref) {
    return credentialStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureCredentialStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureCredentialStorage>(value),
    );
  }
}

String _$credentialStorageHash() => r'b05460cd727cbee9c916098ce93370bc8147098d';

@ProviderFor(connectionService)
final connectionServiceProvider = ConnectionServiceProvider._();

final class ConnectionServiceProvider
    extends
        $FunctionalProvider<
          ConnectionService,
          ConnectionService,
          ConnectionService
        >
    with $Provider<ConnectionService> {
  ConnectionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionServiceHash();

  @$internal
  @override
  $ProviderElement<ConnectionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConnectionService create(Ref ref) {
    return connectionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionService>(value),
    );
  }
}

String _$connectionServiceHash() => r'4b0362de5a27b2b878ca73cfd1613175796019ce';

/// The stored gateway settings; null until the user configures one.

@ProviderFor(GatewayConfigNotifier)
final gatewayConfigProvider = GatewayConfigNotifierProvider._();

/// The stored gateway settings; null until the user configures one.
final class GatewayConfigNotifierProvider
    extends $NotifierProvider<GatewayConfigNotifier, GatewayConfig?> {
  /// The stored gateway settings; null until the user configures one.
  GatewayConfigNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gatewayConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gatewayConfigNotifierHash();

  @$internal
  @override
  GatewayConfigNotifier create() => GatewayConfigNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GatewayConfig? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GatewayConfig?>(value),
    );
  }
}

String _$gatewayConfigNotifierHash() =>
    r'cae4b2833ea3784d322ed2b42468e54c52abd2a8';

/// The stored gateway settings; null until the user configures one.

abstract class _$GatewayConfigNotifier extends $Notifier<GatewayConfig?> {
  GatewayConfig? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GatewayConfig?, GatewayConfig?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GatewayConfig?, GatewayConfig?>,
              GatewayConfig?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The live credential of the configured gateway.

@ProviderFor(CredentialNotifier)
final credentialProvider = CredentialNotifierProvider._();

/// The live credential of the configured gateway.
final class CredentialNotifierProvider
    extends $NotifierProvider<CredentialNotifier, AuthCredential> {
  /// The live credential of the configured gateway.
  CredentialNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'credentialProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$credentialNotifierHash();

  @$internal
  @override
  CredentialNotifier create() => CredentialNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthCredential value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthCredential>(value),
    );
  }
}

String _$credentialNotifierHash() =>
    r'a255a3a6dc894d01a8d96b74d67fcc7cc266bd8c';

/// The live credential of the configured gateway.

abstract class _$CredentialNotifier extends $Notifier<AuthCredential> {
  AuthCredential build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthCredential, AuthCredential>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthCredential, AuthCredential>,
              AuthCredential,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// One client per gateway address, connected at once; rebuilt (the old one
/// disposed) when the address changes.

@ProviderFor(hermesClient)
final hermesClientProvider = HermesClientProvider._();

/// One client per gateway address, connected at once; rebuilt (the old one
/// disposed) when the address changes.

final class HermesClientProvider
    extends $FunctionalProvider<HermesClient?, HermesClient?, HermesClient?>
    with $Provider<HermesClient?> {
  /// One client per gateway address, connected at once; rebuilt (the old one
  /// disposed) when the address changes.
  HermesClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hermesClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hermesClientHash();

  @$internal
  @override
  $ProviderElement<HermesClient?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HermesClient? create(Ref ref) {
    return hermesClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HermesClient? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HermesClient?>(value),
    );
  }
}

String _$hermesClientHash() => r'c38ff8bb16b90620b96b991b83a870d75f138c0d';

/// The questions the agent is blocked on; null with no gateway.

@ProviderFor(serverRequestRouter)
final serverRequestRouterProvider = ServerRequestRouterProvider._();

/// The questions the agent is blocked on; null with no gateway.

final class ServerRequestRouterProvider
    extends
        $FunctionalProvider<
          ServerRequestRouter?,
          ServerRequestRouter?,
          ServerRequestRouter?
        >
    with $Provider<ServerRequestRouter?> {
  /// The questions the agent is blocked on; null with no gateway.
  ServerRequestRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverRequestRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverRequestRouterHash();

  @$internal
  @override
  $ProviderElement<ServerRequestRouter?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServerRequestRouter? create(Ref ref) {
    return serverRequestRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerRequestRouter? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerRequestRouter?>(value),
    );
  }
}

String _$serverRequestRouterHash() =>
    r'5d236453ab42fe10ca6c85eec35a2b2619b0e482';

@ProviderFor(hermesApi)
final hermesApiProvider = HermesApiProvider._();

final class HermesApiProvider
    extends $FunctionalProvider<HermesApi?, HermesApi?, HermesApi?>
    with $Provider<HermesApi?> {
  HermesApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hermesApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hermesApiHash();

  @$internal
  @override
  $ProviderElement<HermesApi?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HermesApi? create(Ref ref) {
    return hermesApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HermesApi? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HermesApi?>(value),
    );
  }
}

String _$hermesApiHash() => r'5b51b1ad3326a6f73822bf53f39b2a9329e4eeb2';

/// Connection state, seeded with the current value.

@ProviderFor(connectionState)
final connectionStateProvider = ConnectionStateProvider._();

/// Connection state, seeded with the current value.

final class ConnectionStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<HermesConnectionState>,
          HermesConnectionState,
          Stream<HermesConnectionState>
        >
    with
        $FutureModifier<HermesConnectionState>,
        $StreamProvider<HermesConnectionState> {
  /// Connection state, seeded with the current value.
  ConnectionStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionStateHash();

  @$internal
  @override
  $StreamProviderElement<HermesConnectionState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<HermesConnectionState> create(Ref ref) {
    return connectionState(ref);
  }
}

String _$connectionStateHash() => r'19ff7c4f0c4ff2ad2845d602f075cd1874a85106';
