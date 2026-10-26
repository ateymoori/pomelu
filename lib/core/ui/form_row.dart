import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// One row of a [FormSection], as a row of an iOS grouped list: a title,
/// an optional line under it, and at the end a [value], a [trailing]
/// control (a switch, a button) or, when the row opens something
/// ([navigates]), a chevron.
class FormRow extends StatelessWidget {
  const FormRow({
    required this.title,
    super.key,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.navigates = false,
    this.titleStyle,
  });

  final String title;
  final String? subtitle;

  /// Text in the secondary colour at the end ("1.0.0").
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Shows the chevron: the row opens a page or a sheet.
  final bool navigates;

  /// Overrides the title's style (a mono id).
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final subtitle = this.subtitle;
    final value = this.value;
    final trailing = this.trailing;

    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: spacing.minTouch),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: spacing.lg,
          vertical: spacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: titleStyle ?? text.bodyLarge),
                  if (subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: spacing.xxs),
                      child: Text(
                        subtitle,
                        style: text.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (value != null) ...[
              SizedBox(width: spacing.sm),
              Text(
                value,
                style: text.bodyLarge?.copyWith(color: colors.textSecondary),
              ),
            ],
            if (trailing != null) ...[SizedBox(width: spacing.sm), trailing],
            if (navigates) ...[
              SizedBox(width: spacing.xs),
              Icon(
                CupertinoIcons.chevron_right,
                size: spacing.lg,
                color: colors.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
    final tap = onTap;
    if (tap == null) return MergeSemantics(child: row);
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(onTap: tap, child: row),
      ),
    );
  }
}
