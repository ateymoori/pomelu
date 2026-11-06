import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../connection/presentation/connection_providers.dart';
import '../../data/media_cache.dart';
import '../now_playing.dart';
import 'media_strip.dart';
import 'video_controls.dart';
import 'video_page.dart';

/// What the video's menu can do.
enum _VideoAction { fullScreen, save, share }

/// Inline video: its first frame and length, then a tap plays it in place
/// with controls, and full screen carries on with the same player.
///
/// The stream opens once the row has been on screen a moment
/// ([AppConfig.videoPosterDelay]): a transcript scrolled past opens no
/// network stream and no native decoder per video. One player plays at a
/// time ([NowPlaying]); video_player keeps the screen on while it plays.
class MediaVideo extends ConsumerStatefulWidget {
  const MediaVideo({
    required this.url,
    required this.headers,
    required this.path,
    required this.name,
    super.key,
  });

  /// Range-capable stream URL on the gateway.
  final Uri url;

  /// Auth headers for [url].
  final Map<String, String> headers;

  /// Gateway path, to fetch the file for saving or sharing.
  final String path;

  /// The file's name.
  final String name;

  @override
  ConsumerState<MediaVideo> createState() => _MediaVideoState();
}

/// Sizes of videos already opened, so a row built again keeps its shape
/// and the transcript does not jump.
final Map<String, double> _aspects = {};

class _MediaVideoState extends ConsumerState<MediaVideo> {
  late final NowPlaying _nowPlaying;
  VideoPlayerController? _controller;
  Timer? _posterTimer;
  bool _ready = false;
  bool _failed = false;
  bool _started = false;
  bool _playing = false;
  bool _playWhenReady = false;

  /// The full-screen page while it is open: it owns the player till then.
  Future<void>? _page;

  String get _key => widget.url.toString();

  @override
  void initState() {
    super.initState();
    _nowPlaying = ref.read(nowPlayingProvider.notifier);
    _posterTimer = Timer(AppConfig.videoPosterDelay, () => unawaited(_load()));
  }

  @override
  void dispose() {
    _posterTimer?.cancel();
    final controller = _controller;
    controller?.removeListener(_onValue);
    // Not inside the tree's teardown: a provider may not change there.
    final nowPlaying = _nowPlaying;
    scheduleMicrotask(() => nowPlaying.release(this));
    if (controller != null) {
      // The page plays on a row that scrolled away; it lets go on close.
      final page = _page;
      if (page == null) {
        unawaited(controller.dispose());
      } else {
        unawaited(page.whenComplete(controller.dispose));
      }
    }
    super.dispose();
  }

  Future<void> _load() async {
    if (_controller != null) return;
    _posterTimer?.cancel();
    final controller = VideoPlayerController.networkUrl(
      widget.url,
      httpHeaders: widget.headers,
    );
    setState(() => _controller = controller);
    try {
      await controller.initialize();
      if (!mounted || !identical(controller, _controller)) return;
      final aspect = controller.value.aspectRatio;
      if (aspect > 0) {
        if (_aspects.length >= AppConfig.videoAspectCacheLimit) {
          _aspects.remove(_aspects.keys.first);
        }
        _aspects[_key] = aspect;
      }
      controller.addListener(_onValue);
      setState(() => _ready = true);
      if (_playWhenReady) _play();
    } on Object catch (e, st) {
      log.w('video failed to load', error: e, stackTrace: st);
      if (mounted) setState(() => _failed = true);
    }
  }

  void _onValue() {
    final playing = _controller?.value.isPlaying ?? false;
    if (playing == _playing) return;
    _playing = playing;
    if (playing) {
      _nowPlaying.claim(this);
    } else {
      _nowPlaying.release(this);
    }
  }

  void _play() {
    final controller = _controller;
    if (controller == null || !_ready) {
      _playWhenReady = true;
      unawaited(_load());
      return;
    }
    _playWhenReady = false;
    setState(() => _started = true);
    unawaited(controller.togglePlay());
  }

  void _retry() {
    final old = _controller;
    old?.removeListener(_onValue);
    setState(() {
      _controller = null;
      _ready = false;
      _failed = false;
      _started = false;
    });
    unawaited(old?.dispose());
    _playWhenReady = true;
    unawaited(_load());
  }

  Future<void> _openFull() async {
    final controller = _controller;
    if (controller == null || !_ready || _page != null) return;
    setState(() => _started = true);
    if (!controller.value.isPlaying) unawaited(controller.togglePlay());
    final page = VideoPage.open(
      context,
      controller: controller,
      name: widget.name,
      save: _save,
      share: _share,
    );
    _page = page;
    await page;
    _page = null;
  }

  Future<File> _file() async {
    final client = ref.read(hermesClientProvider);
    final api = ref.read(hermesApiProvider);
    if (client == null || api == null || widget.path.isEmpty) {
      throw StateError('no gateway for ${widget.name}');
    }
    return MediaCache.fetch(client, api, widget.path, widget.name);
  }

  Future<void> _save() async => MediaCache.galleryVideo((await _file()).path);

  Future<void> _share() async => MediaCache.shareFile(await _file());

  Future<void> _menu() async {
    final l10n = context.l10n;
    final snacks = AppSnacks.of(context);
    final action = await showAppMenu<_VideoAction>(
      context,
      title: widget.name,
      items: [
        if (_ready)
          AppMenuItem(
            value: _VideoAction.fullScreen,
            label: l10n.mediaFullScreen,
            icon: CupertinoIcons.arrow_up_left_arrow_down_right,
          ),
        AppMenuItem(
          value: _VideoAction.save,
          label: l10n.mediaSave,
          icon: CupertinoIcons.arrow_down_to_line,
        ),
        AppMenuItem(
          value: _VideoAction.share,
          label: l10n.attachShare,
          icon: CupertinoIcons.square_arrow_up,
        ),
      ],
    );
    try {
      switch (action) {
        case _VideoAction.fullScreen:
          await _openFull();
        case _VideoAction.save:
          await _save();
          snacks.show(l10n.mediaSaved);
        case _VideoAction.share:
          await _share();
        case null:
      }
    } on Object catch (e) {
      log.w('video ${action?.name} failed', error: e);
      snacks.show(
        action == _VideoAction.save
            ? l10n.mediaVideoSaveFailed
            : l10n.attachDownloadFailed(widget.name),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Another player started: this one gives way.
    ref.listen(nowPlayingProvider, (_, playing) {
      if (!identical(playing, this) && _playing) {
        unawaited(_controller?.pause());
      }
    });
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
    final aspect = _ready && controller!.value.aspectRatio > 0
        ? controller.value.aspectRatio
        : _aspects[_key] ?? context.spacing.mediaAspect;
    return _frame(
      context,
      aspect,
      _started && controller != null
          ? VideoView(
              controller: controller,
              onFullScreen: () => unawaited(_openFull()),
              onMenu: () => unawaited(_menu()),
            )
          : _poster(context, controller),
    );
  }

  /// Before the first play: the first frame (once loaded), a play button and
  /// the length.
  Widget _poster(BuildContext context, VideoPlayerController? controller) {
    final colors = context.colors;
    final spacing = context.spacing;
    final l10n = context.l10n;
    final duration = _ready ? controller!.value.duration : null;
    return Theme(
      data: videoTheme(context),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _play,
        onLongPress: () => unawaited(_menu()),
        onSecondaryTap: () => unawaited(_menu()),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: colors.scrimSolid),
            if (_ready) VideoPlayer(controller!),
            Center(
              child: AppIconButton(
                icon: CupertinoIcons.play_fill,
                tooltip: l10n.mediaPlay,
                busy: _playWhenReady && !_ready,
                onPressed: _play,
              ),
            ),
            if (duration != null && duration > Duration.zero)
              PositionedDirectional(
                end: spacing.sm,
                bottom: spacing.sm,
                // On a solid pill: text on a picture loses contrast.
                child: AppSurface(
                  color: colors.scrimSolid,
                  border: false,
                  borderRadius: BorderRadius.circular(context.radii.pill),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xxs,
                  ),
                  child: Text(
                    Format.duration(duration),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.onScrim,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _frame(BuildContext context, double aspect, Widget child) {
    final cap =
        MediaQuery.sizeOf(context).height *
        context.spacing.mediaMaxHeightFraction;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: cap),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.radii.md),
          child: AspectRatio(aspectRatio: aspect, child: child),
        ),
      ),
    );
  }
}
