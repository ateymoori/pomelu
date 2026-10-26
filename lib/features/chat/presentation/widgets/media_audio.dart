import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/l10n_ext.dart';
import 'media_strip.dart';

part 'media_audio.g.dart';

/// The player playing now, as the token it claimed with: a player that
/// starts claims it and every other one pauses, so two voice notes never
/// play over each other.
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

/// Pill audio player: play/pause, scrubber, position and duration.
///
/// The stream opens on the first play, not when the row is built: a transcript
/// of voice notes would otherwise start a native player and a network request
/// per note as it scrolls past, only to drop them again. One note plays at a
/// time ([NowPlaying]): starting one pauses the one playing.
///
/// [player] makes the player; tests pass their own.
class MediaAudio extends ConsumerStatefulWidget {
  const MediaAudio({
    required this.url,
    required this.headers,
    super.key,
    this.player = AudioPlayer.new,
  });

  /// Range-capable stream URL on the gateway.
  final Uri url;

  /// Auth headers for [url].
  final Map<String, String> headers;

  /// Makes the native player, on the first play.
  final AudioPlayer Function() player;

  @override
  ConsumerState<MediaAudio> createState() => _MediaAudioState();
}

class _MediaAudioState extends ConsumerState<MediaAudio> {
  late final NowPlaying _nowPlaying;

  @override
  void initState() {
    super.initState();
    _nowPlaying = ref.read(nowPlayingProvider.notifier);
  }

  AudioPlayer? _player;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  bool _failed = false;
  final List<StreamSubscription<Object?>> _subs = [];

  Future<AudioPlayer?> _open() async {
    final existing = _player;
    if (existing != null) return existing;
    final player = widget.player();
    _player = player;
    _subs.add(
      player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      }),
    );
    _subs.add(
      player.playerStateStream.listen((s) {
        if (!mounted) return;
        setState(
          () => _playing =
              s.playing && s.processingState != ProcessingState.completed,
        );
      }),
    );
    try {
      final d = await player.setUrl(
        widget.url.toString(),
        headers: widget.headers,
      );
      if (mounted) setState(() => _duration = d ?? Duration.zero);
      return player;
    } on Object catch (e, st) {
      log.w('audio failed to load', error: e, stackTrace: st);
      if (mounted) setState(() => _failed = true);
      return null;
    }
  }

  void _release() {
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    _subs.clear();
    unawaited(_player?.dispose());
    _player = null;
  }

  @override
  void dispose() {
    _release();
    // Not inside the tree's teardown: a provider may not change there.
    final nowPlaying = _nowPlaying;
    scheduleMicrotask(() => nowPlaying.release(this));
    super.dispose();
  }

  void _retry() {
    _release();
    setState(() {
      _failed = false;
      _playing = false;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    unawaited(_toggle());
  }

  Future<void> _toggle() async {
    final player = await _open();
    // The row went away (or was retried) while the stream opened: the
    // player is disposed, and playing it would throw.
    if (player == null || !mounted || !identical(player, _player)) return;
    if (_playing) {
      _nowPlaying.release(this);
      await player.pause();
      return;
    }
    _nowPlaying.claim(this);
    if (player.processingState == ProcessingState.completed) {
      await player.seek(Duration.zero);
    }
    if (!mounted || !identical(player, _player)) return;
    await player.play();
  }

  @override
  Widget build(BuildContext context) {
    // Another note started: this one gives way.
    ref.listen(nowPlayingProvider, (_, playing) {
      if (!identical(playing, this) && _playing) {
        unawaited(_player?.pause());
      }
    });
    final l10n = context.l10n;
    if (_failed) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: MediaStatusChip(
          icon: CupertinoIcons.waveform,
          title: l10n.mediaAudioFailed,
          onRetry: _retry,
        ),
      );
    }

    final spacing = context.spacing;
    final total = _duration.inMilliseconds;
    final value = total == 0
        ? 0.0
        : (_position.inMilliseconds / total).clamp(0.0, 1.0);

    return AppSurface(
      borderRadius: BorderRadius.circular(context.radii.pill),
      // Pill arcs cut deep into the slider track.
      clip: true,
      padding: EdgeInsets.symmetric(horizontal: spacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconButton(
            icon: _playing
                ? CupertinoIcons.pause_fill
                : CupertinoIcons.play_fill,
            tooltip: _playing ? l10n.mediaPause : l10n.mediaPlay,
            onPressed: () => unawaited(_toggle()),
          ),
          SizedBox(width: spacing.xs),
          Flexible(
            // A full touch target to scrub in, not the sliver the thumb
            // would give.
            child: SizedBox(
              height: spacing.minTouch,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: spacing.xs,
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                // One control for a screen reader: a name, the position, and
                // the slider's own increase / decrease.
                child: MergeSemantics(
                  child: Semantics(
                    label: l10n.mediaSeek,
                    child: Slider(
                      value: value,
                      semanticFormatterCallback: (v) => l10n.mediaAudioTime(
                        Format.duration(
                          Duration(milliseconds: (v * total).round()),
                        ),
                        Format.duration(_duration),
                      ),
                      onChanged: total == 0
                          ? null
                          : (v) => unawaited(
                              _player!.seek(
                                Duration(milliseconds: (v * total).round()),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(end: spacing.md),
            child: Text(
              l10n.mediaAudioTime(
                Format.duration(_position),
                Format.duration(_duration),
              ),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}
