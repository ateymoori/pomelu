// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_info.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(platformInfo)
final platformInfoProvider = PlatformInfoProvider._();

final class PlatformInfoProvider
    extends $FunctionalProvider<PlatformInfo, PlatformInfo, PlatformInfo>
    with $Provider<PlatformInfo> {
  PlatformInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'platformInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$platformInfoHash();

  @$internal
  @override
  $ProviderElement<PlatformInfo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlatformInfo create(Ref ref) {
    return platformInfo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlatformInfo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlatformInfo>(value),
    );
  }
}

String _$platformInfoHash() => r'0ae720252b5ac7369deba90737c5b4d8cd59f678';
