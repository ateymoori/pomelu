import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'app_glass.dart';

/// How tall a sheet's content may grow.
enum SheetHeight {
  /// As tall as the content (an action sheet).
  content,

  /// As tall as the content, at most `spacing.sheetMaxFraction` of the
  /// screen; a longer content scrolls.
  capped,

  /// Always `spacing.sheetTallFraction` of the screen (a tabbed sheet).
  tall,
}

/// Body of a sheet: drag handle, optional title, content. Open one with
/// [AppSheet.show], so every sheet gets the same barrier and shape.
///
/// As on iOS 27: a sheet shorter than the screen floats inset from the
/// screen's edges, every corner round, with the page peeking around it; a
/// [SheetHeight.tall] one sits on the edges and turns opaque, to keep the
/// focus on its task. On a tablet's window ([isCentred]) every sheet is a
/// card in the middle, as an iPad form sheet: no handle, closed by a tap
/// beside it or Escape.
class AppSheet extends StatelessWidget {
  const AppSheet({
    required this.child,
    super.key,
    this.title,
    this.height = SheetHeight.content,
    this.centred = false,
  });

  /// Flexible, so a scrollable fills the free space.
  final Widget child;
  final String? title;
  final SheetHeight height;

  /// A card in the middle of the window, not one rising from its bottom.
  final bool centred;

  /// Edge inset of a sheet's title and rows, so they line up.
  static double inset(BuildContext context) => context.spacing.xl;

  /// Whether a sheet opened in [context] floats centred: the window takes
  /// two panes and is tall enough for a card with the page around it. A
  /// phone, upright or on its side, keeps the bottom sheet.
  static bool isCentred(BuildContext context) {
    final spacing = context.spacing;
    final window = MediaQuery.sizeOf(context);
    return window.width >= spacing.sidebarWidth + spacing.chatPaneMin &&
        window.height >= spacing.formSheetMinHeight;
  }

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    String? title,
    SheetHeight height = SheetHeight.content,
  }) {
    final colors = context.colors;
    if (isCentred(context)) {
      final motion = context.motion;
      return showGeneralDialog<T>(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context)
            .modalBarrierDismissLabel,
        barrierColor: colors.scrim,
        transitionDuration: motion.normal,
        pageBuilder: (sheetContext, _, _) => AppSheet(
          title: title,
          height: height,
          centred: true,
          child: builder(sheetContext),
        ),
        // Rises a little and fades in, as an iPad form sheet.
        transitionBuilder: (context, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: motion.enter,
          );
          if (context.reduceMotion) {
            return FadeTransition(opacity: curved, child: child);
          }
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(
                begin: Offset(0, motion.sheetRise),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
    }
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: colors.scrim,
      elevation: 0,
      builder: (sheetContext) =>
          AppSheet(title: title, height: height, child: builder(sheetContext)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final inset = AppSheet.inset(context);
    final full = height == SheetHeight.tall;
    final corner = Radius.circular(context.radii.sheet);
    final radius = full && !centred
        ? BorderRadius.vertical(top: corner)
        : BorderRadius.all(corner);
    final gap = full ? 0.0 : spacing.sm;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    // A centred card measures the window above the keyboard, and stops
    // short of a second screen.
    final screen = centred
        ? MediaQuery.sizeOf(context).height - keyboard - 2 * spacing.xl
        : MediaQuery.sizeOf(context).height;
    double cap(double fraction) => centred
        ? math.min(screen * fraction, spacing.formSheetMaxHeight)
        : screen * fraction;
    final body = switch (height) {
      SheetHeight.content => child,
      SheetHeight.capped => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: cap(spacing.sheetMaxFraction)),
        child: child,
      ),
      SheetHeight.tall => SizedBox(
        height: cap(spacing.sheetTallFraction),
        child: child,
      ),
    };

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A centred card is not dragged: no handle, its title as far from
        // the top as from the side.
        if (centred)
          SizedBox(height: inset)
        else
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.sm),
            child: Center(
              child: Container(
                width: spacing.xxl,
                height: spacing.xs,
                decoration: BoxDecoration(
                  color: colors.track,
                  borderRadius: BorderRadius.circular(context.radii.pill),
                ),
              ),
            ),
          ),
        if (title != null)
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              inset,
              0,
              inset,
              spacing.sm,
            ),
            child: Semantics(
              header: true,
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        Flexible(child: body),
        if (centred) SizedBox(height: spacing.lg),
      ],
    );

    if (centred) {
      return Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: SafeArea(
          minimum: EdgeInsets.all(spacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: spacing.sheetMaxWidth),
              child: _SheetPane(full: full, radius: radius, child: content),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(gap, 0, gap, keyboard + gap),
      child: _SheetPane(
        full: full,
        radius: radius,
        child: SafeArea(top: false, child: content),
      ),
    );
  }
}

/// A short sheet floats as glass; a tall one sits on the edges, opaque, on
/// the grouped background its cards (`FormSection`) stand out on, as iOS
/// draws a full-height sheet. Its buttons then float as glass circles.
class _SheetPane extends StatelessWidget {
  const _SheetPane({
    required this.full,
    required this.radius,
    required this.child,
  });

  final bool full;
  final BorderRadius radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedSuperellipseBorder(borderRadius: radius);
    if (full) {
      // Its page and cards raised, as iOS draws a sheet's grouped surfaces.
      final theme = Theme.of(context);
      final tokens = context.tokens;
      final raised = tokens.copyWith(surfaces: tokens.surfaces.elevated);
      return Theme(
        data: theme.copyWith(
          extensions: [
            for (final e in theme.extensions.values)
              if (e is! HermesTokens) e,
            raised,
          ],
        ),
        child: Material(
          color: raised.surfaces.grouped,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      );
    }
    return AppGlass(shape: shape, floating: true, child: child);
  }
}
