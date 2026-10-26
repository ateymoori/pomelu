import 'package:flutter/material.dart';

/// Ink laid over [child] without changing its layout: for a picture or a
/// filled bubble, whose own paint would hide an `InkWell` under it. The ink
/// is focusable and answers Enter, and a right-click with
/// [onSecondaryTapUp].
class TapInk extends StatelessWidget {
  const TapInk({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTapUp,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GestureTapUpCallback? onSecondaryTapUp;

  /// The splash's corners; match the shape under it.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.passthrough,
    children: [
      child,
      Positioned.fill(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            onLongPress: onLongPress,
            onSecondaryTapUp: onSecondaryTapUp,
          ),
        ),
      ),
    ],
  );
}
