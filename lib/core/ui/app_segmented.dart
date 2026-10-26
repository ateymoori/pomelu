import 'package:flutter/cupertino.dart';

import '../theme/tokens.dart';

/// The iOS segmented control: a sliding thumb over a track, for switching
/// views or picking one of a few values.
class AppSegmented<T extends Object> extends StatelessWidget {
  const AppSegmented({
    required this.segments,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// Value to label, in order.
  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final surfaces = context.surfaces;
    final spacing = context.spacing;
    return CupertinoSlidingSegmentedControl<T>(
      groupValue: selected,
      backgroundColor: colors.track,
      thumbColor: surfaces.groupedCell,
      padding: EdgeInsets.all(spacing.xxs),
      onValueChanged: (value) {
        if (value != null) onChanged(value);
      },
      children: {
        for (final MapEntry(:key, :value) in segments.entries)
          key: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs,
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textPrimary),
            ),
          ),
      },
    );
  }
}
