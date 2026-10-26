// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_opener.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The system's link handler, out of the app. Tests put their own.

@ProviderFor(linkLauncher)
final linkLauncherProvider = LinkLauncherProvider._();

/// The system's link handler, out of the app. Tests put their own.

final class LinkLauncherProvider
    extends $FunctionalProvider<LinkLauncher, LinkLauncher, LinkLauncher>
    with $Provider<LinkLauncher> {
  /// The system's link handler, out of the app. Tests put their own.
  LinkLauncherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkLauncherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkLauncherHash();

  @$internal
  @override
  $ProviderElement<LinkLauncher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LinkLauncher create(Ref ref) {
    return linkLauncher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkLauncher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkLauncher>(value),
    );
  }
}

String _$linkLauncherHash() => r'c56455dec6eb43b49dcf5411591d9c6f089d0269';
