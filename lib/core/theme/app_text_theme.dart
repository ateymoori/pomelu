import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';

import 'tokens.dart';

/// The UI font: the system's (SF Pro) on iOS, Inter elsewhere.
String? appUiFamily(HermesTokens t) =>
    defaultTargetPlatform == TargetPlatform.iOS ? null : t.text.uiFamily;

/// The type scale of [t]. Slots in use: `titleMedium` (17/600), `bodyLarge`
/// (17, fields), `bodyMedium` (16), `bodySmall` (13), `labelLarge` (16/600,
/// buttons), `labelMedium` (13/500), `labelSmall` (12/500).
TextTheme appTextTheme(HermesTokens t) {
  final s = t.text;
  final c = t.colors;
  final font = appUiFamily(t);
  TextStyle style(double size, FontWeight w, [Color? color]) => TextStyle(
    fontFamily: font,
    fontSize: size,
    fontWeight: w,
    height: s.lineHeight,
    color: color ?? c.textPrimary,
    letterSpacing: size >= s.title2 ? s.titleTracking : 0,
  );
  return TextTheme(
    displayLarge: style(s.largeTitle, FontWeight.w700),
    headlineLarge: style(s.title1, FontWeight.w700),
    headlineMedium: style(s.title2, FontWeight.w600),
    headlineSmall: style(s.title3, FontWeight.w600),
    titleLarge: style(s.title3, FontWeight.w600),
    titleMedium: style(s.headline, FontWeight.w600),
    titleSmall: style(s.subheadline, FontWeight.w600),
    bodyLarge: style(s.body, FontWeight.w400),
    bodyMedium: style(s.callout, FontWeight.w400),
    bodySmall: style(s.footnote, FontWeight.w400, c.textSecondary),
    labelLarge: style(s.callout, FontWeight.w600),
    labelMedium: style(s.footnote, FontWeight.w500, c.textSecondary),
    labelSmall: style(s.caption, FontWeight.w500, c.textTertiary),
  );
}
