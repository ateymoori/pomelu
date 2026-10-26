import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';

/// The side menu's pane, open or collapsed to the rail: the page fill (the
/// elevated one in a drawer) with a hairline on its end edge, clear of the
/// system bars, holding [children] top to bottom. Its first child starts on
/// the chat bar's line: the top inset, or [Spacing.sm] with none.
class SidebarFrame extends StatelessWidget {
  const SidebarFrame({
    required this.children,
    super.key,
    this.width,
    this.elevated = false,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final List<Widget> children;

  /// Null fills the parent.
  final double? width;
  final bool elevated;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    // The end edge meets the chat, not the screen: an inset there (the open
    // iPhone Duo's status bar column) belongs to the chat, and every ListTile
    // in the pane would otherwise pad by it.
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: elevated
              ? surfaces.surfaceElevated
              : context.colors.backdropMid,
          border: BorderDirectional(
            end: BorderSide(
              color: surfaces.outline,
              width: surfaces.borderWidth,
            ),
          ),
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeLeft: rtl,
          removeRight: !rtl,
          child: SafeArea(
            minimum: EdgeInsets.only(top: context.spacing.sm),
            child: Column(
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
