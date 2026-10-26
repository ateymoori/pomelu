import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'app_glass.dart';
import 'app_spinner.dart';

/// Round icon action of the minimum touch size. [tooltip] is also the
/// semantic label. The face is a glyph ([icon]) or any widget ([child]);
/// while [busy] it is a spinner.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.tooltip,
    super.key,
    this.icon,
    this.child,
    this.onPressed,
    this.badge = false,
    this.filled = false,
    this.busy = false,
    this.disc = false,
  }) : assert((icon == null) != (child == null), 'Give an icon or a child.'),
       plain = false,
       color = null,
       iconSize = null;

  /// A bare glyph in the ambient icon color, or [color]: an action inside
  /// content (a row's run and delete, a code block's copy, a field's reveal),
  /// where a glass disc would be noise.
  const AppIconButton.plain({
    required IconData this.icon,
    required this.tooltip,
    super.key,
    this.onPressed,
    this.busy = false,
    this.color,
    this.iconSize,
  }) : plain = true,
       disc = false,
       child = null,
       badge = false,
       filled = false;

  final IconData? icon;
  final Widget? child;
  final String tooltip;

  /// Null disables and dims the button.
  final VoidCallback? onPressed;

  /// An accent dot at the top-end corner.
  final bool badge;

  /// An accent fill instead of the surface.
  final bool filled;

  /// A spinner in place of the face, announced as [tooltip].
  final bool busy;

  /// No glass disc, no fill ([AppIconButton.plain]).
  final bool plain;

  /// Keeps the glass disc on a glass pane: a sheet's own bar buttons
  /// (✕, ✓) float as circles there, as on iOS.
  final bool disc;

  /// The glyph's color on a plain button (`danger` for a delete).
  final Color? color;

  /// Defaults to the theme's icon size.
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final surfaces = context.surfaces;
    final spacing = context.spacing;
    // The label rides on the face, which `IconButton` merges into its own
    // node; the tooltip stays silent, so the label is read once.
    final face = child;
    final Widget glyph = busy
        ? AppSpinner.icon(semanticsLabel: tooltip)
        : face == null
        ? Icon(icon, semanticLabel: tooltip)
        : Semantics(label: tooltip, excludeSemantics: true, child: face);
    final size = iconSize ?? Theme.of(context).iconTheme.size ?? spacing.icon;
    final ButtonStyle style;
    if (plain) {
      final tint = color;
      style = IconButton.styleFrom(
        foregroundColor: tint,
        disabledForegroundColor: tint?.withValues(
          alpha: surfaces.disabledOpacity,
        ),
        padding: EdgeInsets.zero,
        fixedSize: Size.square(spacing.minTouch),
        iconSize: size,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    } else {
      // A plain button is a glass disc; a filled one is the accent.
      final background = filled ? colors.accent : Colors.transparent;
      final foreground = filled ? colors.onAccent : colors.textPrimary;
      style = IconButton.styleFrom(
        // Disabled keeps the colors: the Opacity below does the dimming.
        backgroundColor: background,
        disabledBackgroundColor: background,
        foregroundColor: foreground,
        disabledForegroundColor: foreground,
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
        fixedSize: Size.square(spacing.minTouch),
        iconSize: size,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }
    Widget button = IconButton(onPressed: onPressed, icon: glyph, style: style);
    if (plain) {
      return Tooltip(
        message: tooltip,
        excludeFromSemantics: true,
        child: button,
      );
    }
    // On a glass pane (the composer) the pane is the glass: a bare glyph.
    if (!filled && (disc || !AppGlass.isOn(context))) {
      button = AppGlass(shape: const CircleBorder(), child: button);
    }
    return Tooltip(
      message: tooltip,
      excludeFromSemantics: true,
      child: Opacity(
        opacity: onPressed == null ? surfaces.disabledOpacity : 1,
        child: badge
            ? Badge(
                backgroundColor: colors.accent,
                smallSize: spacing.sm,
                child: button,
              )
            : button,
      ),
    );
  }
}
