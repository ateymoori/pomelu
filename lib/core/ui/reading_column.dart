import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The app's one reading column: the gutters, then at most
/// `spacing.readingWidth`, centred. Every edge on screen lines up with it.
class ReadingColumn extends StatelessWidget {
  const ReadingColumn({
    required this.child,
    super.key,
    this.padding,
    this.gutter = true,
  });

  final Widget child;

  /// Extra inset inside the gutters.
  final EdgeInsetsGeometry? padding;

  /// False where the parent already pads by the gutters.
  final bool gutter;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    Widget column = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: spacing.readingWidth),
        child: child,
      ),
    );
    final inset = padding;
    if (inset != null) column = Padding(padding: inset, child: column);
    if (!gutter) return column;
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: spacing.gutter),
      child: column,
    );
  }
}
