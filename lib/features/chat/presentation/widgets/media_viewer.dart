import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/api/hermes_api.dart';
import '../../../../hermes/client/hermes_client.dart';
import '../../../connection/presentation/connection_providers.dart';
import 'media_strip.dart';
import 'picture_actions.dart';

/// Full-screen gallery: swipe between pictures, pinch to zoom, tap to hide
/// the chrome, drag down to close, save and share from the top bar.
class MediaViewerPage extends ConsumerStatefulWidget {
  const MediaViewerPage({
    required this.items,
    super.key,
    this.initialIndex = 0,
  });

  final List<MediaItem> items;
  final int initialIndex;

  /// A fading full-screen route; reduced motion switches at once.
  static Future<void> open(
    BuildContext context, {
    required List<MediaItem> items,
    int initialIndex = 0,
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
        pageBuilder: (_, _, _) =>
            MediaViewerPage(items: items, initialIndex: initialIndex),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  ConsumerState<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends ConsumerState<MediaViewerPage> {
  late final PageController _pages = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;
  bool _chrome = true;
  bool _busy = false;
  double _drag = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _run(
    Future<void> Function(MediaItem item, HermesClient? c, HermesApi? a) job, {
    String? done,
    required String failed,
  }) async {
    final snacks = AppSnacks.of(context);
    setState(() => _busy = true);
    try {
      await job(
        widget.items[_index],
        ref.read(hermesClientProvider),
        ref.read(hermesApiProvider),
      );
      if (done != null) snacks.show(done);
    } on Object catch (e) {
      log.w('media save or share failed', error: e);
      snacks.show(failed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final l10n = context.l10n;
    final scrim = colors.scrimSolid;
    final dismissAt = spacing.dragToDismiss;
    final fade = (1 - _drag.abs() / (dismissAt * 2)).clamp(
      context.motion.viewerDragMinOpacity,
      1.0,
    );
    final item = widget.items[_index];
    return Scaffold(
      backgroundColor: scrim.withValues(alpha: fade),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _chrome = !_chrome),
        onVerticalDragUpdate: (d) => setState(() => _drag += d.delta.dy),
        onVerticalDragEnd: (_) {
          if (_drag.abs() > dismissAt) {
            Navigator.of(context).maybePop();
          } else {
            setState(() => _drag = 0);
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Transform.translate(
              offset: Offset(0, _drag),
              child: PhotoViewGallery.builder(
                pageController: _pages,
                itemCount: widget.items.length,
                onPageChanged: (i) => setState(() => _index = i),
                backgroundDecoration: BoxDecoration(
                  color: scrim.withValues(alpha: 0),
                ),
                // A remote picture on its way: say so, not a black screen.
                loadingBuilder: (context, _) =>
                    Center(child: AppSpinner(color: colors.onScrim)),
                builder: (context, i) => PhotoViewGalleryPageOptions(
                  imageProvider: widget.items[i].provider,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale:
                      PhotoViewComputedScale.covered * AppConfig.viewerMaxZoom,
                  errorBuilder: (context, _, _) => Center(
                    child: Icon(CupertinoIcons.photo, color: colors.onScrim),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedOpacity(
                opacity: _chrome ? 1 : 0,
                duration: context.reduceMotion
                    ? Duration.zero
                    : context.motion.fast,
                child: IgnorePointer(
                  ignoring: !_chrome,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(spacing.gutter),
                      child: Row(
                        children: [
                          AppIconButton(
                            icon: CupertinoIcons.xmark,
                            tooltip: l10n.actionClose,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          const Spacer(),
                          // On a solid pill: text on a picture loses contrast.
                          if (widget.items.length > 1)
                            AppSurface(
                              color: colors.scrimSolid,
                              border: false,
                              borderRadius: BorderRadius.circular(
                                context.radii.pill,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.md,
                                vertical: spacing.xs,
                              ),
                              child: Text(
                                l10n.mediaViewerCounter(
                                  _index + 1,
                                  widget.items.length,
                                ),
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: colors.onScrim),
                              ),
                            ),
                          const Spacer(),
                          AppIconButton(
                            icon: CupertinoIcons.arrow_down_to_line,
                            tooltip: l10n.mediaSave,
                            onPressed: _busy
                                ? null
                                : () => _run(
                                    (i, c, a) =>
                                        saveToGallery(i, client: c, api: a),
                                    done: l10n.mediaSaved,
                                    failed: l10n.mediaSaveFailed,
                                  ),
                          ),
                          SizedBox(width: spacing.xs),
                          AppIconButton(
                            icon: CupertinoIcons.square_arrow_up,
                            tooltip: l10n.attachShare,
                            onPressed: _busy
                                ? null
                                : () => _run(
                                    (i, c, a) =>
                                        sharePicture(i, client: c, api: a),
                                    failed: l10n.attachDownloadFailed(
                                      item.fileName,
                                    ),
                                  ),
                          ),
                        ],
                      ),
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
}
