// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_audio.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The player playing now, as the token it claimed with: a player that
/// starts claims it and every other one pauses, so two voice notes never
/// play over each other.

@ProviderFor(NowPlaying)
final nowPlayingProvider = NowPlayingProvider._();

/// The player playing now, as the token it claimed with: a player that
/// starts claims it and every other one pauses, so two voice notes never
/// play over each other.
final class NowPlayingProvider extends $NotifierProvider<NowPlaying, Object?> {
  /// The player playing now, as the token it claimed with: a player that
  /// starts claims it and every other one pauses, so two voice notes never
  /// play over each other.
  NowPlayingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nowPlayingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nowPlayingHash();

  @$internal
  @override
  NowPlaying create() => NowPlaying();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Object? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Object?>(value),
    );
  }
}

String _$nowPlayingHash() => r'8e78d06f50aca8515d4a54a4dac30d9d1062bd9d';

/// The player playing now, as the token it claimed with: a player that
/// starts claims it and every other one pauses, so two voice notes never
/// play over each other.

abstract class _$NowPlaying extends $Notifier<Object?> {
  Object? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Object?, Object?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Object?, Object?>,
              Object?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
