// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_supervisor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reconnects on network change and app resume, and signs in again with
/// the saved password when the gateway refuses a stale token.
///
/// A network change during a dial or a sign-in is left alone (it would
/// tear the fresh socket down); while connected only a dead socket is
/// redialled. Silent re-sign-ins are capped at [AppConfig.reauthMaxAttempts]
/// in a row on a doubling [AppConfig.reauthBackoff], so a gateway that takes
/// the password and then refuses the token cannot loop. A re-sign-in for a
/// client that is gone, or no longer `AuthRequired`, does nothing.

@ProviderFor(ConnectionSupervisor)
final connectionSupervisorProvider = ConnectionSupervisorProvider._();

/// Reconnects on network change and app resume, and signs in again with
/// the saved password when the gateway refuses a stale token.
///
/// A network change during a dial or a sign-in is left alone (it would
/// tear the fresh socket down); while connected only a dead socket is
/// redialled. Silent re-sign-ins are capped at [AppConfig.reauthMaxAttempts]
/// in a row on a doubling [AppConfig.reauthBackoff], so a gateway that takes
/// the password and then refuses the token cannot loop. A re-sign-in for a
/// client that is gone, or no longer `AuthRequired`, does nothing.
final class ConnectionSupervisorProvider
    extends $NotifierProvider<ConnectionSupervisor, void> {
  /// Reconnects on network change and app resume, and signs in again with
  /// the saved password when the gateway refuses a stale token.
  ///
  /// A network change during a dial or a sign-in is left alone (it would
  /// tear the fresh socket down); while connected only a dead socket is
  /// redialled. Silent re-sign-ins are capped at [AppConfig.reauthMaxAttempts]
  /// in a row on a doubling [AppConfig.reauthBackoff], so a gateway that takes
  /// the password and then refuses the token cannot loop. A re-sign-in for a
  /// client that is gone, or no longer `AuthRequired`, does nothing.
  ConnectionSupervisorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionSupervisorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionSupervisorHash();

  @$internal
  @override
  ConnectionSupervisor create() => ConnectionSupervisor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$connectionSupervisorHash() =>
    r'9cb34629142c64d7652a1b07a7bc4391ed972d90';

/// Reconnects on network change and app resume, and signs in again with
/// the saved password when the gateway refuses a stale token.
///
/// A network change during a dial or a sign-in is left alone (it would
/// tear the fresh socket down); while connected only a dead socket is
/// redialled. Silent re-sign-ins are capped at [AppConfig.reauthMaxAttempts]
/// in a row on a doubling [AppConfig.reauthBackoff], so a gateway that takes
/// the password and then refuses the token cannot loop. A re-sign-in for a
/// client that is gone, or no longer `AuthRequired`, does nothing.

abstract class _$ConnectionSupervisor extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
