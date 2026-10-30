// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_registration.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// This phone with the gateway's Pomelu plugin: registered on each
/// connection while notifications are on and allowed, removed when they are
/// turned off. On screen and away are told to the plugin, which pushes only
/// while the app is away.

@ProviderFor(PushRegistration)
final pushRegistrationProvider = PushRegistrationProvider._();

/// This phone with the gateway's Pomelu plugin: registered on each
/// connection while notifications are on and allowed, removed when they are
/// turned off. On screen and away are told to the plugin, which pushes only
/// while the app is away.
final class PushRegistrationProvider
    extends $NotifierProvider<PushRegistration, PushStatus> {
  /// This phone with the gateway's Pomelu plugin: registered on each
  /// connection while notifications are on and allowed, removed when they are
  /// turned off. On screen and away are told to the plugin, which pushes only
  /// while the app is away.
  PushRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushRegistrationHash();

  @$internal
  @override
  PushRegistration create() => PushRegistration();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushStatus>(value),
    );
  }
}

String _$pushRegistrationHash() => r'ec8726101e918bd6825067af9053115653518f18';

/// This phone with the gateway's Pomelu plugin: registered on each
/// connection while notifications are on and allowed, removed when they are
/// turned off. On screen and away are told to the plugin, which pushes only
/// while the app is away.

abstract class _$PushRegistration extends $Notifier<PushStatus> {
  PushStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PushStatus, PushStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PushStatus, PushStatus>,
              PushStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
