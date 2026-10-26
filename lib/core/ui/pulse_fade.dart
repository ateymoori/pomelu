import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The one idle pulse (skeletons, the busy dot, the stream caret). Holds
/// full opacity when [enabled] is false or motion is reduced.
class PulseFade extends StatefulWidget {
  const PulseFade({
    required this.child,
    super.key,
    this.min,
    this.period,
    this.enabled = true,
  });

  final Widget child;

  /// Dim end of the pulse; defaults to `motion.pulseMin`.
  final double? min;

  /// One fade, out or back; defaults to `motion.slow`.
  final Duration? period;
  final bool enabled;

  @override
  State<PulseFade> createState() => _PulseFadeState();
}

class _PulseFadeState extends State<PulseFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pulse.duration = widget.period ?? context.motion.slow;
    _sync();
  }

  @override
  void didUpdateWidget(PulseFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    _pulse.duration = widget.period ?? context.motion.slow;
    if (oldWidget.enabled != widget.enabled) _sync();
  }

  /// Parked at 0, the tween holds its `begin`: full opacity.
  void _sync() {
    if (widget.enabled && !context.reduceMotion) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _pulse.drive(
      Tween<double>(
        begin: 1,
        end: widget.min ?? context.motion.pulseMin,
      ).chain(CurveTween(curve: context.motion.enter)),
    ),
    child: widget.child,
  );
}
