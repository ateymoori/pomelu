import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/l10n_ext.dart';
import 'media_strip.dart';

const int _seekSteps = 10;

/// Inline video: a play tile until tapped, then the player with a play/pause
/// overlay and a thin progress bar.
///
/// The player starts on the tap, not when the row is built. A transcript with
/// many videos would otherwise open a network stream and a native decoder for
/// each one as it scrolls past, and tear them down again a moment later.
class MediaVideo extends StatefulWidget {
  const MediaVideo({required this.url, required this.headers, super.key});

  /// Range-capable stream URL on the gateway.
  final Uri url;

  /// Auth headers for [url].
  final Map<String, String> headers;

  @override
  State<MediaVideo> createState() => _MediaVideoState();
}

class _MediaVideoState extends State<MediaVideo> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  Future<void> _start() async {
    if (_controller != null) return;
    final controller = VideoPlayerController.networkUrl(
      widget.url,
      httpHeaders: widget.headers,
    );
    setState(() => _controller = controller);
    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() => _ready = true);
      unawaited(controller.play());
    } on Object catch (e, st) {
      log.w('video failed to load', error: e, stackTrace: st);
      if (mounted) setState(() => _failed = true);
    }
  }

  void _retry() {
    final old = _controller;
    setState(() {
      _controller = null;
      _ready = false;
      _failed = false;
    });
    unawaited(old?.dispose());
    unawaited(_start());
  }

  @override
  void dispose() {
    unawaited(_controller?.dispose());
    super.dispose();
  }

  void _toggle() {
    final controller = _controller;
    if (controller == null || !_ready) return;
    if (controller.value.isPlaying) {
      unawaited(controller.pause());
    } else {
      unawaited(controller.play());
    }
  }

  void _step(VideoPlayerController controller, int steps) {
    final total = controller.value.duration;
    final at = controller.value.position + total ~/ _seekSteps * steps;
    unawaited(
      controller.seekTo(
        at < Duration.zero
            ? Duration.zero
            : at > total
            ? total
            : at,
      ),
    );
  }

  Widget _frame(BuildContext context, double aspect, Widget layers) {
    final cap =
        MediaQuery.sizeOf(context).height *
        context.spacing.mediaMaxHeightFraction;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: cap),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.radii.md),
          child: AspectRatio(aspectRatio: aspect, child: layers),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    if (_failed) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: MediaStatusChip(
          icon: CupertinoIcons.video_camera_solid,
          title: l10n.mediaVideoFailed,
          onRetry: _retry,
        ),
      );
    }

    final controller = _controller;
    if (controller == null) {
      return _frame(
        context,
        context.spacing.mediaAspect,
        Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: colors.scrimSolid),
            Center(
              child: AppIconButton(
                icon: CupertinoIcons.play_fill,
                tooltip: l10n.mediaPlay,
                onPressed: () => unawaited(_start()),
              ),
            ),
          ],
        ),
      );
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final aspect = _ready && value.aspectRatio > 0
            ? value.aspectRatio
            : context.spacing.mediaAspect;
        return _frame(
          context,
          aspect,
          Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: colors.scrimSolid),
              if (_ready)
                VideoPlayer(controller)
              else
                const Center(child: ShimmerLine()),
              Center(
                child: AppIconButton(
                  icon: value.isPlaying
                      ? CupertinoIcons.pause_fill
                      : CupertinoIcons.play_fill,
                  tooltip: value.isPlaying ? l10n.mediaPause : l10n.mediaPlay,
                  onPressed: _ready ? _toggle : null,
                ),
              ),
              if (_ready) _scrubber(context, controller, value),
            ],
          ),
        );
      },
    );
  }

  Widget _scrubber(
    BuildContext context,
    VideoPlayerController controller,
    VideoPlayerValue value,
  ) {
    final colors = context.colors;
    final spacing = context.spacing;
    final l10n = context.l10n;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Semantics(
        slider: true,
        label: l10n.mediaSeek,
        value: l10n.mediaAudioTime(
          Format.duration(value.position),
          Format.duration(value.duration),
        ),
        onIncrease: () => _step(controller, 1),
        onDecrease: () => _step(controller, -1),
        excludeSemantics: true,
        child: VideoProgressIndicator(
          controller,
          allowScrubbing: true,
          padding: EdgeInsets.only(top: spacing.minTouch - spacing.xs),
          colors: VideoProgressColors(
            playedColor: colors.accent,
            bufferedColor: colors.accentSoft,
            backgroundColor: colors.divider,
          ),
        ),
      ),
    );
  }
}
