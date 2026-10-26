import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../hermes/api/hermes_api.dart';
import '../../../hermes/hermes_failure.dart';
import '../../connection/presentation/connection_providers.dart';
import 'widgets/media_audio.dart';

part 'read_aloud.g.dart';

/// Plays speech audio; the native player, which tests replace.
abstract interface class SpeechOutput {
  /// Plays [audio]; completes when it ends or is stopped. Throws a
  /// [HermesFailure] when the phone cannot play it.
  Future<void> play(SpeechAudio audio);

  Future<void> stop();
}

/// `just_audio`, from a file in the temporary folder: one at a time, so
/// each reading overwrites the last.
class PlayerSpeechOutput implements SpeechOutput {
  AudioPlayer? _player;

  @override
  Future<void> play(SpeechAudio audio) async {
    await stop();
    final ext = switch (audio.mimeType) {
      'audio/ogg' => 'ogg',
      'audio/wav' => 'wav',
      'audio/flac' => 'flac',
      _ => 'mp3',
    };
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/read_aloud.$ext');
    await file.writeAsBytes(audio.bytes, flush: true);
    final player = _player = AudioPlayer();
    try {
      await player.setFilePath(file.path);
      // Ends when the audio does, or when paused or stopped.
      await player.play();
    } on PlayerInterruptedException {
      // Stopped while it loaded.
    } on PlayerException catch (e) {
      // A format the phone cannot play (iOS has no Ogg).
      throw ProtocolFailure('speech audio not playable', cause: e);
    } finally {
      if (identical(_player, player)) _player = null;
      unawaited(player.dispose());
    }
  }

  @override
  Future<void> stop() async => _player?.stop();
}

@Riverpod(keepAlive: true)
SpeechOutput speechOutput(Ref ref) => PlayerSpeechOutput();

/// The reply read aloud, and whether its audio is still on its way.
typedef ReadingAloud = ({String messageId, bool loading});

/// Reads one reply aloud in the bot's own voice (the gateway's text to
/// speech). One at a time: a voice note that starts stops it, as it stops
/// a voice note.
@Riverpod(keepAlive: true)
class ReadAloud extends _$ReadAloud {
  Object? _turn;

  @override
  ReadingAloud? build() {
    ref.listen(nowPlayingProvider, (_, next) {
      if (next != null && !identical(next, this)) unawaited(stop());
    });
    return null;
  }

  /// Reads [text] of [messageId] as [profile]'s voice, in place of any
  /// reading before; completes when it ends or is stopped. Throws a
  /// [HermesFailure] when the gateway cannot speak it or the phone cannot
  /// play it.
  Future<void> read({
    required String messageId,
    required String text,
    required String profile,
  }) async {
    final api = ref.read(hermesApiProvider);
    if (api == null) throw NetworkFailure.notConnected;
    await stop();
    final turn = _turn = Object();
    state = (messageId: messageId, loading: true);
    final output = ref.read(speechOutputProvider);
    final nowPlaying = ref.read(nowPlayingProvider.notifier);
    try {
      final audio = await api.speak(text: text, profile: profile);
      if (!identical(_turn, turn)) return;
      state = (messageId: messageId, loading: false);
      nowPlaying.claim(this);
      await output.play(audio);
    } finally {
      if (identical(_turn, turn)) {
        _turn = null;
        state = null;
        nowPlaying.release(this);
      }
    }
  }

  Future<void> stop() async {
    if (_turn == null) return;
    _turn = null;
    state = null;
    ref.read(nowPlayingProvider.notifier).release(this);
    await ref.read(speechOutputProvider).stop();
  }
}
