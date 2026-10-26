part of '../tokens.dart';

/// The fill the tool rows and the reasoning block share, per theme.
const Color _lightQuiet = Color(0xFFE9E9EE);
const Color _darkQuiet = Color(0xFF2C2C2E);

/// Semantic colors. Contrast rules are checked in
/// `test/core/theme/contrast_test.dart`.
@immutable
class HermesColors {
  const HermesColors({
    required this.accent,
    required this.accentText,
    required this.inverseAccent,
    required this.accentSoft,
    required this.onAccent,
    required this.backdropMid,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
    required this.inputOutline,
    required this.track,
    required this.success,
    required this.warning,
    required this.danger,
    required this.onDanger,
    required this.dangerSoft,
    required this.userBubble,
    required this.onUserBubble,
    required this.codeBackground,
    required this.codeText,
    required this.toolSurface,
    required this.reasoningSurface,
    required this.tableStripe,
    required this.scrim,
    required this.chart,
    this.onScrim = const Color(0xFFFFFFFF),
    this.scrimSolid = const Color(0xFF0E1220),
    this.files = const FileColors(),
  });

  /// Brand fill: primary buttons, the selected mark, indicators.
  final Color accent;

  /// The accent as text: 4.5:1 on every surface and on [accentSoft].
  final Color accentText;

  /// The accent as text on the inverse surface (the snack bar).
  final Color inverseAccent;
  final Color accentSoft;

  /// Text and glyphs on an [accent] fill.
  final Color onAccent;
  final Color backdropMid;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color divider;

  /// Edge of an interactive control, 3:1 (WCAG 1.4.11). Cards keep the
  /// quieter [SurfaceSpec.outline].
  final Color inputOutline;

  /// Idle fill of a progress track, a skeleton and a drag handle.
  final Color track;
  final Color success;
  final Color warning;
  final Color danger;
  final Color onDanger;

  /// Tint behind a destructive label; [danger] keeps 4.5:1 on it.
  final Color dangerSoft;
  final Color userBubble;
  final Color onUserBubble;
  final Color codeBackground;
  final Color codeText;
  final Color toolSurface;
  final Color reasoningSurface;

  /// Every other body row of a Markdown table: a step lighter than
  /// [toolSurface], the header's fill.
  final Color tableStripe;
  final Color scrim;

  /// Text and glyphs on [scrim] or on a picture: light in both themes.
  final Color onScrim;

  /// Series colors of a breakdown bar, in order; cycle when there are more.
  final List<Color> chart;

  /// Solid dark fill for a badge on a picture, where [scrim] would show
  /// the picture through.
  final Color scrimSolid;

  /// Fills of the file type badges.
  final FileColors files;

  factory HermesColors.light() => const HermesColors(
    accent: Color(0xFF0A84FF),
    accentText: Color(0xFF005FC2),
    inverseAccent: Color(0xFF59ABFF),
    accentSoft: Color(0x260A84FF),
    onAccent: Color(0xFF0B0F1E),
    backdropMid: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0E1220),
    textSecondary: Color(0xB30E1220),
    textTertiary: Color(0xA40E1220),
    divider: Color(0x1A0E1220),
    inputOutline: Color(0xFF84848A),
    track: Color(0xFFD1D1D6),
    success: Color(0xFF1D744A),
    warning: Color(0xFF886210),
    danger: Color(0xFFB91419),
    onDanger: Color(0xFFFFFFFF),
    dangerSoft: Color(0x26B91419),
    userBubble: Color(0xFFF2F2F7),
    onUserBubble: Color(0xFF0E1220),
    codeBackground: Color(0xFFEBEBF0),
    codeText: Color(0xFF1B2030),
    toolSurface: _lightQuiet,
    reasoningSurface: _lightQuiet,
    tableStripe: Color(0xFFF2F2F7),
    scrim: Color(0x660E1220),
    chart: [
      Color(0xFF0A84FF),
      Color(0xFF8E5CF7),
      Color(0xFF0C8B89),
      Color(0xFFC4690C),
      Color(0xFFD63F78),
      Color(0xFF4F5BD5),
      Color(0xFF2E9E4F),
      Color(0xFF9C7400),
    ],
  );

  factory HermesColors.dark() => const HermesColors(
    accent: Color(0xFF0A84FF),
    accentText: Color(0xFF59ABFF),
    inverseAccent: Color(0xFF005FC2),
    accentSoft: Color(0x330A84FF),
    onAccent: Color(0xFF0B0F1E),
    backdropMid: Color(0xFF000000),
    textPrimary: Color(0xFFF2F4FA),
    textSecondary: Color(0xB3F2F4FA),
    textTertiary: Color(0x9CF2F4FA),
    divider: Color(0x1FF2F4FA),
    inputOutline: Color(0xFF7A7A80),
    track: Color(0xFF48484A),
    success: Color(0xFF4CCB8A),
    warning: Color(0xFFF0B84A),
    danger: Color(0xFFFF858A),
    onDanger: Color(0xFF0B0F1E),
    dangerSoft: Color(0x2EFF6B70),
    userBubble: Color(0xFF2C2C2E),
    onUserBubble: Color(0xFFF2F4FA),
    codeBackground: Color(0xFF111114),
    codeText: Color(0xFFE6E9F5),
    toolSurface: _darkQuiet,
    reasoningSurface: _darkQuiet,
    tableStripe: Color(0xFF1C1C1E),
    scrim: Color(0x99000000),
    chart: [
      Color(0xFF3D9BFF),
      Color(0xFFA77BFF),
      Color(0xFF2EC4C0),
      Color(0xFFF59A3C),
      Color(0xFFF0679A),
      Color(0xFF7D88FF),
      Color(0xFF4CCB8A),
      Color(0xFFE6B84A),
    ],
  );

  /// These colors under Increase Contrast (Apple HIG, "Color": every custom
  /// color has an increased-contrast variant): weaker text, hairlines and
  /// control edges move toward [textPrimary]; links get darker (or lighter).
  HermesColors increasedContrast({required Color accentText}) => HermesColors(
    accent: accent,
    accentText: accentText,
    inverseAccent: inverseAccent,
    accentSoft: accentSoft,
    onAccent: onAccent,
    backdropMid: backdropMid,
    textPrimary: textPrimary,
    textSecondary: textPrimary.withValues(alpha: 0.9),
    textTertiary: textPrimary.withValues(alpha: 0.8),
    divider: textPrimary.withValues(alpha: 0.55),
    inputOutline: textPrimary.withValues(alpha: 0.75),
    track: track,
    success: success,
    warning: warning,
    danger: danger,
    onDanger: onDanger,
    dangerSoft: dangerSoft,
    userBubble: userBubble,
    onUserBubble: onUserBubble,
    codeBackground: codeBackground,
    codeText: codeText,
    toolSurface: toolSurface,
    reasoningSurface: reasoningSurface,
    tableStripe: tableStripe,
    scrim: scrim,
    chart: chart,
    onScrim: onScrim,
    scrimSolid: scrimSolid,
  );

  static HermesColors lerp(HermesColors a, HermesColors b, double t) {
    Color c(Color Function(HermesColors) pick) =>
        Color.lerp(pick(a), pick(b), t)!;
    return HermesColors(
      accent: c((x) => x.accent),
      accentText: c((x) => x.accentText),
      inverseAccent: c((x) => x.inverseAccent),
      accentSoft: c((x) => x.accentSoft),
      onAccent: c((x) => x.onAccent),
      backdropMid: c((x) => x.backdropMid),
      textPrimary: c((x) => x.textPrimary),
      textSecondary: c((x) => x.textSecondary),
      textTertiary: c((x) => x.textTertiary),
      divider: c((x) => x.divider),
      inputOutline: c((x) => x.inputOutline),
      track: c((x) => x.track),
      success: c((x) => x.success),
      warning: c((x) => x.warning),
      danger: c((x) => x.danger),
      onDanger: c((x) => x.onDanger),
      dangerSoft: c((x) => x.dangerSoft),
      userBubble: c((x) => x.userBubble),
      onUserBubble: c((x) => x.onUserBubble),
      codeBackground: c((x) => x.codeBackground),
      codeText: c((x) => x.codeText),
      toolSurface: c((x) => x.toolSurface),
      reasoningSurface: c((x) => x.reasoningSurface),
      tableStripe: c((x) => x.tableStripe),
      scrim: c((x) => x.scrim),
      chart: [
        for (var i = 0; i < a.chart.length && i < b.chart.length; i++)
          Color.lerp(a.chart[i], b.chart[i], t)!,
      ],
    );
  }
}

/// Fills of the file type badges: the colors people know the types by
/// (PDF red, Word blue, Excel green), the same in both themes. [label]
/// keeps 4.5:1 on each.
@immutable
class FileColors {
  const FileColors();

  final Color label = const Color(0xFFFFFFFF);
  final Color pdf = const Color(0xFFD93025);
  final Color document = const Color(0xFF2B579A);
  final Color sheet = const Color(0xFF1E7145);
  final Color slides = const Color(0xFFC43E1C);
  final Color archive = const Color(0xFF8D6E2F);
  final Color code = const Color(0xFF7048C8);
  final Color text = const Color(0xFF5E6B7C);
  final Color image = const Color(0xFF0B7A86);
  final Color video = const Color(0xFFB3306E);
  final Color audio = const Color(0xFFC2185B);
  final Color other = const Color(0xFF6B6B73);
}
