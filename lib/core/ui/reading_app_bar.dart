import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'app_close_button.dart';
import 'reading_column.dart';
import 'scroll_edge.dart';

/// The bar of a full-screen page as iOS 26+ draws it: no slab, the close
/// button and the [action] (such as Save) as floating glass circles, the
/// title centred between them, and a soft scroll edge so content fades away
/// under it. Give the page's `Scaffold` `extendBodyBehindAppBar: true` so
/// content scrolls under it; the body then pads by
/// `MediaQuery.paddingOf(context).top`.
AppBar readingAppBar(
  BuildContext context, {
  required String title,
  required VoidCallback onClose,
  String? subtitle,
  Widget? action,
}) {
  final spacing = context.spacing;
  final textTheme = Theme.of(context).textTheme;

  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Colors.transparent,
    flexibleSpace: const ScrollEdge(child: SizedBox.expand()),
    titleSpacing: 0,
    centerTitle: false,
    title: ReadingColumn(
      child: Row(
        children: [
          AppCloseButton(onPressed: onClose),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textTheme.labelMedium,
                  ),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          // The other end balances the close button, so the title stays
          // centred on the page.
          action ?? SizedBox.square(dimension: spacing.minTouch),
        ],
      ),
    ),
  );
}
