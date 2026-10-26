import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../hermes/models/context_breakdown.dart';

const List<String> _categoryOrder = [
  ContextCategoryId.systemPrompt,
  ContextCategoryId.tools,
  ContextCategoryId.rules,
  ContextCategoryId.skills,
  ContextCategoryId.mcp,
  ContextCategoryId.subagents,
  ContextCategoryId.memory,
  ContextCategoryId.conversation,
];

/// The series color of category [id].
Color contextPartColor(BuildContext context, String id, int fallbackIndex) {
  final chart = context.colors.chart;
  final known = _categoryOrder.indexOf(id);
  return chart[(known < 0 ? fallbackIndex : known) % chart.length];
}

/// One bar for the whole window: a segment per part, then the free rest.
///
/// The parts are estimates and the used figure may be the provider's exact
/// count, so the segments are scaled to fill exactly [used]: the bar's end
/// matches the headline number, and each part keeps its estimated share.
class ContextBar extends StatelessWidget {
  const ContextBar({
    required this.used,
    required this.max,
    required this.parts,
    super.key,
  });

  final int used;
  final int max;

  /// (color, tokens) per part; empty draws one accent segment.
  final List<(Color, int)> parts;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final fill = max <= 0 ? 0.0 : (used / max).clamp(0.0, 1.0);
    final estimated = parts.fold<int>(0, (sum, p) => sum + p.$2);
    final segments = <(Color, double)>[
      if (estimated <= 0)
        (colors.accent, fill)
      else
        for (final (color, tokens) in parts)
          if (tokens > 0) (color, tokens / estimated * fill),
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.radii.pill),
      child: SizedBox(
        height: spacing.sm,
        child: ColoredBox(
          color: colors.track,
          child: LayoutBuilder(
            builder: (context, box) => Row(
              // A segment has no child to size it; it takes the bar's height.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (color, share) in segments)
                  SizedBox(
                    width: box.maxWidth * share,
                    child: ColoredBox(color: color),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A label with a value at the end, an optional mark at the start and an
/// optional note under the label.
class ContextRow extends StatelessWidget {
  const ContextRow({
    required this.label,
    required this.value,
    super.key,
    this.leading,
    this.note,
    this.noteColor,
  });

  final String label;
  final String value;
  final Widget? leading;
  final String? note;
  final Color? noteColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;
    final spacing = context.spacing;
    final mark = leading;
    final remark = note;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mark != null) ...[
            // One text line tall at any text scale, so the mark sits on the
            // label's first line.
            SizedBox(
              width: spacing.lg,
              height: MediaQuery.textScalerOf(context)
                  .scale(spacing.lg + spacing.xs),
              child: Center(child: mark),
            ),
            SizedBox(width: spacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.bodyMedium),
                if (remark != null)
                  Text(
                    remark,
                    style: theme.bodySmall?.copyWith(
                      color: noteColor ?? colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: spacing.md),
          Text(
            value,
            style: theme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              fontFeatures: context.textScale.tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}

/// The state of a context file as one small icon.
Widget contextFileMark(BuildContext context, ContextFile file) {
  final colors = context.colors;
  final loaded = (CupertinoIcons.checkmark_circle, colors.success);
  final (icon, color) = switch (file.status) {
    'loaded' => loaded,
    'truncated' ||
    'flagged' => (CupertinoIcons.exclamationmark_circle, colors.warning),
    'blocked' || 'unreadable' => (CupertinoIcons.nosign, colors.danger),
    _ when file.loaded => loaded,
    _ => (CupertinoIcons.minus_circle, colors.textTertiary),
  };
  return Icon(icon, size: context.spacing.lg, color: color);
}
