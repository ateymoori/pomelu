import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'shimmer_line.dart';

/// A placeholder row: an optional avatar, an optional title block, then a
/// full-width line. The caller pads it like the real row.
class SkeletonRow extends StatelessWidget {
  const SkeletonRow({
    super.key,
    this.avatar = false,
    this.title = false,
    this.titleGap,
    this.lineHeight,
  });

  final bool avatar;

  /// A title block over the line, `spacing.skeletonTitleShare` wide.
  final bool title;

  /// Defaults to `spacing.xs`.
  final double? titleGap;
  final double? lineHeight;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final line = ShimmerLine(height: lineHeight);
    return Row(
      children: [
        if (avatar) ...[
          ShimmerLine(
            width: spacing.avatar,
            height: spacing.avatar,
            borderRadius: BorderRadius.circular(context.radii.pill),
          ),
          SizedBox(width: spacing.md),
        ],
        Expanded(
          child: !title
              ? line
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: spacing.skeletonTitleShare,
                      child: ShimmerLine(height: spacing.lg),
                    ),
                    SizedBox(height: titleGap ?? spacing.xs),
                    line,
                  ],
                ),
        ),
      ],
    );
  }
}
