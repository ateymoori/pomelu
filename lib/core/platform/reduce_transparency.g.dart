// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reduce_transparency.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// iOS's Reduce Transparency setting, which Flutter does not expose; false
/// elsewhere. Liquid Glass turns solid while it is on.

@ProviderFor(reduceTransparency)
final reduceTransparencyProvider = ReduceTransparencyProvider._();

/// iOS's Reduce Transparency setting, which Flutter does not expose; false
/// elsewhere. Liquid Glass turns solid while it is on.

final class ReduceTransparencyProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// iOS's Reduce Transparency setting, which Flutter does not expose; false
  /// elsewhere. Liquid Glass turns solid while it is on.
  ReduceTransparencyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reduceTransparencyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reduceTransparencyHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return reduceTransparency(ref);
  }
}

String _$reduceTransparencyHash() =>
    r'bf3e5bae6eea1ba6f3cbd8d8c62a78890a19d2b9';
