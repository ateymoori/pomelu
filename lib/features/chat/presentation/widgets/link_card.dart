import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../data/link_metadata.dart';
import '../../domain/markdown_segments.dart';
import 'markdown_links.dart';

/// A link alone on its line, as a card instead of a naked URL. A video gets
/// its thumbnail and title (a static image URL and the oEmbed document, no
/// page fetch, no player); any other host a compact row.
class LinkCard extends ConsumerWidget {
  const LinkCard({required this.target, super.key});

  final LinkTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final subtitle = target.isVideo
        ? l10n.chatJoinDot(l10n.chatLinkYouTube, target.host)
        : target.host;
    void open() => MarkdownLinks.open(context, target.url);
    final oEmbed = target.oEmbedUri;
    final title =
        (oEmbed == null ? null : ref.watch(linkTitleProvider(oEmbed)).value) ??
        target.fallbackTitle;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.xs),
      // One link for assistive technology, named by what it shows now.
      child: Semantics(
        link: true,
        label: title,
        onTap: open,
        excludeSemantics: true,
        child: AppSurface(
          borderRadius: BorderRadius.circular(context.radii.md),
          clip: true,
          // Ink over the thumbnail, which would hide it from under.
          child: TapInk(
            onTap: open,
            child: target.isVideo
                ? _VideoCard(title: title, subtitle: subtitle, target: target)
                : _GenericCard(title: title, subtitle: subtitle),
          ),
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.title,
    required this.subtitle,
    required this.target,
  });

  final String title;
  final String subtitle;
  final LinkTarget target;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: context.spacing.mediaAspect,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: colors.toolSurface),
              CachedNetworkImage(
                imageUrl: target.thumbnailUrl!,
                fit: BoxFit.cover,
                // A missing thumbnail must not leave a hole: the play badge
                // still identifies the card.
                errorWidget: (context, _, _) => const SizedBox.shrink(),
                placeholder: (context, _) => const SizedBox.shrink(),
              ),
              // A solid dark badge: the translucent scrim would let a bright
              // thumbnail wash out the white glyph.
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.scrimSolid,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(spacing.sm),
                    child: Icon(
                      CupertinoIcons.play_fill,
                      size: spacing.xl,
                      color: colors.onScrim,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(spacing.md),
          child: _Caption(title: title, subtitle: subtitle),
        ),
      ],
    );
  }
}

class _GenericCard extends StatelessWidget {
  const _GenericCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: spacing.minTouch),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.link,
              size: spacing.lg,
              color: context.colors.textTertiary,
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: _Caption(title: title, subtitle: subtitle),
            ),
            Icon(
              CupertinoIcons.arrow_up_right_square,
              size: spacing.lg,
              color: context.colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.bodyMedium,
        ),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: (theme.bodySmall ?? const TextStyle()).copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
