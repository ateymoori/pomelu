import 'package:in_app_review/in_app_review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'platform_info.dart';

part 'store_review.g.dart';

/// The store's own review prompt. The store decides whether it shows.
abstract interface class StoreReview {
  Future<void> request();
}

/// None: other platforms and tests.
class NoStoreReview implements StoreReview {
  const NoStoreReview();

  @override
  Future<void> request() async {}
}

/// Google Play's in-app review.
class PlayStoreReview implements StoreReview {
  const PlayStoreReview();

  @override
  Future<void> request() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) await review.requestReview();
  }
}

@Riverpod(keepAlive: true)
StoreReview storeReview(Ref ref) => ref.watch(platformInfoProvider).isAndroid
    ? const PlayStoreReview()
    : const NoStoreReview();
