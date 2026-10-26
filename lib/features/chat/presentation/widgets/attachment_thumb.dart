import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/models/local_attachment.dart';

/// Preview of one outgoing [LocalAttachment] that is not a picture (pictures
/// go in a `MediaStrip`): a pill for voice notes and files. Shows a remove
/// affordance when [onRemove] is set.
class AttachmentThumb extends StatelessWidget {
  const AttachmentThumb({
    required this.attachment,
    super.key,
    this.onRemove,
    this.foreground,
    this.background,
  });

  /// The file being previewed.
  final LocalAttachment attachment;

  /// Removes the attachment. Null hides the affordance.
  final VoidCallback? onRemove;

  /// Text and icon color. Defaults to `textSecondary`.
  final Color? foreground;

  /// Pill fill. Defaults to `toolSurface`.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final body = _pill(context);

    if (onRemove == null) return body;
    return Stack(
      children: [
        body,
        RemoveBadge(label: context.l10n.attachRemove, onPressed: onRemove!),
      ],
    );
  }

  Widget _pill(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final fg = foreground ?? colors.textSecondary;
    final label = attachment.isAudio
        ? context.l10n.attachVoiceNote
        : attachment.name;
    final detail = attachment.isAudio
        ? Format.duration(attachment.duration ?? Duration.zero)
        : Format.bytes(context.l10n, attachment.sizeBytes);

    return AppSurface(
      color: background ?? colors.toolSurface,
      border: false,
      borderRadius: BorderRadius.circular(context.radii.sm),
      child: Padding(
        // A removable pill keeps its text clear of the remove mark.
        padding: EdgeInsetsDirectional.only(
          start: spacing.sm,
          top: spacing.sm,
          bottom: spacing.sm,
          end: onRemove == null ? spacing.sm : RemoveBadge.extentOf(context),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FileBadge(
              name: attachment.isAudio ? '' : attachment.name,
              kind: attachment.kind,
            ),
            SizedBox(width: spacing.sm),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: spacing.attachmentLabelMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (Theme.of(context).textTheme.bodySmall ??
                                const TextStyle())
                            .copyWith(color: fg),
                  ),
                  Text(
                    detail,
                    maxLines: 1,
                    style:
                        (Theme.of(context).textTheme.labelSmall ??
                                const TextStyle())
                            .copyWith(color: fg),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
