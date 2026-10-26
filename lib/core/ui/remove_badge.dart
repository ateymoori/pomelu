import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The "remove" mark on a pending attachment, in a `Stack` over the item: a
/// small dot on a full `minTouch` target in the top-end corner.
class RemoveBadge extends StatelessWidget {
  const RemoveBadge({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback onPressed;

  /// Room the dot takes, so content can keep clear of it.
  static double extentOf(BuildContext context) {
    final spacing = context.spacing;
    return spacing.xs + _dotOf(spacing);
  }

  static double _dotOf(Spacing spacing) => spacing.md + spacing.xs * 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    return PositionedDirectional(
      top: 0,
      end: 0,
      width: spacing.minTouch,
      height: spacing.minTouch,
      child: Semantics(
        button: true,
        label: label,
        // `excludeSemantics` drops the detector's tap, so this carries it.
        onTap: onPressed,
        excludeSemantics: true,
        child: Tooltip(
          message: label,
          excludeFromSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: EdgeInsets.all(spacing.xs),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(spacing.xs),
                    child: Icon(
                      CupertinoIcons.xmark,
                      size: spacing.md,
                      color: colors.backdropMid,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
