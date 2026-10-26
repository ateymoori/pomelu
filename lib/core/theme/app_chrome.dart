import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../layout/fold_geometry.dart';
import '../ui/app_glass.dart';
import 'tokens.dart';

/// Transparent system bars (edge to edge) with icons that read on a page of
/// [brightness].
SystemUiOverlayStyle overlayStyleFor(Brightness brightness) {
  final icons = brightness == Brightness.light
      ? Brightness.dark
      : Brightness.light;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: icons,
    statusBarBrightness: brightness,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: icons,
    systemNavigationBarContrastEnforced: false,
  );
}

/// Chrome above the navigator (`MaterialApp.builder`): system bar icons follow
/// the app's theme, not the phone's, and the snack bar is capped at
/// `snackBarMaxWidth` so it does not span both panes of an unfolded Fold;
/// the window's fold is provided once ([FoldScope]).
class AppChrome extends StatelessWidget {
  const AppChrome({required this.child, super.key, this.solidGlass = false});

  final Widget child;

  /// Reduce Transparency is on: every glass pane is solid ([GlassScope]).
  final bool solidGlass;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final width = math.min(
      spacing.snackBarMaxWidth,
      MediaQuery.sizeOf(context).width - spacing.gutter * 2,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyleFor(theme.brightness),
      child: Theme(
        data: theme.copyWith(
          snackBarTheme: theme.snackBarTheme.copyWith(width: width),
        ),
        child: GlassScope(
          solid: solidGlass,
          child: FoldScope(child: child),
        ),
      ),
    );
  }
}
