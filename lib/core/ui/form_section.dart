import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'app_spinner.dart';

/// One card of an iOS inset-grouped form, on a `surfaces.grouped` page: an
/// optional header above, rows split by inset hairlines, an optional footer
/// below. A text field in a row is the row itself: no frame, no fill.
class FormSection extends StatelessWidget {
  const FormSection({
    required this.children,
    super.key,
    this.header,
    this.footer,
  });

  final String? header;
  final String? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final surfaces = context.surfaces;
    final theme = Theme.of(context);
    final note = theme.textTheme.bodySmall?.copyWith(
      color: context.colors.textSecondary,
    );
    // Header and footer text start where the rows' text does.
    final textInset = EdgeInsetsDirectional.symmetric(horizontal: spacing.lg);
    final header = this.header;
    final footer = this.footer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: textInset.add(EdgeInsets.only(bottom: spacing.xs)),
            child: Semantics(header: true, child: Text(header, style: note)),
          ),
        Theme(
          data: theme.copyWith(
            listTileTheme: theme.listTileTheme.copyWith(
              contentPadding: EdgeInsetsDirectional.symmetric(
                horizontal: spacing.lg,
              ),
            ),
            inputDecorationTheme: theme.inputDecorationTheme.copyWith(
              filled: false,
              contentPadding: EdgeInsetsDirectional.symmetric(
                horizontal: spacing.lg,
                vertical: spacing.md,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
          child: ClipRSuperellipse(
            borderRadius: BorderRadius.circular(context.radii.xl),
            child: ColoredBox(
              color: surfaces.groupedCell,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, row) in children.indexed) ...[
                    if (i > 0)
                      Divider(
                        height: surfaces.borderWidth,
                        thickness: surfaces.borderWidth,
                        indent: spacing.lg,
                        color: surfaces.outline,
                      ),
                    row,
                  ],
                ],
              ),
            ),
          ),
        ),
        if (footer != null)
          Padding(
            padding: textInset.add(EdgeInsets.only(top: spacing.xs)),
            child: Text(footer, style: note),
          ),
      ],
    );
  }
}

/// A button row of a [FormSection]: a verb in the accent colour, or in the
/// danger colour for one that cannot be undone.
class FormButtonRow extends StatelessWidget {
  const FormButtonRow({
    required this.label,
    required this.onPressed,
    super.key,
    this.destructive = false,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool destructive;

  /// Shows the spinner at the end while the action runs.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final color = destructive ? colors.danger : colors.accentText;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: spacing.minTouch),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: spacing.lg,
              vertical: spacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: onPressed == null
                          ? color.withValues(
                              alpha: context.surfaces.disabledOpacity,
                            )
                          : color,
                    ),
                  ),
                ),
                if (busy) const AppSpinner.icon(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One piece of a card that is too long to build at once (a long file in a
/// lazy list): the card's colour, round corners only on the [first] and the
/// [last] piece, so the pieces read as one [FormSection] card.
class CardSlice extends StatelessWidget {
  const CardSlice({
    required this.child,
    required this.first,
    required this.last,
    super.key,
  });

  final Widget child;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final corner = Radius.circular(context.radii.xl);
    final spacing = context.spacing;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.surfaces.groupedCell,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.vertical(
            top: first ? corner : Radius.zero,
            bottom: last ? corner : Radius.zero,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          spacing.lg,
          first ? spacing.md : 0,
          spacing.lg,
          last ? spacing.md : 0,
        ),
        child: child,
      ),
    );
  }
}
