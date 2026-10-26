import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/l10n_ext.dart';

/// A take in progress: its length, whether the finger slid far enough
/// toward the start to drop it, and whether it was started by the tap action (it then ends
/// with another tap, not a lifted finger).
typedef RecordingProgress = ({Duration elapsed, bool cancelling, bool byTap});

/// Replaces the text field while a voice note is being recorded: elapsed
/// time, the slide-to-cancel hint (which turns into "Release to cancel" once
/// the finger is far enough), and a record dot that dims when cancelling.
class RecordingHint extends StatelessWidget {
  const RecordingHint({required this.progress, super.key});

  /// Live state from the mic button.
  final RecordingProgress progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.circle_fill,
            size: spacing.md,
            color: progress.cancelling ? colors.textTertiary : colors.danger,
          ),
          SizedBox(width: spacing.sm),
          Text(
            Format.duration(progress.elapsed),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            // A live region: sliding into the cancel zone changes the line to
            // "Release to cancel", and that is announced.
            child: Semantics(
              liveRegion: true,
              child: Text(
                progress.cancelling
                    ? context.l10n.chatRecordingCancel
                    : progress.byTap
                    ? context.l10n.chatRecordingTap
                    : context.l10n.chatRecording,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
