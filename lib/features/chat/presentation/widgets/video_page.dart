import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/l10n_ext.dart';
import 'video_controls.dart';

/// Full-screen video on the player the chat row started, so it plays on
/// without a break: drag down or ✕ to close, save and share from the top
/// bar, the keyboard's space, arrows, M and Esc.
class VideoPage extends StatefulWidget {
  const VideoPage({
    required this.controller,
    required this.name,
    required this.save,
    required this.share,
    super.key,
  });

  final VideoPlayerController controller;

  /// The file's name, for a failed share.
  final String name;

  /// Save to the gallery, and to the share sheet; each throws on failure.
  final Future<void> Function() save;
  final Future<void> Function() share;

  /// A fading full-screen route over the chat; reduced motion switches at
  /// once.
  static Future<void> open(
    BuildContext context, {
    required VideoPlayerController controller,
    required String name,
    required Future<void> Function() save,
    required Future<void> Function() share,
  }) {
    final instant = context.reduceMotion;
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        fullscreenDialog: true,
        transitionDuration: instant ? Duration.zero : context.motion.normal,
        reverseTransitionDuration: instant
            ? Duration.zero
            : context.motion.fast,
        pageBuilder: (_, _, _) => VideoPage(
          controller: controller,
          name: name,
          save: save,
          share: share,
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  double _drag = 0;
  bool _busy = false;

  VideoPlayerController get _c => widget.controller;

  @override
  void dispose() {
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    super.dispose();
  }

  /// Hidden controls take the status bar with them: only the video shows.
  void _controls(bool shown) => unawaited(
    SystemChrome.setEnabledSystemUIMode(
      shown ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
    ),
  );

  Future<void> _run(
    Future<void> Function() job, {
    String? done,
    required String failed,
  }) async {
    final snacks = AppSnacks.of(context);
    setState(() => _busy = true);
    try {
      await job();
      if (done != null) snacks.show(done);
    } on Object catch (e) {
      log.w('video save or share failed', error: e);
      snacks.show(failed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _close() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final l10n = context.l10n;
    final dismissAt = spacing.dragToDismiss;
    final fade = (1 - _drag.abs() / (dismissAt * 2)).clamp(
      context.motion.viewerDragMinOpacity,
      1.0,
    );
    final top = Row(
      children: [
        AppIconButton(
          icon: CupertinoIcons.xmark,
          tooltip: l10n.actionClose,
          onPressed: _close,
        ),
        const Spacer(),
        AppIconButton(
          icon: CupertinoIcons.arrow_down_to_line,
          tooltip: l10n.mediaSave,
          onPressed: _busy
              ? null
              : () => _run(
                  widget.save,
                  done: l10n.mediaSaved,
                  failed: l10n.mediaVideoSaveFailed,
                ),
        ),
        SizedBox(width: spacing.xs),
        AppIconButton(
          icon: CupertinoIcons.square_arrow_up,
          tooltip: l10n.attachShare,
          busy: _busy,
          onPressed: _busy
              ? null
              : () => _run(
                  widget.share,
                  failed: l10n.attachDownloadFailed(widget.name),
                ),
        ),
      ],
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.scrimSolid.withValues(alpha: fade),
        body: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.space): () =>
                unawaited(_c.togglePlay()),
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                unawaited(_c.skip(-AppConfig.mediaSkip)),
            const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                unawaited(_c.skip(AppConfig.mediaSkip)),
            const SingleActivator(LogicalKeyboardKey.keyM): () =>
                unawaited(_c.toggleMute()),
            const SingleActivator(LogicalKeyboardKey.escape): _close,
          },
          child: Focus(
            autofocus: true,
            child: GestureDetector(
              onVerticalDragUpdate: (d) => setState(() => _drag += d.delta.dy),
              onVerticalDragEnd: (_) {
                if (_drag.abs() > dismissAt) {
                  _close();
                } else {
                  setState(() => _drag = 0);
                }
              },
              child: Transform.translate(
                offset: Offset(0, _drag),
                child: Opacity(
                  opacity: fade,
                  child: VideoView(
                    controller: _c,
                    full: true,
                    top: top,
                    onControlsChanged: _controls,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
