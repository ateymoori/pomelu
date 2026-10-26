import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'app_glass.dart';

/// The soft edge under a bar of floating glass buttons (iOS 26+): the page
/// colour behind [child], solid down to the last `spacing.scrollEdgeFade`
/// and fading out there, so content scrolls away beneath the buttons
/// instead of under a slab, and never shows through the bar's own text.
/// Solid when glass is off.
class ScrollEdge extends StatelessWidget {
  const ScrollEdge({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final page =
        Scaffold.maybeOf(context)?.widget.backgroundColor ??
        Theme.of(context).scaffoldBackgroundColor;
    final solid =
        MediaQuery.highContrastOf(context) || GlassScope.solidOf(context);
    if (solid) {
      return DecoratedBox(
        decoration: BoxDecoration(color: page),
        child: child,
      );
    }
    return CustomPaint(
      painter: _EdgePainter(page, context.spacing.scrollEdgeFade),
      child: child,
    );
  }
}

class _EdgePainter extends CustomPainter {
  const _EdgePainter(this.page, this.fade);

  final Color page;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    final band = fade.clamp(0, size.height).toDouble();
    final top = size.height - band;
    canvas.drawRect(Offset.zero & Size(size.width, top), Paint()..color = page);
    final edge = Rect.fromLTWH(0, top, size.width, band);
    canvas.drawRect(
      edge,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [page, page.withValues(alpha: 0)],
        ).createShader(edge),
    );
  }

  @override
  bool shouldRepaint(_EdgePainter old) => old.page != page || old.fade != fade;
}
