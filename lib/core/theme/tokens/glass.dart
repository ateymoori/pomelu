part of '../tokens.dart';

/// Liquid Glass: the material of the controls and bars that float above
/// content (bars, the composer, sheets, menus, floating buttons). Content
/// itself (bubbles, cards, rows) stays on solid surfaces.
///
/// Follows iOS 27: a frosted fill that keeps text readable over any content,
/// a darker edge with a bright specular rim, and a solid fallback when the
/// system asks for more contrast.
@immutable
class GlassSpec {
  const GlassSpec({
    required this.fill,
    required this.solidFill,
    required this.rimLight,
    required this.rimDark,
    required this.shadow,
    this.blur = 24,
    this.saturation = 1.8,
    this.rimWidth = 1,
  });

  /// Tint laid over the blurred backdrop.
  final Color fill;

  /// The fill when glass is off (Increase Contrast).
  final Color solidFill;

  /// Specular highlight at the top of the rim.
  final Color rimLight;

  /// The darker edge at the bottom of the rim.
  final Color rimDark;

  /// Soft shadow under floating glass (buttons, the composer, sheets).
  final List<BoxShadow> shadow;

  /// Blur sigma of the backdrop.
  final double blur;

  /// Saturation boost of the backdrop, so colors behind glass stay alive.
  final double saturation;

  /// Width of the rim stroke.
  final double rimWidth;

  /// Saturate, then blur: what the backdrop goes through.
  ImageFilter get filter => ImageFilter.compose(
    outer: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
    inner: ColorFilter.matrix(_saturate(saturation)),
  );

  factory GlassSpec.light() => const GlassSpec(
    fill: Color(0xB8FFFFFF),
    solidFill: Color(0xFFFFFFFF),
    rimLight: Color(0xE6FFFFFF),
    rimDark: Color(0x1F000000),
    shadow: [
      BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
    ],
  );

  factory GlassSpec.dark() => const GlassSpec(
    fill: Color(0xB01C1C1E),
    solidFill: Color(0xFF2C2C2E),
    rimLight: Color(0x40FFFFFF),
    rimDark: Color(0x66000000),
    shadow: [
      BoxShadow(color: Color(0x59000000), blurRadius: 24, offset: Offset(0, 8)),
    ],
  );

  static GlassSpec lerp(GlassSpec a, GlassSpec b, double t) => GlassSpec(
    fill: Color.lerp(a.fill, b.fill, t)!,
    solidFill: Color.lerp(a.solidFill, b.solidFill, t)!,
    rimLight: Color.lerp(a.rimLight, b.rimLight, t)!,
    rimDark: Color.lerp(a.rimDark, b.rimDark, t)!,
    shadow: BoxShadow.lerpList(a.shadow, b.shadow, t) ?? a.shadow,
    blur: lerpDouble(a.blur, b.blur, t)!,
    saturation: lerpDouble(a.saturation, b.saturation, t)!,
    rimWidth: lerpDouble(a.rimWidth, b.rimWidth, t)!,
  );

  /// By value, so a rim repaints only when the glass changes.
  @override
  bool operator ==(Object other) =>
      other is GlassSpec &&
      other.fill == fill &&
      other.solidFill == solidFill &&
      other.rimLight == rimLight &&
      other.rimDark == rimDark &&
      listEquals(other.shadow, shadow) &&
      other.blur == blur &&
      other.saturation == saturation &&
      other.rimWidth == rimWidth;

  @override
  int get hashCode => Object.hash(
    fill,
    solidFill,
    rimLight,
    rimDark,
    Object.hashAll(shadow),
    blur,
    saturation,
    rimWidth,
  );

  /// The standard luminance-preserving saturation matrix.
  static List<double> _saturate(double s) {
    const r = 0.2126;
    const g = 0.7152;
    const b = 0.0722;
    final i = 1 - s;
    return [
      r * i + s, g * i, b * i, 0, 0, //
      r * i, g * i + s, b * i, 0, 0, //
      r * i, g * i, b * i + s, 0, 0, //
      0, 0, 0, 1, 0, //
    ];
  }
}
