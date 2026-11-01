// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_review.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storeReview)
final storeReviewProvider = StoreReviewProvider._();

final class StoreReviewProvider
    extends $FunctionalProvider<StoreReview, StoreReview, StoreReview>
    with $Provider<StoreReview> {
  StoreReviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeReviewProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeReviewHash();

  @$internal
  @override
  $ProviderElement<StoreReview> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StoreReview create(Ref ref) {
    return storeReview(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreReview value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreReview>(value),
    );
  }
}

String _$storeReviewHash() => r'd5b5bf4c28456b6e5886f508ff9f0208f979201a';
