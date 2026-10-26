import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';

/// A `<details>` / `<summary>` disclosure inside a reply.
///
/// Long answers routinely fold their appendix behind a disclosure. Markdown
/// has no syntax for it, so models emit the HTML element; `gpt_markdown`
/// passes it through as literal tags. This renders the real control: the
/// summary is the tap target, the body only builds while it is open, so a
/// collapsed appendix costs nothing to scroll past.
class MarkdownDetails extends StatefulWidget {
  const MarkdownDetails({
    required this.summary,
    required this.builder,
    super.key,
    this.initiallyOpen = false,
  });

  /// Label on the disclosure row. Empty falls back to a localized default.
  final String summary;

  /// Builds the body. Called only while the disclosure is open.
  final WidgetBuilder builder;

  /// `<details open>` starts expanded.
  final bool initiallyOpen;

  @override
  State<MarkdownDetails> createState() => _MarkdownDetailsState();
}

class _MarkdownDetailsState extends State<MarkdownDetails> {
  late bool _open = widget.initiallyOpen;

  /// The user opened or closed it: a streamed `open` no longer moves it.
  bool _touched = false;

  @override
  void didUpdateWidget(MarkdownDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A streamed reply can flip `open` mid-turn.
    if (!_touched &&
        widget.summary != oldWidget.summary &&
        widget.initiallyOpen != oldWidget.initiallyOpen) {
      _open = widget.initiallyOpen;
    }
  }

  void _toggle() => setState(() {
    _touched = true;
    _open = !_open;
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final theme = Theme.of(context).textTheme;
    final label = widget.summary.trim().isEmpty
        ? context.l10n.chatDetailsSummary
        : widget.summary.trim();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: AppSurface(
        borderRadius: BorderRadius.circular(context.radii.md),
        // The header ink spreads into the rounded top corners.
        clip: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // The summary text is the label; the tap stays a semantic action
            // (an excluding wrapper would drop it).
            DisclosureRow(
              open: _open,
              onToggle: _toggle,
              chevronFirst: true,
              minHeight: spacing.minTouch,
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
              // The surface clips the ink to its corners.
              borderRadius: BorderRadius.zero,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (_open) ...[
              Divider(
                height: context.surfaces.borderWidth,
                thickness: context.surfaces.borderWidth,
                color: colors.divider,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.md,
                  spacing.sm,
                  spacing.md,
                  spacing.md,
                ),
                child: Builder(builder: widget.builder),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
