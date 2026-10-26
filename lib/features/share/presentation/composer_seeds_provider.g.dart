// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composer_seeds_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composer seeds by chat target key; the chat view takes each once.

@ProviderFor(ComposerSeeds)
final composerSeedsProvider = ComposerSeedsProvider._();

/// Composer seeds by chat target key; the chat view takes each once.
final class ComposerSeedsProvider
    extends $NotifierProvider<ComposerSeeds, Map<String, ComposerSeed>> {
  /// Composer seeds by chat target key; the chat view takes each once.
  ComposerSeedsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'composerSeedsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$composerSeedsHash();

  @$internal
  @override
  ComposerSeeds create() => ComposerSeeds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, ComposerSeed> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, ComposerSeed>>(value),
    );
  }
}

String _$composerSeedsHash() => r'cbada2217b3a920fad65e7d6d7b069a513e4cd06';

/// Composer seeds by chat target key; the chat view takes each once.

abstract class _$ComposerSeeds extends $Notifier<Map<String, ComposerSeed>> {
  Map<String, ComposerSeed> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<Map<String, ComposerSeed>, Map<String, ComposerSeed>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, ComposerSeed>, Map<String, ComposerSeed>>,
              Map<String, ComposerSeed>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
