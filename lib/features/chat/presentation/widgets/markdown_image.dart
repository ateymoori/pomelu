import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import 'media_strip.dart';
import 'media_viewer.dart';

/// A picture referenced from Markdown (`![alt](url)`).
///
/// The package default paints an unbounded box that swells to the full
/// reading column and, on failure, leaves a large blank rectangle with a
/// generic glyph. This keeps the picture inside the column, gives it a
/// hairline edge, and degrades to a **compact** chip that names the picture
/// and offers a retry instead of reserving a screenful of nothing.
class MarkdownImage extends StatefulWidget {
  const MarkdownImage({
    required this.url,
    super.key,
    this.alt = '',
    this.width,
    this.height,
    this.providerOverride,
  });

  /// Absolute source URL taken from the Markdown link.
  final String url;

  /// Alt text from the Markdown, used as the semantic label and as the
  /// caption of the failed state. May be empty.
  final String alt;

  /// Explicit box from an `WxH` alt text, when the author gave one.
  final double? width;
  final double? height;

  /// Replaces the network provider. The cached provider never resolves under
  /// the test binding, so a test injects one that resolves or fails at once.
  @visibleForTesting
  final ImageProvider? providerOverride;

  @override
  State<MarkdownImage> createState() => _MarkdownImageState();
}

class _MarkdownImageState extends State<MarkdownImage> {
  int _attempt = 0;

  String get _label {
    final alt = widget.alt.trim();
    if (alt.isNotEmpty) return alt;
    final uri = Uri.tryParse(widget.url);
    if (uri == null) return widget.url;
    final last = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
    return last.isNotEmpty ? last : uri.host;
  }

  String get _origin {
    final uri = Uri.tryParse(widget.url);
    return uri == null || uri.host.isEmpty ? widget.url : uri.host;
  }

  void _retry() {
    unawaited(_displayed(context).evict());
    unawaited(_source.evict());
    setState(() => _attempt++);
  }

  ImageProvider<Object> get _source =>
      widget.providerOverride ?? _item?.provider ?? NetworkImage(widget.url);

  ImageProvider<Object> _displayed(BuildContext context) =>
      ResizeImage.resizeIfNeeded(_decodeWidth(context), null, _source);

  MediaItem? get _item => MediaItem.fromUrl(widget.url, alt: widget.alt);

  void _open() {
    final item = _item;
    if (item == null) return;
    unawaited(MediaViewerPage.open(context, items: [item]));
  }

  int _decodeWidth(BuildContext context) {
    final box = widget.width ?? context.spacing.readingWidth;
    final screen = MediaQuery.sizeOf(context).width;
    return (math.min(box, screen) * MediaQuery.devicePixelRatioOf(context))
        .round();
  }

  Widget _tappable(BuildContext context, Widget picture, MediaItem? item) {
    if (item == null) {
      return Semantics(image: true, label: _label, child: picture);
    }
    return Semantics(
      image: true,
      button: true,
      label: '$_label, ${context.l10n.chatOpenImage}',
      child: TapInk(
        borderRadius: BorderRadius.circular(context.radii.md),
        onTap: _open,
        child: picture,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = context.l10n;
    final item = _item;
    // A tall picture may not push the conversation off a short screen.
    final maxHeight = math.min(
      widget.height ?? spacing.readingWidth,
      MediaQuery.sizeOf(context).height * spacing.mediaMaxHeightFraction,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.width ?? spacing.readingWidth,
          maxHeight: maxHeight,
        ),
        // No fill: a picture with a transparent background keeps the
        // backdrop.
        child: AppSurface(
          color: Colors.transparent,
          clip: true,
          child: Image(
            // The viewer's provider, wrapped to decode at display size:
            // opening a picture never re-downloads it, and a 12 MP original
            // is never decoded in full (about 48 MB each) just to fill a
            // phone-wide column while the transcript scrolls.
            image: _displayed(context),
            key: ValueKey('${widget.url}#$_attempt'),
            width: widget.width,
            height: widget.height,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) => progress == null
                ? _tappable(context, child, item)
                : MediaStatusChip(
                    icon: CupertinoIcons.photo,
                    title: _label,
                    subtitle: l10n.chatImageLoading,
                    busy: true,
                  ),
            errorBuilder: (context, _, _) => MediaStatusChip(
              icon: CupertinoIcons.photo,
              title: _label,
              subtitle: l10n.chatJoinDot(l10n.chatImageFailed, _origin),
              onRetry: _retry,
            ),
          ),
        ),
      ),
    );
  }
}
