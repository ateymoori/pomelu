// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_prompt.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reviewPrompt)
final reviewPromptProvider = ReviewPromptProvider._();

final class ReviewPromptProvider
    extends $FunctionalProvider<ReviewPrompt, ReviewPrompt, ReviewPrompt>
    with $Provider<ReviewPrompt> {
  ReviewPromptProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewPromptProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewPromptHash();

  @$internal
  @override
  $ProviderElement<ReviewPrompt> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReviewPrompt create(Ref ref) {
    return reviewPrompt(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewPrompt value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewPrompt>(value),
    );
  }
}

String _$reviewPromptHash() => r'efc714e0cdddfe89b94f25583e7ed4fd653d09b7';
