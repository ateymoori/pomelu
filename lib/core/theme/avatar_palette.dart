import 'package:flutter/painting.dart';

/// Fill of a letter avatar: a muted light color whose hue comes from the
/// name, the same in both themes; the `onAccent` letter keeps 4.5:1 on it.
abstract final class AvatarPalette {
  static const double saturation = 0.38;

  static const double lightness = 0.62;

  static Color fill(double hue) =>
      HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();
}
