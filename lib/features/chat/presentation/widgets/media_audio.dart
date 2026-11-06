import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../now_playing.dart';
import 'media_scrubber.dart';
import 'media_strip.dart';

/// Audio card: play/pause, the file's name, a seek bar with the time played
/// and the time left, and a speed button (1×, 1.5×, 2×).
///
/// The stream opens on the first play, not when the row is built: a transcript
/// of voice notes would otherwise start a native player and a network request
/// per note as it scrolls past, only to drop them again. One player plays at
/// a time ([NowPlaying]): starting one pauses the one playing.
///
/// [player] makes the player; tests pass their own.
class MediaAudio extends ConsumerStatefulWidget {
  const MediaAudio({
    required this.url,
    required this.headers,
    super.key,
    this.name = '',
    this.player = AudioPlayer.new,
  });

  /// Range-capable stream URL on the gateway.
  final Uri url;

  /// Auth headers for [url].
  final Map<String, String> headers;

  /// The file's name; empty shows a plain "Audio".
  final String name;

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
  Duration _buffered = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  bool _loading = false;
  bool _failed = false;
  double _speed = 1;
  final List<StreamSubscription<Object?>> _subs = [];

  Future<AudioPlayer?> _open() async {
    final existing = _player;
    if (existing != null) return existing;
    final player = widget.player();
    _player = player;
    _subs
      ..add(
        player.positionStream.listen((p) {
          if (mounted) setState(() => _position = p);
        }),
      )
      ..add(
        player.bufferedPositionStream.listen((b) {
          if (mounted) setState(() => _buffered = b);
        }),
      )
      ..add(
        player.durationStream.listen((d) {
          if (mounted && d != null) setState(() => _duration = d);
        }),
      )
      ..add(
        player.playerStateStream.listen((s) {
          if (!mounted) return;
          final done = s.processingState == ProcessingState.completed;
          setState(() {
            _playing = s.playing && !done;
            _loading =
                s.playing &&
                (s.processingState == ProcessingState.loading ||
                    s.processingState == ProcessingState.buffering);
          });
          if (done) _nowPlaying.release(this);
        }),
      );
    setState(() => _loading = true);
    try {
      final d = await player.setUrl(
        widget.url.toString(),
        headers: widget.headers,
      );
      if (!mounted) return null;
      setState(() {
        _loading = false;
        if (d != null) _duration = d;
      });
      await player.setSpeed(_speed);
      return player;
    } on Object catch (e, st) {
      log.w('audio failed to load', error: e, stackTrace: st);
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
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
      _buffered = Duration.zero;
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

  void _nextSpeed() {
    const speeds = AppConfig.audioSpeeds;
    final next = speeds[(speeds.indexOf(_speed) + 1) % speeds.length];
    setState(() => _speed = next);
    unawaited(_player?.setSpeed(next));
  }

  @override
  Widget build(BuildContext context) {
    // Another player started: this one gives way.
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

    final colors = context.colors;
    final spacing = context.spacing;
    final text = Theme.of(context).textTheme;
    final clock = text.labelSmall?.copyWith(
      color: colors.textSecondary,
      // Digits of one width: the clock does not shake as it counts.
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final left = _duration - _position;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: spacing.audioCardMaxWidth),
        child: AppSurface(
          color: colors.toolSurface,
          border: false,
          padding: EdgeInsetsDirectional.only(
            start: spacing.sm,
            top: spacing.sm,
            bottom: spacing.xs,
          ),
          child: Row(
            children: [
              AppIconButton(
                icon: _playing
                    ? CupertinoIcons.pause_fill
                    : CupertinoIcons.play_fill,
                tooltip: _playing ? l10n.mediaPause : l10n.mediaPlay,
                filled: true,
                busy: _loading,
                onPressed: () => unawaited(_toggle()),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: spacing.md),
                      child: Text(
                        widget.name.isEmpty
                            ? l10n.mediaAudioTitle
                            : widget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium,
                      ),
                    ),
                    MediaScrubber(
                      position: _position,
                      duration: _duration,
                      buffered: _buffered,
                      onSeek: (at) => unawaited(_player?.seek(at)),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: spacing.md),
                      child: Row(
                        children: [
                          Text(Format.duration(_position), style: clock),
                          const Spacer(),
                          Text(
                            _duration == Duration.zero
                                ? ''
                                : l10n.mediaRemaining(
                                    Format.duration(
                                      left.isNegative ? Duration.zero : left,
                                    ),
                                  ),
                            style: clock,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _nextSpeed,
                child: Semantics(
                  label: l10n.mediaSpeed,
                  child: Text(
                    Format.speed(l10n, _speed),
                    style: text.labelMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
