import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'now_playing.g.dart';

/// The player playing now, as the token it claimed with: a player that
/// starts claims it and every other one pauses, so a voice note, a video
/// and a reading aloud never play over each other.
@Riverpod(keepAlive: true)
class NowPlaying extends _$NowPlaying {
  @override
  Object? build() => null;

  void claim(Object token) {
    if (ref.mounted && !identical(state, token)) state = token;
  }

  /// [token] stopped; another player's claim stays.
  void release(Object token) {
    if (ref.mounted && identical(state, token)) state = null;
  }
}
