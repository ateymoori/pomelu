import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/markdown_segments.dart';
import 'code_block.dart';
import 'link_card.dart';
import 'markdown_details.dart';
import 'markdown_image.dart';
import 'markdown_links.dart';
import 'message_search.dart';

part 'markdown_parts.dart';

/// A Markdown image, for its alt text: the package's builder gets the URL.
final RegExp _imageAlt = RegExp(r'!\[([^\]]*)\]\(\s*(\S+?)\s*\)');

typedef _Parsed = ({String text, Map<String, String> alts});

/// Chat Markdown: `gpt_markdown` styled from the tokens, with our own code
/// blocks, task lists, disclosures, link cards and pictures. Selectable,
/// with the long-press copy menu of a [SelectionArea].
class MarkdownBody extends StatefulWidget {
  const MarkdownBody(
    this.data, {
    super.key,
    this.style,
    this.selectable = true,
    this.onMoreActions,
    this.direction,
  });

  final String data;

  /// Defaults to `bodyLarge`.
  final TextStyle? style;
  final bool selectable;

  /// A "More" button in the selection toolbar: a long press selects text, so
  /// without it the message menu would be out of reach on a reply.
  final VoidCallback? onMoreActions;

  /// The direction of the whole reply, for one piece of it; else what
  /// [data] reads as.
  final TextDirection? direction;

  @override
  State<MarkdownBody> createState() => _MarkdownBodyState();
}

class _MarkdownBodyState extends State<MarkdownBody> {
  // Parsed once per text, not per build: a streaming reply rebuilds this on
  // every token, and the split runs on the UI thread.
  late List<MarkdownSegment> _segments;
  late Map<String, _Parsed> _parsed;
  late TextDirection _direction;

  @override
  void initState() {
    super.initState();
    _parse();
  }

  @override
  void didUpdateWidget(MarkdownBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.direction != widget.direction) {
      _parse();
    }
  }

  void _parse() {
    _direction = widget.direction ?? markdownDirection(widget.data);
    _segments = MarkdownSegments.split(widget.data);
    _parsed = {
      for (final segment in _segments)
        if (segment is MarkdownTextSegment)
          segment.text: (
            text: MarkdownSegments.normalizeTaskLists(segment.text),
            alts: {
              for (final m in _imageAlt.allMatches(segment.text))
                m.group(2)!: m.group(1) ?? '',
            },
          ),
    };
  }

  @override
  Widget build(BuildContext context) {
    // The find scope: a query repaints the hits, not the cached rows.
    final query = MessageSearchScope.queryOf(context);
    Widget piece(MarkdownSegment segment) => switch (segment) {
      MarkdownTextSegment(:final text) => _markdown(
        context,
        _parsed[text]!,
        query,
      ),
      MarkdownDetailsSegment(:final summary, :final body, :final open) =>
        MarkdownDetails(
          summary: summary,
          initiallyOpen: open,
          builder: (context) => MarkdownBody(
            body,
            style: widget.style,
            selectable: false,
            direction: _direction,
          ),
        ),
      MarkdownLinkSegment(:final target) => LinkCard(target: target),
    };
    final body = _segments.length == 1
        ? piece(_segments.single)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [for (final s in _segments) piece(s)],
          );

    // Right to left text fills the row: its lines start at the row's right
    // edge, and a one-line heading would otherwise sit at the left.
    return Directionality(
      textDirection: _direction,
      child: SizedBox(
        width: _direction == TextDirection.rtl ? double.infinity : null,
        child: widget.selectable
            ? SelectionArea(
                contextMenuBuilder: widget.onMoreActions == null
                    ? null
                    : (menuContext, selection) =>
                          AdaptiveTextSelectionToolbar.buttonItems(
                            anchors: selection.contextMenuAnchors,
                            buttonItems: [
                              ...selection.contextMenuButtonItems,
                              ContextMenuButtonItem(
                                label: menuContext.l10n.chatMoreActions,
                                onPressed: () {
                                  selection.hideToolbar();
                                  selection.clearSelection();
                                  widget.onMoreActions!();
                                },
                              ),
                            ],
                          ),
                child: body,
              )
            : body,
      ),
    );
  }

  Widget _markdown(BuildContext context, _Parsed parsed, String? query) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radii;
    final scale = context.textScale;
    final theme = Theme.of(context).textTheme;
    final base = widget.style ?? theme.bodyLarge ?? const TextStyle();
    final alts = parsed.alts;

    return GptMarkdown(
      parsed.text,
      style: base,
      // The package lays out left to right unless told, whatever the ambient
      // direction says.
      textDirection: _direction,
      onLinkTap: (url, _) => MarkdownLinks.open(context, url),
      codeBuilder: (context, name, code, closed) =>
          CodeBlock(code: code, language: name),
      imageBuilder: (context, url, width, height) => MarkdownImage(
        url: url,
        alt: alts[url] ?? '',
        width: width,
        height: height,
      ),
      checkboxBuilder: (context, checked, content, checkboxStyle) =>
          _TaskItem(checked: checked, content: content),
      inlinePatterns: [if (query != null) _highlightPattern(query, colors)],
      isStreaming: false,
      styleSheet: GptMarkdownStyleSheet(
        link: LinkStyle(color: colors.accentText),
        hr: HrStyle(
          color: colors.divider,
          thickness: context.surfaces.borderWidth,
          padding: EdgeInsets.symmetric(vertical: spacing.sm),
        ),
        list: ListStyle(
          bulletColor: colors.textTertiary,
          indent: spacing.lg,
          gapAfterMarker: spacing.sm,
          markerTextStyle: (theme.bodySmall ?? const TextStyle()).copyWith(
            color: colors.textTertiary,
          ),
        ),
        blockQuote: BlockQuoteStyle(
          barColor: colors.accent,
          barWidth: spacing.xs,
          barRadius: Radius.circular(radii.xs),
          backgroundColor: colors.reasoningSurface,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          margin: EdgeInsets.symmetric(vertical: spacing.xs),
        ),
        table: TableStyle(
          borderColor: colors.divider,
          borderWidth: context.surfaces.borderWidth,
          borderRadius: Radius.circular(radii.sm),
          headerBackground: colors.toolSurface,
          rowStripeColor: colors.tableStripe,
          headerTextStyle: theme.labelLarge,
          cellPadding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
        ),
        inlineCode: InlineCodeStyle(
          fontFamily: scale.monoFamily,
          color: colors.codeText,
          backgroundColor: colors.codeBackground,
          borderColor: colors.divider,
          borderWidth: context.surfaces.borderWidth,
          borderRadius: Radius.circular(radii.xs),
          padding: EdgeInsets.symmetric(horizontal: spacing.xs),
        ),
      ),
    );
  }
}

/// One piece of a long Markdown text cut by `MarkdownChunks`: the blank
/// line that stood before it, when one did, then its Markdown in the whole
/// text's [direction].
class MarkdownPiece extends StatelessWidget {
  const MarkdownPiece(
    this.text, {
    super.key,
    this.gap = false,
    this.style,
    this.direction,
    this.onMoreActions,
  });

  final String text;
  final bool gap;
  final TextStyle? style;
  final TextDirection? direction;
  final VoidCallback? onMoreActions;

  @override
  Widget build(BuildContext context) {
    final body = MarkdownBody(
      text,
      style: style,
      onMoreActions: onMoreActions,
      direction: direction,
    );
    if (!gap) return body;
    final size =
        (style ?? Theme.of(context).textTheme.bodyLarge)?.fontSize ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: size * context.textScale.blockGapScale),
        body,
      ],
    );
  }
}
