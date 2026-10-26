import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'app_glass.dart';

/// One action of an [showAppMenu] menu.
class AppMenuItem<T> {
  const AppMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    this.destructive = false,
    this.enabled = true,
    this.hint,
    this.key,
  });

  final T value;

  /// Finds the row in a test.
  final Key? key;
  final String label;

  /// Shown at the end of the row, as iOS menus do.
  final IconData icon;

  /// What it does, in a line under the label.
  final String? hint;

  /// Red: an action that cannot be undone.
  final bool destructive;
  final bool enabled;
}

/// Opens an iOS pull-down menu: a glass panel next to the widget of
/// [context] (the button, or the message held down), or at [at] (a
/// right-click's global point), its rows split by hairlines, under an
/// optional [title]. Answers the picked value, or null when dismissed.
Future<T?> showAppMenu<T>(
  BuildContext context, {
  required List<AppMenuItem<T>> items,
  String? title,
  Offset? at,
}) {
  final box = context.findRenderObject()! as RenderBox;
  final anchor = at != null
      ? Rect.fromLTWH(at.dx, at.dy, 0, 0)
      : box.localToGlobal(Offset.zero) & box.size;
  return Navigator.of(context).push<T>(
    _MenuRoute<T>(
      anchor: anchor,
      items: items,
      title: title,
      label: MaterialLocalizations.of(context).popupMenuLabel,
      motion: context.motion.fast,
    ),
  );
}

class _MenuRoute<T> extends PopupRoute<T> {
  _MenuRoute({
    required this.anchor,
    required this.items,
    required this.title,
    required this.label,
    required this.motion,
  });

  final Rect anchor;
  final List<AppMenuItem<T>> items;
  final String? title;
  final String label;
  final Duration motion;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => label;

  @override
  Duration get transitionDuration => motion;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => _MenuPanel<T>(anchor: anchor, items: items, title: title, label: label);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    if (context.reduceMotion) {
      return FadeTransition(opacity: curved, child: child);
    }
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
        alignment: _growFrom(context, anchor),
        child: child,
      ),
    );
  }
}

/// Where the panel grows from: the corner nearest the anchor.
Alignment _growFrom(BuildContext context, Rect anchor) {
  final screen = MediaQuery.sizeOf(context);
  final right = anchor.center.dx > screen.width / 2;
  final below = anchor.center.dy < screen.height / 2;
  return Alignment(right ? 1 : -1, below ? -1 : 1);
}

class _MenuPanel<T> extends StatelessWidget {
  const _MenuPanel({
    required this.anchor,
    required this.items,
    required this.title,
    required this.label,
  });

  final Rect anchor;
  final List<AppMenuItem<T>> items;
  final String? title;
  final String label;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final surfaces = context.surfaces;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final screen = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final width = spacing.menuWidth.clamp(0, screen.width - 2 * spacing.lg);
    // Lined up with the anchor's nearer edge, on the side with more room;
    // over the middle of the screen when the anchor (a long message) leaves
    // no room on either side.
    final right = anchor.center.dx > screen.width / 2;
    final roomBelow = screen.height - pad.bottom - anchor.bottom - spacing.lg;
    final roomAbove = anchor.top - pad.top - spacing.lg;
    final below = roomBelow >= roomAbove;
    final cramped = (below ? roomBelow : roomAbove) < 4 * spacing.minTouch;
    final double left = right
        ? (anchor.right - width).clamp(
            spacing.lg,
            screen.width - width - spacing.lg,
          )
        : anchor.left.clamp(spacing.lg, screen.width - width - spacing.lg);

    final panel = AppGlass(
      floating: true,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(context.radii.xl),
      ),
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title case final title?)
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  spacing.lg,
                  spacing.sm,
                  spacing.lg,
                  spacing.sm,
                ),
                child: Text(
                  title,
                  style: text.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              ),
            for (final (i, item) in items.indexed) ...[
              if (i > 0 || title != null)
                Divider(
                  height: surfaces.borderWidth,
                  thickness: surfaces.borderWidth,
                  color: surfaces.outline,
                ),
              Builder(
                builder: (context) {
                  final tint = item.destructive
                      ? colors.danger
                      : colors.textPrimary;
                  final color = item.enabled
                      ? tint
                      : tint.withValues(alpha: surfaces.disabledOpacity);
                  return Semantics(
                    button: true,
                    enabled: item.enabled,
                    child: InkWell(
                      key: item.key,
                      onTap: item.enabled
                          ? () => Navigator.of(context).pop(item.value)
                          : null,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: spacing.minTouch,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: spacing.lg,
                            vertical: spacing.sm,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.label,
                                      style: text.bodyLarge?.copyWith(
                                        color: color,
                                      ),
                                    ),
                                    if (item.hint case final hint?)
                                      Text(
                                        hint,
                                        style: text.bodySmall?.copyWith(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(width: spacing.md),
                              ExcludeSemantics(
                                child: Icon(
                                  item.icon,
                                  size: spacing.icon,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );

    return Stack(
      children: [
        if (cramped)
          Positioned(
            left: left,
            width: width.toDouble(),
            top: pad.top + spacing.lg,
            bottom: pad.bottom + spacing.lg,
            child: Center(child: SingleChildScrollView(child: panel)),
          )
        else
          Positioned(
            left: left,
            width: width.toDouble(),
            top: below ? anchor.bottom + spacing.xs : null,
            bottom: below ? null : screen.height - anchor.top + spacing.xs,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: below ? roomBelow : roomAbove,
              ),
              child: SingleChildScrollView(child: panel),
            ),
          ),
      ],
    );
  }
}
