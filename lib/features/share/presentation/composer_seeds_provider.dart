import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/composer_seed.dart';

export '../domain/composer_seed.dart';

part 'composer_seeds_provider.g.dart';

/// Composer seeds by chat target key; the chat view takes each once.
@Riverpod(keepAlive: true)
class ComposerSeeds extends _$ComposerSeeds {
  @override
  Map<String, ComposerSeed> build() => const {};

  void put(String targetKey, ComposerSeed seed) =>
      state = {...state, targetKey: seed};

  /// Returns and removes the seed for [targetKey], if any.
  ComposerSeed? take(String targetKey) {
    final seed = state[targetKey];
    if (seed == null) return null;
    state = {...state}..remove(targetKey);
    return seed;
  }
}
