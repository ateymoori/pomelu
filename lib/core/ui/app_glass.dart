import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Liquid Glass (`tokens.glass`): a blurred, tinted pane with a specular rim,
/// for everything that floats above content: bars, the composer, sheets,
/// menus and floating buttons. Content (bubbles, cards, rows) uses
/// `AppSurface` instead.
///
/// A pane with a rim is a [Material] canvas too, so ink (a `ListTile`, an
/// `InkWell`) shows on it. With Increase Contrast or Reduce Transparency
/// ([GlassScope]) on, the pane is solid. Controls on a pane, a bar too, draw
/// no glass of their own: one glass layer, never glass on glass.
class AppGlass extends StatelessWidget {
  const AppGlass({
    required this.child,
    super.key,
    this.shape,
    this.padding,
    this.floating = false,
  }) : rim = true;

  /// A capsule: buttons, the composer, chips.
  const AppGlass.capsule({
    required this.child,
    super.key,
    this.padding,
    this.floating = true,
  }) : shape = const StadiumBorder(),
       rim = true;

  /// A full-width bar (the map's spot bar): square, no rim, no
  /// shadow; its lower edge is the content scrolling under it.
  const AppGlass.bar({required this.child, super.key, this.padding})
    : shape = const RoundedRectangleBorder(),
      floating = false,
      rim = false;

  /// The pane's outline. Defaults to a continuous-corner rectangle of
  /// `radii.lg`.
  final OutlinedBorder? shape;

  /// Inset applied to [child] only.
  final EdgeInsetsGeometry? padding;

  /// Casts the soft glass shadow: the pane floats (a button, the composer,
  /// a sheet) rather than sitting at an edge.
  final bool floating;

  /// Strokes the specular rim; every pane but a bar.
  final bool rim;

  final Widget child;

  /// Whether [context] sits on a glass pane: a control there (a button in
  /// the composer, on a sheet) draws no glass of its own.
  static bool isOn(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_OnGlass>() != null;

  @override
  Widget build(BuildContext context) {
    final glass = context.tokens.glass;
    final outline =
        shape ??
        RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(context.radii.lg),
        );
    final solid =
        MediaQuery.highContrastOf(context) || GlassScope.solidOf(context);
    final inset = padding;
    Widget content = _OnGlass(child: rim ? _InkCanvas(child: child) : child);
    if (inset != null) content = Padding(padding: inset, child: content);
    Widget pane = DecoratedBox(
      decoration: ShapeDecoration(
        color: solid ? glass.solidFill : glass.fill,
        shape: outline,
      ),
      child: content,
    );
    if (rim) {
      pane = CustomPaint(
        foregroundPainter: _RimPainter(outline, glass),
        child: pane,
      );
    }
    if (!solid) {
      pane = ClipPath(
        clipper: ShapeBorderClipper(
          shape: outline,
          textDirection: Directionality.maybeOf(context),
        ),
        child: BackdropFilter(filter: glass.filter, child: pane),
      );
    }
    if (!floating) return pane;
    return DecoratedBox(
      decoration: ShapeDecoration(shape: outline, shadows: glass.shadow),
      child: pane,
    );
  }
}

/// The rim: bright at the top where light hits, darker at the bottom.
class _RimPainter extends CustomPainter {
  _RimPainter(this.shape, this.glass);

  final ShapeBorder shape;
  final GlassSpec glass;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = glass.rimWidth / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = glass.rimWidth
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [glass.rimLight, glass.rimDark],
      ).createShader(rect);
    canvas.drawPath(shape.getOuterPath(rect.deflate(inset)), paint);
  }

  @override
  bool shouldRepaint(_RimPainter old) =>
      old.shape != shape || old.glass != glass;
}

/// Marks the content of a glass pane (see [AppGlass.isOn]).
class _OnGlass extends InheritedWidget {
  const _OnGlass({required super.child});

  @override
  bool updateShouldNotify(_OnGlass oldWidget) => false;
}

/// A clear [Material] for the ink of the pane's rows. It keeps the text style
/// the pane inherited: a `Material` would reset it to `bodyMedium`.
class _InkCanvas extends StatelessWidget {
  const _InkCanvas({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = DefaultTextStyle.of(context);
    return Material(
      type: MaterialType.transparency,
      child: DefaultTextStyle(
        style: text.style,
        textAlign: text.textAlign,
        softWrap: text.softWrap,
        overflow: text.overflow,
        maxLines: text.maxLines,
        textWidthBasis: text.textWidthBasis,
        textHeightBehavior: text.textHeightBehavior,
        child: child,
      ),
    );
  }
}

/// Whether glass may be translucent below this point: iOS's Reduce
/// Transparency, which Flutter does not expose, comes in through it
/// (`AppChrome`). Increase Contrast is read from [MediaQuery] directly.
class GlassScope extends InheritedWidget {
  const GlassScope({required this.solid, required super.child, super.key});

  /// Every pane is solid.
  final bool solid;

  static bool solidOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GlassScope>()?.solid ?? false;

  @override
  bool updateShouldNotify(GlassScope oldWidget) => solid != oldWidget.solid;
}
