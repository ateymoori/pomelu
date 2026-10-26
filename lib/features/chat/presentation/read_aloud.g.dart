// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'read_aloud.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(speechOutput)
final speechOutputProvider = SpeechOutputProvider._();

final class SpeechOutputProvider
    extends $FunctionalProvider<SpeechOutput, SpeechOutput, SpeechOutput>
    with $Provider<SpeechOutput> {
  SpeechOutputProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'speechOutputProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$speechOutputHash();

  @$internal
  @override
  $ProviderElement<SpeechOutput> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpeechOutput create(Ref ref) {
    return speechOutput(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeechOutput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeechOutput>(value),
    );
  }
}

String _$speechOutputHash() => r'5e271ca6f42a033c41519b48ffda166786810257';

/// Reads one reply aloud in the bot's own voice (the gateway's text to
/// speech). One at a time: a voice note that starts stops it, as it stops
/// a voice note.

@ProviderFor(ReadAloud)
final readAloudProvider = ReadAloudProvider._();

/// Reads one reply aloud in the bot's own voice (the gateway's text to
/// speech). One at a time: a voice note that starts stops it, as it stops
/// a voice note.
final class ReadAloudProvider
    extends $NotifierProvider<ReadAloud, ReadingAloud?> {
  /// Reads one reply aloud in the bot's own voice (the gateway's text to
  /// speech). One at a time: a voice note that starts stops it, as it stops
  /// a voice note.
  ReadAloudProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readAloudProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readAloudHash();

  @$internal
  @override
  ReadAloud create() => ReadAloud();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingAloud? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingAloud?>(value),
    );
  }
}

String _$readAloudHash() => r'42b4c6d792af8e3b1f591b65a4e14778457da363';

/// Reads one reply aloud in the bot's own voice (the gateway's text to
/// speech). One at a time: a voice note that starts stops it, as it stops
/// a voice note.

abstract class _$ReadAloud extends $Notifier<ReadingAloud?> {
  ReadingAloud? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ReadingAloud?, ReadingAloud?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReadingAloud?, ReadingAloud?>,
              ReadingAloud?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
