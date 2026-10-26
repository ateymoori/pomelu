import 'package:flutter/material.dart';

import 'tokens.dart';

/// Every [ColorScheme] role from a token of [t]: the accent for primary,
/// secondary and tertiary; the page as `surface`, climbing through the card
/// and elevated levels.
ColorScheme appColorScheme(HermesTokens t, Brightness brightness) {
  final c = t.colors;
  final s = t.surfaces;
  // Containers are opaque: the translucent tint, settled on the page.
  Color tint(Color fill) => Color.alphaBlend(fill, c.backdropMid);
  final accentTint = tint(c.accentSoft);
  return ColorScheme(
    brightness: brightness,
    primary: c.accent,
    onPrimary: c.onAccent,
    primaryContainer: accentTint,
    onPrimaryContainer: c.textPrimary,
    secondary: c.accent,
    onSecondary: c.onAccent,
    secondaryContainer: accentTint,
    onSecondaryContainer: c.textPrimary,
    tertiary: c.accent,
    onTertiary: c.onAccent,
    tertiaryContainer: accentTint,
    onTertiaryContainer: c.textPrimary,
    error: c.danger,
    onError: c.onDanger,
    errorContainer: tint(c.dangerSoft),
    onErrorContainer: c.danger,
    surface: c.backdropMid,
    onSurface: c.textPrimary,
    surfaceDim: s.surface,
    surfaceBright: s.surfaceElevated,
    surfaceContainerLowest: c.backdropMid,
    surfaceContainerLow: s.surface,
    surfaceContainer: s.surfaceElevated,
    surfaceContainerHigh: s.surfaceElevated,
    surfaceContainerHighest: s.surfacePressed,
    onSurfaceVariant: c.textSecondary,
    outline: c.inputOutline,
    outlineVariant: s.outline,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: c.textPrimary,
    onInverseSurface: c.backdropMid,
    inversePrimary: c.inverseAccent,
    surfaceTint: Colors.transparent,
  );
}
