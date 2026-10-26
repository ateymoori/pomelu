import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A row that opens and closes what sits under it: a button that says
/// whether it is expanded, ink on tap, and a chevron. With no [onToggle]
/// there is nothing to open: no chevron, not a button.
class DisclosureRow extends StatelessWidget {
  const DisclosureRow({
    required this.open,
    required this.onToggle,
    required this.children,
    super.key,
    this.chevronFirst = false,
    this.minHeight,
    this.padding,
    this.borderRadius,
  });

  final bool open;
  final VoidCallback? onToggle;

  /// The row's content, laid out in a `Row`.
  final List<Widget> children;

  /// The chevron leads and points right when closed, as in a tree; else it
  /// trails and points down.
  final bool chevronFirst;

  /// Defaults to `spacing.inlineRow`, one text line.
  final double? minHeight;
  final EdgeInsetsGeometry? padding;

  /// The ink's corners; defaults to `radii.sm`.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final toggles = onToggle != null;
    final chevron = Icon(
      chevronFirst
          ? (open ? CupertinoIcons.chevron_down : CupertinoIcons.chevron_right)
          : (open ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down),
      size: spacing.lg,
      color: context.colors.textTertiary,
    );
    return Semantics(
      button: toggles,
      expanded: toggles ? open : null,
      child: InkWell(
        onTap: onToggle,
        borderRadius: borderRadius ?? BorderRadius.circular(context.radii.sm),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: minHeight ?? spacing.inlineRow,
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Row(
              children: [
                if (toggles && chevronFirst) ...[
                  chevron,
                  SizedBox(width: spacing.sm),
                ],
                ...children,
                if (toggles && !chevronFirst) ...[
                  SizedBox(width: spacing.xs),
                  chevron,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
