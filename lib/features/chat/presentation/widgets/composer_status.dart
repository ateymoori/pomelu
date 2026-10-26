import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/chat_state.dart';

/// The line under the composer's row: an upload's progress, a voice note
/// being transcribed, failed or queued turns, or offline. Nothing when all
/// is well.
class ComposerStatus extends StatelessWidget {
  const ComposerStatus({
    required this.online,
    required this.queued,
    required this.failed,
    required this.transcribing,
    super.key,
    this.upload,
  });

  final bool online;
  final int queued;
  final int failed;
  final bool transcribing;
  final UploadProgress? upload;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final spacing = context.spacing;
    final upload = this.upload;
    final (String label, Color? color) = switch (upload) {
      final up? => (l10n.chatUploadProgress(up.name, up.done, up.total), null),
      _ when transcribing => (l10n.chatTranscribing, null),
      _ when failed > 0 => (l10n.chatFailedNotice(failed), colors.danger),
      _ when !online && queued > 0 => (
        l10n.chatQueuedNotice(queued),
        colors.textSecondary,
      ),
      _ when !online => (l10n.chatOfflineNotice, colors.textSecondary),
      _ => ('', null),
    };
    if (label.isEmpty) return const SizedBox.shrink();
    // Queued, offline or failed is said, not only painted.
    return Semantics(
      liveRegion: true,
      container: true,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          spacing.sm,
          spacing.xs,
          spacing.sm,
          0,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: color),
              ),
            ),
            if (upload != null && upload.total > 1)
              SizedBox(
                width: spacing.xxl,
                child: LinearProgressIndicator(
                  value: upload.done / upload.total,
                  color: colors.accent,
                  backgroundColor: colors.accentSoft,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
