import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The one heading above a group of rows, announced as a heading. The
/// default [padding] is the vertical rhythm only.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.padding});

  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding:
          padding ??
          EdgeInsetsDirectional.only(top: spacing.lg, bottom: spacing.xs),
      // A node of its own, or it would merge with the rows below.
      child: Semantics(
        container: true,
        header: true,
        child: Text(text, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}
