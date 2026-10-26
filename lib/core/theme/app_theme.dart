import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_chrome.dart';
import 'app_color_scheme.dart';
import 'app_text_theme.dart';
import 'tokens.dart';

part 'app_control_themes.dart';

/// [ThemeData] for light and dark, built from [HermesTokens]: every stock
/// Material widget is restyled to the flat look, so none falls back to a
/// seed-tinted color.
abstract final class AppTheme {
  static ThemeData light() => _build(HermesTokens.light(), Brightness.light);
  static ThemeData dark() => _build(HermesTokens.dark(), Brightness.dark);

  /// The themes under Increase Contrast (`MaterialApp.highContrastTheme`).
  static ThemeData lightContrast() =>
      _build(HermesTokens.lightContrast(), Brightness.light);
  static ThemeData darkContrast() =>
      _build(HermesTokens.darkContrast(), Brightness.dark);

  static ThemeData _build(HermesTokens t, Brightness brightness) {
    final c = t.colors;
    final s = t.surfaces;
    final sp = t.spacing;
    final r = t.radii;
    final text = appTextTheme(t);
    final k = _Controls(t, text);
    final hairline = k.hairline;
    final menuShape = k.rounded(r.md, hairline);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: appColorScheme(t, brightness),
      scaffoldBackgroundColor: c.backdropMid,
      canvasColor: c.backdropMid,
      fontFamily: appUiFamily(t),
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      dividerColor: c.divider,
      dividerTheme: DividerThemeData(
        color: c.divider,
        thickness: s.borderWidth,
        space: s.borderWidth,
      ),
      iconTheme: IconThemeData(color: c.textPrimary, size: sp.icon),
      appBarTheme: AppBarThemeData(
        // The glass pane is the bar's flexible space (`readingAppBar`). A
        // clear bar cannot tell the status bar its brightness: say it.
        backgroundColor: Colors.transparent,
        systemOverlayStyle: overlayStyleFor(brightness),
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: sp.barHeight,
        titleSpacing: sp.sm,
        centerTitle: false,
        titleTextStyle: text.titleMedium,
        iconTheme: IconThemeData(color: c.textPrimary, size: sp.icon),
      ),
      segmentedButtonTheme: k.segmentedButton,
      tabBarTheme: TabBarThemeData(
        labelColor: c.textPrimary,
        unselectedLabelColor: c.textSecondary,
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge,
        labelPadding: EdgeInsetsDirectional.symmetric(horizontal: sp.md),
        indicatorColor: c.accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: c.divider,
        dividerHeight: s.borderWidth,
        overlayColor: k.ripple,
        tabAlignment: TabAlignment.start,
      ),
      filledButtonTheme: k.filledButton,
      outlinedButtonTheme: k.outlinedButton,
      textButtonTheme: k.textButton,
      iconButtonTheme: k.iconButton,
      inputDecorationTheme: k.inputDecoration,
      chipTheme: k.chip,
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: c.accentSoft,
        selectedColor: c.textPrimary,
        textColor: c.textPrimary,
        iconColor: c.textPrimary,
        titleTextStyle: text.bodyMedium,
        subtitleTextStyle: text.labelMedium,
        minTileHeight: sp.minTouch,
        minVerticalPadding: sp.sm,
        horizontalTitleGap: sp.md,
        contentPadding: EdgeInsetsDirectional.symmetric(horizontal: sp.md),
        shape: k.rounded(r.md),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: s.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        barrierColor: c.scrim,
        shape: k.rounded(r.lg, hairline),
        titleTextStyle: text.titleMedium,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.textSecondary),
      ),
      switchTheme: k.switchTheme,
      sliderTheme: k.slider,
      checkboxTheme: k.checkbox,
      radioTheme: k.radio,
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.textPrimary,
          borderRadius: BorderRadius.circular(r.xs),
        ),
        textStyle: text.bodySmall?.copyWith(color: c.backdropMid),
      ),
      // The inverse of the page, floating clear of the composer. `AppChrome`
      // caps its width.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: c.textPrimary,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.backdropMid),
        actionTextColor: c.inverseAccent,
        disabledActionTextColor: c.backdropMid.withValues(
          alpha: s.disabledOpacity,
        ),
        insetPadding: EdgeInsets.fromLTRB(
          sp.gutter,
          0,
          sp.gutter,
          sp.snackBarBottomInset,
        ),
        shape: k.rounded(r.md, hairline),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.accent,
        selectionColor: c.accentSoft,
        selectionHandleColor: c.accent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accent,
        linearTrackColor: c.track,
        circularTrackColor: Colors.transparent,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(c.inputOutline),
        radius: Radius.circular(r.pill),
        thickness: WidgetStatePropertyAll(sp.xs),
      ),
      // Menus are flat like dialogs; their items read as rows, not buttons.
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(s.surfaceElevated),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(menuShape),
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(text.bodyMedium),
          foregroundColor: WidgetStatePropertyAll(c.textPrimary),
          iconColor: WidgetStatePropertyAll(c.textPrimary),
          overlayColor: WidgetStatePropertyAll(s.surfacePressed),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: s.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: menuShape,
        textStyle: text.bodyMedium,
        labelTextStyle: WidgetStatePropertyAll(text.bodyMedium),
        iconColor: c.textPrimary,
        iconSize: sp.icon,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: s.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        scrimColor: c.scrim,
        elevation: 0,
        shape: const RoundedRectangleBorder(),
        endShape: const RoundedRectangleBorder(),
      ),
      // Sheets paint their own surface (`AppSheet`).
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        constraints: BoxConstraints(maxWidth: sp.sheetMaxWidth),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: [t],
    );
  }
}

/// The one destructive button style: a `dangerSoft` fill under a `danger`
/// label. `FilledButton(style: context.destructiveButtonStyle, ...)`.
extension DestructiveButtonStyle on BuildContext {
  ButtonStyle get destructiveButtonStyle => FilledButton.styleFrom(
    backgroundColor: colors.dangerSoft,
    foregroundColor: colors.danger,
  );
}
