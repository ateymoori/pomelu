// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_size.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bytes in the gateway file [path]; null when the gateway does not say. A
/// size once known is kept: a file the bot sent does not change.

@ProviderFor(mediaSize)
final mediaSizeProvider = MediaSizeFamily._();

/// Bytes in the gateway file [path]; null when the gateway does not say. A
/// size once known is kept: a file the bot sent does not change.

final class MediaSizeProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, FutureOr<int?>>
    with $FutureModifier<int?>, $FutureProvider<int?> {
  /// Bytes in the gateway file [path]; null when the gateway does not say. A
  /// size once known is kept: a file the bot sent does not change.
  MediaSizeProvider._({
    required MediaSizeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'mediaSizeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mediaSizeHash();

  @override
  String toString() {
    return r'mediaSizeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int?> create(Ref ref) {
    final argument = this.argument as String;
    return mediaSize(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MediaSizeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mediaSizeHash() => r'67eb713d603343d44c732af26e870922a4cc4ef8';

/// Bytes in the gateway file [path]; null when the gateway does not say. A
/// size once known is kept: a file the bot sent does not change.

final class MediaSizeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int?>, String> {
  MediaSizeFamily._()
    : super(
        retry: null,
        name: r'mediaSizeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Bytes in the gateway file [path]; null when the gateway does not say. A
  /// size once known is kept: a file the bot sent does not change.

  MediaSizeProvider call(String path) =>
      MediaSizeProvider._(argument: path, from: this);

  @override
  String toString() => r'mediaSizeProvider';
}
