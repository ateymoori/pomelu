import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import 'markdown_body.dart';

/// Collapsible "Thinking" block holding a message's reasoning trace.
class ReasoningChip extends StatefulWidget {
  const ReasoningChip({required this.reasoning, super.key});

  /// Raw reasoning Markdown. Never empty when this widget is built.
  final String reasoning;

  @override
  State<ReasoningChip> createState() => _ReasoningChipState();
}

class _ReasoningChipState extends State<ReasoningChip> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final theme = Theme.of(context).textTheme;

    final label = (theme.labelMedium ?? const TextStyle()).copyWith(
      color: colors.textTertiary,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quiet to look at: a text-height row across the column that says
          // whether it is open.
          DisclosureRow(
            open: _open,
            onToggle: () => setState(() => _open = !_open),
            children: [Text(context.l10n.chatThinking, style: label)],
          ),
          if (_open)
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: spacing.md,
                top: spacing.xs,
                bottom: spacing.sm,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    start: BorderSide(
                      color: context.surfaces.outline,
                      width: context.surfaces.borderWidth * 2,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: spacing.md),
                  child: MarkdownBody(
                    widget.reasoning,
                    style: (theme.bodySmall ?? const TextStyle()).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
