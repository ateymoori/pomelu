// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_redial_guard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs the [BackgroundRedialBudget] while "Stay connected" is on (without
/// it Android suspends the process and nothing redials). True while the
/// redialling is stopped.

@ProviderFor(BackgroundRedialGuard)
final backgroundRedialGuardProvider = BackgroundRedialGuardProvider._();

/// Runs the [BackgroundRedialBudget] while "Stay connected" is on (without
/// it Android suspends the process and nothing redials). True while the
/// redialling is stopped.
final class BackgroundRedialGuardProvider
    extends $NotifierProvider<BackgroundRedialGuard, bool> {
  /// Runs the [BackgroundRedialBudget] while "Stay connected" is on (without
  /// it Android suspends the process and nothing redials). True while the
  /// redialling is stopped.
  BackgroundRedialGuardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backgroundRedialGuardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backgroundRedialGuardHash();

  @$internal
  @override
  BackgroundRedialGuard create() => BackgroundRedialGuard();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$backgroundRedialGuardHash() =>
    r'0076f01c361154c886755e0195b15f2f795270a8';

/// Runs the [BackgroundRedialBudget] while "Stay connected" is on (without
/// it Android suspends the process and nothing redials). True while the
/// redialling is stopped.

abstract class _$BackgroundRedialGuard extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
