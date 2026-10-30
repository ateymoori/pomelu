// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_bridge.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Push on Android and iOS, none elsewhere.

@ProviderFor(pushBridge)
final pushBridgeProvider = PushBridgeProvider._();

/// Push on Android and iOS, none elsewhere.

final class PushBridgeProvider
    extends $FunctionalProvider<PushBridge, PushBridge, PushBridge>
    with $Provider<PushBridge> {
  /// Push on Android and iOS, none elsewhere.
  PushBridgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushBridgeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushBridgeHash();

  @$internal
  @override
  $ProviderElement<PushBridge> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PushBridge create(Ref ref) {
    return pushBridge(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushBridge value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushBridge>(value),
    );
  }
}

String _$pushBridgeHash() => r'b0e6d4c87e72a7729cb46f41d7f3d7c64c715310';
