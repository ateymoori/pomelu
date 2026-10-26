part of 'app_theme.dart';

/// The themes of the controls (buttons, fields, chips, toggles), and the
/// edges and shapes every other component shares with them.
final class _Controls {
  _Controls(HermesTokens t, this.text)
    : c = t.colors,
      s = t.surfaces,
      sp = t.spacing,
      r = t.radii;

  final TextTheme text;
  final HermesColors c;
  final SurfaceSpec s;
  final Spacing sp;
  final Radii r;

  late final hairline = BorderSide(color: s.outline, width: s.borderWidth);
  late final _controlEdge = BorderSide(
    color: c.inputOutline,
    width: s.borderWidth,
  );
  late final ripple = WidgetStatePropertyAll(c.accentSoft);

  BorderSide _edge(Color color) =>
      BorderSide(color: color, width: s.borderWidth);

  RoundedRectangleBorder rounded(double radius, [BorderSide? side]) =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: side ?? BorderSide.none,
      );

  static bool _picked(Set<WidgetState> states) =>
      states.contains(WidgetState.selected);

  Color? _accentWhenOn(Set<WidgetState> states) =>
      _picked(states) ? c.accent : null;

  // One pill, one touch floor and one label for every button: primary,
  // secondary and ghost differ only in color.
  late final _button = ButtonStyle(
    textStyle: WidgetStatePropertyAll(text.labelLarge),
    padding: WidgetStatePropertyAll(
      EdgeInsetsDirectional.symmetric(horizontal: sp.lg),
    ),
    minimumSize: WidgetStatePropertyAll(Size(0, sp.minTouch)),
    iconSize: WidgetStatePropertyAll(sp.lg),
    shape: WidgetStatePropertyAll(rounded(r.pill)),
    elevation: const WidgetStatePropertyAll(0),
    visualDensity: VisualDensity.standard,
  );

  /// iOS draws a field as a fill: no outline and no focus ring, unless
  /// Increase Contrast asks for edges.
  InputBorder _field(BorderSide side) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(r.md),
    borderSide: s.fieldEdges ? side : BorderSide.none,
  );

  // The picked segment is an accent fill, never a tint.
  SegmentedButtonThemeData get segmentedButton => SegmentedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (st) => _picked(st) ? c.accent : s.surfaceElevated,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (st) => _picked(st) ? c.onAccent : c.textSecondary,
      ),
      overlayColor: ripple,
      textStyle: WidgetStatePropertyAll(text.labelLarge),
      side: WidgetStatePropertyAll(hairline),
      shape: WidgetStatePropertyAll(rounded(r.pill)),
      padding: WidgetStatePropertyAll(
        EdgeInsetsDirectional.symmetric(horizontal: sp.sm),
      ),
      minimumSize: WidgetStatePropertyAll(Size(0, sp.minTouch)),
      visualDensity: VisualDensity.standard,
    ),
  );

  FilledButtonThemeData get filledButton =>
      FilledButtonThemeData(style: _button);

  OutlinedButtonThemeData get outlinedButton => OutlinedButtonThemeData(
    style: _button.copyWith(
      backgroundColor: WidgetStatePropertyAll(s.surface),
      foregroundColor: WidgetStatePropertyAll(c.textPrimary),
      overlayColor: WidgetStatePropertyAll(s.surfacePressed),
      side: WidgetStatePropertyAll(hairline),
    ),
  );

  TextButtonThemeData get textButton => TextButtonThemeData(
    style: _button.copyWith(
      foregroundColor: WidgetStatePropertyAll(c.accentText),
      overlayColor: ripple,
    ),
  );

  IconButtonThemeData get iconButton => IconButtonThemeData(
    style: ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size.square(sp.minTouch)),
      iconSize: WidgetStatePropertyAll(sp.icon),
    ),
  );

  // The edge, not the fill, tells a field from its host.
  InputDecorationThemeData get inputDecoration => InputDecorationThemeData(
    filled: true,
    fillColor: s.fieldFill,
    hintStyle: text.bodyLarge?.copyWith(color: c.textTertiary),
    errorStyle: text.bodySmall?.copyWith(color: c.danger),
    prefixIconColor: c.textTertiary,
    suffixIconColor: c.textTertiary,
    // Padding, not a min height: the composer sizes its field itself.
    contentPadding: EdgeInsetsDirectional.symmetric(
      horizontal: sp.md,
      vertical: sp.md,
    ),
    border: _field(_controlEdge),
    enabledBorder: _field(_controlEdge),
    disabledBorder: _field(hairline),
    focusedBorder: _field(_edge(c.accent)),
    errorBorder: _field(_edge(c.danger)),
    focusedErrorBorder: _field(_edge(c.danger)),
  );

  ChipThemeData get chip => ChipThemeData(
    backgroundColor: s.surface,
    selectedColor: c.accentSoft,
    disabledColor: s.surface,
    side: WidgetStateBorderSide.resolveWith(
      (st) => _picked(st) ? _edge(c.accent) : hairline,
    ),
    shape: rounded(r.pill),
    showCheckmark: false,
    labelStyle: text.labelLarge?.copyWith(
      color: WidgetStateColor.resolveWith(
        (st) => _picked(st) ? c.textPrimary : c.textSecondary,
      ),
    ),
    padding: EdgeInsetsDirectional.symmetric(horizontal: sp.xs),
  );

  SwitchThemeData get switchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (st) => _picked(st) ? c.onAccent : null,
    ),
    trackColor: WidgetStateProperty.resolveWith(_accentWhenOn),
  );

  SliderThemeData get slider => SliderThemeData(
    activeTrackColor: c.accent,
    thumbColor: c.accent,
    inactiveTrackColor: c.track,
    overlayColor: c.accentSoft,
  );

  CheckboxThemeData get checkbox => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(_accentWhenOn),
    checkColor: WidgetStatePropertyAll(c.onAccent),
    overlayColor: ripple,
    side: WidgetStateBorderSide.resolveWith(
      (st) => _picked(st)
          ? _edge(c.accent)
          : _controlEdge.copyWith(width: s.borderWidth * 2),
    ),
    shape: rounded(r.xs),
  );

  RadioThemeData get radio => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (st) => _picked(st) ? c.accent : c.inputOutline,
    ),
    overlayColor: ripple,
  );
}
