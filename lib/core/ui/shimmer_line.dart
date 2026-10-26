import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'pulse_fade.dart';

/// A skeleton block that pulses while content loads. Silent to a screen
/// reader: the list that owns it says it is loading.
class ShimmerLine extends StatelessWidget {
  const ShimmerLine({super.key, this.width, this.height, this.borderRadius});

  /// Null fills the width.
  final double? width;

  /// Defaults to `spacing.md`.
  final double? height;

  /// Defaults to `radii.xs`.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: PulseFade(
      min: context.motion.skeletonPulseMin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.track,
          borderRadius: borderRadius ?? BorderRadius.circular(context.radii.xs),
        ),
        child: SizedBox(
          width: width ?? double.infinity,
          height: height ?? context.spacing.md,
        ),
      ),
    ),
  );
}
