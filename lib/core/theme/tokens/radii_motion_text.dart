part of '../tokens.dart';

/// Corner radii.
@immutable
class Radii {
  const Radii();

  final double xs = 6;
  final double sm = 10;
  final double md = 12;
  final double lg = 16;
  final double xl = 20;

  /// The top corners of a sheet: Liquid Glass sheets are rounder than cards.
  final double sheet = 32;
  final double pill = 999;
}

/// Durations, curves and pulse levels.
@immutable
class Motion {
  const Motion();

  final Duration fast = const Duration(milliseconds: 160);
  final Duration normal = const Duration(milliseconds: 240);
  final Duration slow = const Duration(milliseconds: 360);
  final Curve enter = Curves.easeOutCubic;

  /// How long a snack bar stays: Material's own default.
  final Duration snackBar = const Duration(seconds: 4);

  /// Share of its height a centred sheet rises while it fades in.
  final double sheetRise = 0.04;

  /// Dim end of the idle pulse (a busy dot).
  final double pulseMin = 0.5;

  /// Dim end of a skeleton's pulse; dimmer, as the block is large.
  final double skeletonPulseMin = 0.4;

  /// Share of the ring a spinner draws while motion is reduced.
  final double spinnerStillSweep = 0.75;

  /// Dimmest a full-screen viewer fades while dragged to close.
  final double viewerDragMinOpacity = 0.4;

  /// One blink of the caret at the end of a streaming reply.
  final Duration streamCaretPeriod = const Duration(milliseconds: 900);
}

/// Type ladder (dp), after Apple's Dynamic Type.
@immutable
class TextScale {
  const TextScale();

  final double largeTitle = 34;
  final double title1 = 28;
  final double title2 = 22;
  final double title3 = 20;
  final double headline = 17;
  final double body = 17;
  final double callout = 16;
  final double subheadline = 15;
  final double footnote = 13;
  final double caption = 12;
  final double caption2 = 11;
  final double code = 13.5;
  final double lineHeight = 1.35;

  /// Letter spacing from `title2` up.
  final double titleTracking = -0.4;

  /// Taller leading for long replies.
  final double bodyLineHeight = 1.55;
  final String uiFamily = 'Inter';
  final String monoFamily = 'JetBrainsMono';

  /// Figures of one width, for numbers that change in place (a percentage,
  /// a time, a coordinate).
  final List<FontFeature> tabularFigures = const [FontFeature.tabularFigures()];

  /// Blank line between two Markdown blocks, in body font sizes.
  final double blockGapScale = 1.15;

  /// The one monospace style; [size] defaults to `footnote`.
  TextStyle mono({double? size, double? height, Color? color}) => TextStyle(
    fontFamily: monoFamily,
    fontSize: size ?? footnote,
    height: height,
    color: color,
  );
}
