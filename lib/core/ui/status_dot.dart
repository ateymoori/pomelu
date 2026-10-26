import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'pulse_fade.dart';

/// What a [StatusDot] reports; `busy` pulses.
enum StatusKind { ok, busy, warn, off }

/// Small colored dot, optionally followed by a label.
class StatusDot extends StatelessWidget {
  const StatusDot({required this.kind, super.key, this.label}) : color = null;

  /// A plain dot of [color]: a chart's color key.
  const StatusDot.legend(Color this.color, {super.key})
    : kind = StatusKind.off,
      label = null;

  final StatusKind kind;

  /// Overrides the color of [kind].
  final Color? color;

  /// Text after the dot; also the semantic label.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final dot = PulseFade(
      enabled: kind == StatusKind.busy,
      child: Container(
        width: spacing.sm,
        height: spacing.sm,
        decoration: BoxDecoration(
          color:
              color ??
              switch (kind) {
                StatusKind.ok => colors.success,
                StatusKind.busy => colors.accent,
                StatusKind.warn => colors.warning,
                StatusKind.off => colors.textTertiary,
              },
          shape: BoxShape.circle,
        ),
      ),
    );

    final text = label;
    if (text == null) return ExcludeSemantics(child: dot);

    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: spacing.xs,
        children: [
          dot,
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
