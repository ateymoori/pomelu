// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_metadata.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The HTTP client of the link titles. Tests put a stub.

@ProviderFor(linkMetadataClient)
final linkMetadataClientProvider = LinkMetadataClientProvider._();

/// The HTTP client of the link titles. Tests put a stub.

final class LinkMetadataClientProvider
    extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// The HTTP client of the link titles. Tests put a stub.
  LinkMetadataClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkMetadataClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkMetadataClientHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return linkMetadataClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$linkMetadataClientHash() =>
    r'ff962ee31bdcf6ac9904733fa43b6a33c21eb295';

/// The title of a YouTube video, from its public oEmbed document [oEmbed]:
/// one small GET, no key, nothing else fetched. Null when it has none.
///
/// Kept for the life of the process; a failed one is kept for
/// [AppConfig.linkTitleRetryAfter], so a streaming reply that rebuilds its
/// card does not ask again on every token.

@ProviderFor(linkTitle)
final linkTitleProvider = LinkTitleFamily._();

/// The title of a YouTube video, from its public oEmbed document [oEmbed]:
/// one small GET, no key, nothing else fetched. Null when it has none.
///
/// Kept for the life of the process; a failed one is kept for
/// [AppConfig.linkTitleRetryAfter], so a streaming reply that rebuilds its
/// card does not ask again on every token.

final class LinkTitleProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The title of a YouTube video, from its public oEmbed document [oEmbed]:
  /// one small GET, no key, nothing else fetched. Null when it has none.
  ///
  /// Kept for the life of the process; a failed one is kept for
  /// [AppConfig.linkTitleRetryAfter], so a streaming reply that rebuilds its
  /// card does not ask again on every token.
  LinkTitleProvider._({
    required LinkTitleFamily super.from,
    required Uri super.argument,
  }) : super(
         retry: null,
         name: r'linkTitleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$linkTitleHash();

  @override
  String toString() {
    return r'linkTitleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as Uri;
    return linkTitle(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LinkTitleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$linkTitleHash() => r'fbe339e01fcf1d81134b5a0d278f659f7cf6b83b';

/// The title of a YouTube video, from its public oEmbed document [oEmbed]:
/// one small GET, no key, nothing else fetched. Null when it has none.
///
/// Kept for the life of the process; a failed one is kept for
/// [AppConfig.linkTitleRetryAfter], so a streaming reply that rebuilds its
/// card does not ask again on every token.

final class LinkTitleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, Uri> {
  LinkTitleFamily._()
    : super(
        retry: null,
        name: r'linkTitleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The title of a YouTube video, from its public oEmbed document [oEmbed]:
  /// one small GET, no key, nothing else fetched. Null when it has none.
  ///
  /// Kept for the life of the process; a failed one is kept for
  /// [AppConfig.linkTitleRetryAfter], so a streaming reply that rebuilds its
  /// card does not ask again on every token.

  LinkTitleProvider call(Uri oEmbed) =>
      LinkTitleProvider._(argument: oEmbed, from: this);

  @override
  String toString() => r'linkTitleProvider';
}
