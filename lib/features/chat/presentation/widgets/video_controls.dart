import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/l10n_ext.dart';
import 'media_scrubber.dart';

final ThemeData _dark = AppTheme.dark();
final ThemeData _darkContrast = AppTheme.darkContrast();

/// The dark theme for controls over a picture: a video is dark around its
/// controls in either app theme, as in Photos.
ThemeData videoTheme(BuildContext context) =>
    MediaQuery.highContrastOf(context) ? _darkContrast : _dark;

/// Player actions every control shares.
extension VideoActions on VideoPlayerController {
  /// Plays, pauses, or after the end plays again from the start.
  Future<void> togglePlay() async {
    if (value.isPlaying) return pause();
    if (value.isCompleted || value.position >= value.duration) {
      await seekTo(Duration.zero);
    }
    await play();
  }

  /// Skips by [by], within the video.
  Future<void> skip(Duration by) {
    final at = value.position + by;
    return seekTo(
      at < Duration.zero
          ? Duration.zero
          : at > value.duration
          ? value.duration
          : at,
    );
  }

  Future<void> toggleMute() => setVolume(value.volume == 0 ? 1 : 0);

  /// The next of [AppConfig.videoSpeeds], round to the first.
  Future<void> nextSpeed() {
    const speeds = AppConfig.videoSpeeds;
    final i = speeds.indexOf(value.playbackSpeed);
    return setPlaybackSpeed(speeds[(i + 1) % speeds.length]);
  }
}

/// A started video with its controls: tap to show or hide them, which a
/// playing video does by itself after a moment. Inline it has play/pause,
/// the seek bar, mute and full screen; [full] adds skip buttons, the time
/// left, double tap to skip, and [top] (the page's bar).
class VideoView extends StatefulWidget {
  const VideoView({
    required this.controller,
    super.key,
    this.full = false,
    this.top,
    this.onFullScreen,
    this.onMenu,
    this.onControlsChanged,
  });

  final VideoPlayerController controller;
  final bool full;

  /// The bar at the top of the full-screen page; fades with the controls.
  final Widget? top;

  /// Opens the full-screen page; null hides the button.
  final VoidCallback? onFullScreen;

  /// A long press or right click: the video's actions.
  final VoidCallback? onMenu;

  /// The controls showed or hid.
  final ValueChanged<bool>? onControlsChanged;

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  bool _shown = true;
  bool _scrubbing = false;
  bool _wasPlaying = false;
  Timer? _hide;

  VideoPlayerController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _wasPlaying = _c.value.isPlaying;
    _c.addListener(_onValue);
    // The linger time is a theme token: read it once the theme is there.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _linger();
    });
  }

  @override
  void didUpdateWidget(VideoView old) {
    super.didUpdateWidget(old);
    if (!identical(old.controller, _c)) {
      old.controller.removeListener(_onValue);
      _c.addListener(_onValue);
    }
  }

  @override
  void dispose() {
    _hide?.cancel();
    _c.removeListener(_onValue);
    super.dispose();
  }

  void _onValue() {
    final playing = _c.value.isPlaying;
    if (playing == _wasPlaying) return;
    _wasPlaying = playing;
    // Paused or ended: the controls come back and stay.
    if (playing) {
      _linger();
    } else {
      _show(true);
    }
  }

  void _show(bool shown) {
    _hide?.cancel();
    if (shown != _shown) {
      setState(() => _shown = shown);
      widget.onControlsChanged?.call(shown);
    }
  }

  /// Shows the controls; a playing video hides them again after a moment.
  void _linger() {
    _show(true);
    if (!_c.value.isPlaying || _scrubbing) return;
    _hide = Timer(context.motion.videoControlsLinger, () {
      if (mounted && _c.value.isPlaying && !_scrubbing) _show(false);
    });
  }

  void _act(Future<void> Function() action) {
    unawaited(action());
    _linger();
  }

  void _doubleTap(TapDownDetails d) {
    final box = context.findRenderObject()! as RenderBox;
    final back = d.localPosition.dx < box.size.width / 2;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // The start side skips back, as a timeline runs from it.
    _act(
      () => _c.skip(back != rtl ? -AppConfig.mediaSkip : AppConfig.mediaSkip),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final instant = context.reduceMotion;
    return Theme(
      data: videoTheme(context),
      child: Builder(
        builder: (context) => Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: context.colors.scrimSolid),
            Center(
              child: ValueListenableBuilder(
                valueListenable: _c,
                builder: (_, value, _) => AspectRatio(
                  aspectRatio: value.aspectRatio,
                  child: VideoPlayer(_c),
                ),
              ),
            ),
            // Under the controls, not around them: a double tap waits to
            // tell one tap from two, and would hold every button's tap.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  _shown && _c.value.isPlaying ? _show(false) : _linger(),
              onDoubleTapDown: widget.full ? _doubleTap : null,
              onDoubleTap: widget.full ? () {} : null,
              onLongPress: widget.onMenu,
              onSecondaryTap: widget.onMenu,
            ),
            AnimatedOpacity(
              opacity: _shown ? 1 : 0,
              duration: instant ? Duration.zero : context.motion.fast,
              child: IgnorePointer(
                ignoring: !_shown,
                child: ValueListenableBuilder(
                  valueListenable: _c,
                  builder: (context, value, _) => _controls(context, value),
                ),
              ),
            ),
            if (widget.full && widget.top != null)
              Align(
                alignment: Alignment.topCenter,
                child: AnimatedOpacity(
                  opacity: _shown ? 1 : 0,
                  duration: instant ? Duration.zero : context.motion.fast,
                  child: IgnorePointer(
                    ignoring: !_shown,
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(spacing.gutter),
                        child: widget.top,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _controls(BuildContext context, VideoPlayerValue value) {
    final spacing = context.spacing;
    final l10n = context.l10n;
    final skip = AppConfig.mediaSkip.inSeconds;
    final play = AppIconButton(
      icon: value.isPlaying
          ? CupertinoIcons.pause_fill
          : value.isCompleted
          ? CupertinoIcons.arrow_counterclockwise
          : CupertinoIcons.play_fill,
      tooltip: value.isPlaying
          ? l10n.mediaPause
          : value.isCompleted
          ? l10n.mediaReplay
          : l10n.mediaPlay,
      busy: value.isBuffering && value.isPlaying,
      onPressed: () => _act(_c.togglePlay),
    );
    final bar = Padding(
      padding: EdgeInsets.all(widget.full ? spacing.gutter : spacing.sm),
      child: _bar(context, value),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: widget.full
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: spacing.xl,
                  children: [
                    AppIconButton(
                      icon: CupertinoIcons.gobackward_10,
                      tooltip: l10n.mediaSkipBack(skip),
                      onPressed: () =>
                          _act(() => _c.skip(-AppConfig.mediaSkip)),
                    ),
                    play,
                    AppIconButton(
                      icon: CupertinoIcons.goforward_10,
                      tooltip: l10n.mediaSkipForward(skip),
                      onPressed: () => _act(() => _c.skip(AppConfig.mediaSkip)),
                    ),
                  ],
                )
              : play,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: widget.full ? SafeArea(top: false, child: bar) : bar,
        ),
      ],
    );
  }

  Widget _bar(BuildContext context, VideoPlayerValue value) {
    final colors = context.colors;
    final spacing = context.spacing;
    final l10n = context.l10n;
    final clock = Theme.of(context).textTheme.labelMedium?.copyWith(
      // Digits of one width: the clock does not shake as it counts.
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final buffered = value.buffered.isEmpty
        ? null
        : value.buffered.map((r) => r.end).reduce((a, b) => a > b ? a : b);
    final muted = value.volume == 0;
    return AppGlass.capsule(
      padding: EdgeInsetsDirectional.only(start: spacing.md),
      child: Row(
        children: [
          Text(Format.duration(value.position), style: clock),
          SizedBox(width: spacing.sm),
          Expanded(
            child: MediaScrubber(
              position: value.position,
              duration: value.duration,
              buffered: buffered,
              activeColor: colors.onScrim,
              inactiveColor: colors.divider,
              bufferedColor: colors.textSecondary,
              onSeek: (at) => unawaited(_c.seekTo(at)),
              onScrubStart: () {
                _scrubbing = true;
                _show(true);
              },
              onScrubEnd: () {
                _scrubbing = false;
                _linger();
              },
            ),
          ),
          SizedBox(width: spacing.sm),
          if (widget.full)
            Text(
              l10n.mediaRemaining(
                Format.duration(value.duration - value.position),
              ),
              style: clock,
            ),
          if (widget.full)
            TextButton(
              onPressed: () => _act(_c.nextSpeed),
              child: Semantics(
                label: l10n.mediaSpeed,
                child: Text(
                  Format.speed(l10n, value.playbackSpeed),
                  style: clock,
                ),
              ),
            ),
          AppIconButton.plain(
            icon: muted
                ? CupertinoIcons.speaker_slash_fill
                : CupertinoIcons.speaker_2_fill,
            tooltip: muted ? l10n.mediaUnmute : l10n.mediaMute,
            onPressed: () => _act(_c.toggleMute),
          ),
          if (widget.onFullScreen case final open?)
            AppIconButton.plain(
              icon: CupertinoIcons.arrow_up_left_arrow_down_right,
              tooltip: l10n.mediaFullScreen,
              onPressed: open,
            ),
        ],
      ),
    );
  }
}
