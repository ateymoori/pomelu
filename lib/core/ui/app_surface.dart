import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The base card of content (cards, rows, bubbles): a solid fill and an
/// optional hairline on a rounded rectangle, no shadow. Controls that float
/// above content are `AppGlass`. Never build a card inline.
class AppSurface extends StatelessWidget {
  const AppSurface({
    required this.child,
    super.key,
    this.borderRadius,
    this.padding,
    this.border = true,
    this.borderColor,
    this.color,
    this.clip = false,
  });

  final Widget child;

  /// Defaults to `radii.md`.
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool border;

  /// Defaults to the hairline; a control's edge passes `inputOutline`.
  final Color? borderColor;
  final Color? color;

  /// Clips [child] to the corners. Off by default: a clip costs a layer, and
  /// only a full-bleed image, a scroller or edge ink needs it.
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final radius = borderRadius ?? BorderRadius.circular(context.radii.md);
    final inset = padding;
    final content = inset == null
        ? child
        : Padding(padding: inset, child: child);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? surfaces.surface,
        borderRadius: radius,
        border: border
            ? Border.all(
                color: borderColor ?? surfaces.outline,
                width: surfaces.borderWidth,
              )
            : null,
      ),
      child: clip ? ClipRRect(borderRadius: radius, child: content) : content,
    );
  }
}
