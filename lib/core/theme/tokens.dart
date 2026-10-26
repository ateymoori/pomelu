import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

part 'tokens/colors.dart';
part 'tokens/glass.dart';
part 'tokens/radii_motion_text.dart';
part 'tokens/spacing.dart';
part 'tokens/surfaces.dart';

/// Design tokens: solid content surfaces under Liquid Glass controls, one instance per theme, installed as a
/// [ThemeExtension]. Widgets take every visual constant from here.
@immutable
class HermesTokens extends ThemeExtension<HermesTokens> {
  const HermesTokens({
    required this.colors,
    required this.surfaces,
    required this.glass,
    this.radii = const Radii(),
    this.spacing = const Spacing(),
    this.motion = const Motion(),
    this.text = const TextScale(),
  });

  final HermesColors colors;
  final SurfaceSpec surfaces;
  final Radii radii;
  final Spacing spacing;
  final Motion motion;
  final TextScale text;
  final GlassSpec glass;

  static HermesTokens light() => HermesTokens(
    colors: HermesColors.light(),
    surfaces: SurfaceSpec.light(),
    glass: GlassSpec.light(),
  );

  static HermesTokens dark() => HermesTokens(
    colors: HermesColors.dark(),
    surfaces: SurfaceSpec.dark(),
    glass: GlassSpec.dark(),
  );

  /// [light] under Increase Contrast.
  static HermesTokens lightContrast() {
    final base = light();
    final colors = base.colors.increasedContrast(
      accentText: const Color(0xFF004A99),
    );
    return HermesTokens(
      colors: colors,
      surfaces: base.surfaces.increasedContrast(colors.divider),
      glass: base.glass,
    );
  }

  /// [dark] under Increase Contrast.
  static HermesTokens darkContrast() {
    final base = dark();
    final colors = base.colors.increasedContrast(
      accentText: const Color(0xFF8CC4FF),
    );
    return HermesTokens(
      colors: colors,
      surfaces: base.surfaces.increasedContrast(colors.divider),
      glass: base.glass,
    );
  }

  @override
  HermesTokens copyWith({
    HermesColors? colors,
    SurfaceSpec? surfaces,
    GlassSpec? glass,
  }) => HermesTokens(
    colors: colors ?? this.colors,
    surfaces: surfaces ?? this.surfaces,
    glass: glass ?? this.glass,
  );

  @override
  HermesTokens lerp(ThemeExtension<HermesTokens>? other, double t) {
    if (other is! HermesTokens) return this;
    return HermesTokens(
      colors: HermesColors.lerp(colors, other.colors, t),
      surfaces: SurfaceSpec.lerp(surfaces, other.surfaces, t),
      glass: GlassSpec.lerp(glass, other.glass, t),
    );
  }
}

extension HermesTokensContext on BuildContext {
  HermesTokens get tokens => Theme.of(this).extension<HermesTokens>()!;
  HermesColors get colors => tokens.colors;
  SurfaceSpec get surfaces => tokens.surfaces;
  Radii get radii => tokens.radii;
  Spacing get spacing => tokens.spacing;
  Motion get motion => tokens.motion;
  TextScale get textScale => tokens.text;
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);
}
