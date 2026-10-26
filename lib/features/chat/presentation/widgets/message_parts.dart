import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/transcript_item.dart';

/// `Today`, `Yesterday`, a date, or a date with its year when it is not
/// this year's.
String _dayLabel(BuildContext context, DateTime time) {
  final today = dayOf(DateTime.now());
  final day = dayOf(time);
  final delta = Format.calendarDays(day, today);
  if (delta == 0) return context.l10n.timeToday;
  if (delta == 1) return context.l10n.timeYesterday;
  final material = MaterialLocalizations.of(context);
  return day.year == today.year
      ? material.formatMediumDate(day)
      : material.formatFullDate(day);
}

/// The quiet clock under a turn, absolute (a relative one would need a
/// timer that rebuilds the transcript). It adds no horizontal inset: it sits
/// on the leading edge of an assistant turn, the trailing edge of a user
/// bubble, and prints its digits left to right in any language.
class MessageTimestamp extends StatelessWidget {
  const MessageTimestamp.leading({required this.time, super.key})
    : alignment = AlignmentDirectional.centerStart;

  const MessageTimestamp.trailing({required this.time, super.key})
    : alignment = AlignmentDirectional.centerEnd;

  final DateTime? time;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final time = this.time;
    if (time == null) return const SizedBox.shrink();
    final label = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(time.toLocal()),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return Padding(
      padding: EdgeInsets.only(top: context.spacing.xxs),
      child: Align(
        alignment: alignment,
        child: Text(
          label,
          textDirection: TextDirection.ltr,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.colors.textTertiary,
            fontSize: context.textScale.caption2,
            fontFeatures: context.textScale.tabularFigures,
          ),
        ),
      ),
    );
  }
}

/// A break in the transcript: a day, or "New conversation". A hairline on
/// either side of a centred label that wraps past most of the row.
class TranscriptSeparator extends StatelessWidget {
  const TranscriptSeparator({required this.label, super.key});

  TranscriptSeparator.day(BuildContext context, DateTime day, {super.key})
    : label = _dayLabel(context, day);

  final String label;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final surfaces = context.surfaces;
    final line = Expanded(
      child: Divider(
        height: surfaces.borderWidth,
        thickness: surfaces.borderWidth,
        color: surfaces.outline,
      ),
    );
    return Semantics(
      header: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.md),
        child: LayoutBuilder(
          builder: (context, box) => Row(
            children: [
              line,
              // Not a Flexible: beside two Expanded it would get a third.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: box.maxWidth * spacing.separatorLabelFraction,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.md),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: context.colors.textTertiary,
                      fontSize: context.textScale.caption,
                    ),
                  ),
                ),
              ),
              line,
            ],
          ),
        ),
      ),
    );
  }
}

/// The blinking bar at the end of a streaming reply; steady under reduced
/// motion.
class StreamCaret extends StatelessWidget {
  const StreamCaret({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Padding(
      padding: EdgeInsets.only(top: context.spacing.xxs),
      child: PulseFade(
        min: 0,
        period: context.motion.streamCaretPeriod,
        child: SizedBox(
          width: context.surfaces.borderWidth * 2,
          // One line of body text at the reader's text size.
          height: MediaQuery.textScalerOf(context)
              .scale(context.textScale.body),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.accent,
              borderRadius: BorderRadius.circular(context.radii.xs),
            ),
          ),
        ),
      ),
    ),
  );
}
