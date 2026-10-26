import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/models/local_attachment.dart';
import '../../../connection/presentation/connection_providers.dart';
import '../../domain/chat_message.dart';
import '../../domain/chat_target.dart';
import 'attachment_thumb.dart';
import 'media_strip.dart';
import 'message_actions.dart';
import 'message_parts.dart';

/// One outgoing turn: a right-aligned quiet bubble with its attachments and
/// delivery state, closed by a quiet clock on the bubble's own side.
class UserMessage extends ConsumerWidget {
  const UserMessage({
    required this.message,
    required this.target,
    super.key,
    this.onRetry,
  });

  /// The row to render. Always `ChatRole.user`.
  final ChatMessage message;

  /// The chat the turn belongs to, for its long-press actions.
  final ChatTarget target;

  /// Re-sends a failed message. Null disables the retry affordance.
  final VoidCallback? onRetry;

  bool get _failed => message.delivery == DeliveryState.failed;
  bool get _sending => message.delivery == DeliveryState.sending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final spacing = context.spacing;
    final pending = context.surfaces.pendingOpacity;
    final theme = Theme.of(context).textTheme;
    final api = ref.watch(hermesApiProvider);
    final pictures = [
      for (final a in message.attachments) ?MediaItem.fromLocal(a),
      for (final m in message.media) ?MediaItem.fromRef(m, api),
    ];
    final files = message.attachments.where((a) => !a.isImage).toList();

    final hasBubble =
        message.text.trim().isNotEmpty || files.isNotEmpty || _sending;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.turnGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Pictures sit above the bubble on the bare backdrop.
          if (pictures.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: hasBubble ? spacing.sm : 0),
              child: Opacity(
                opacity: _sending ? pending : 1,
                child: MediaStrip(items: pictures, alignEnd: true),
              ),
            ),
          if (hasBubble) _BubbleCap(child: _bubble(context, ref, files)),
          // The clock closes the turn on the bubble's own side. Hidden while
          // the message is still in flight or has failed: the delivery state
          // is what matters then, and a send time that may never hold would
          // only mislead.
          if (!_failed && !_sending)
            // No horizontal inset: the clock must land exactly on the
            // bubble's trailing edge, not 8dp inside it.
            MessageTimestamp.trailing(time: message.timestamp),
          if (_failed)
            Padding(
              // Directional, and flush with the bubble edge for the same
              // reason the clock is.
              padding: EdgeInsetsDirectional.only(top: spacing.xxs),
              child: TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: colors.danger,
                  overlayColor: colors.dangerSoft,
                  // The label sits on the bubble's trailing edge; the button
                  // still keeps the full touch target around it.
                  padding: EdgeInsets.zero,
                  minimumSize: Size.square(spacing.minTouch),
                  alignment: AlignmentDirectional.centerEnd,
                ),
                child: Text(
                  context.l10n.chatFailedToSend,
                  style: theme.labelLarge?.copyWith(color: colors.danger),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bubble(
    BuildContext context,
    WidgetRef ref,
    List<LocalAttachment> files,
  ) {
    final colors = context.colors;
    final spacing = context.spacing;
    final theme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(context.radii.xl);
    void actions({Offset? at}) =>
        showMessageActions(context, ref, target, message, pointer: at);

    return MergeSemantics(
      child: Semantics(
        customSemanticsActions: {
          CustomSemanticsAction(label: context.l10n.chatMessageActionsLabel):
              actions,
        },
        child: Opacity(
          opacity: _sending ? context.surfaces.pendingOpacity : 1,
          child: AppSurface(
            color: colors.userBubble,
            border: false,
            borderRadius: radius,
            child: TapInk(
              borderRadius: radius,
              onTap: _failed ? onRetry : null,
              onLongPress: actions,
              onSecondaryTapUp: (d) => actions(at: d.globalPosition),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: spacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (files.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: spacing.sm),
                        child: Wrap(
                          spacing: spacing.sm,
                          runSpacing: spacing.sm,
                          alignment: WrapAlignment.end,
                          children: [
                            for (final a in files)
                              AttachmentThumb(
                                key: ValueKey(a.id),
                                attachment: a,
                                foreground: colors.onUserBubble,
                                background: context.surfaces.surfacePressed,
                              ),
                          ],
                        ),
                      ),
                    // Plain text, not SelectableText: a selectable span wins
                    // the gesture arena and would swallow the bubble's
                    // long-press menu and the retry tap. Copy and share live
                    // in the long-press sheet.
                    if (message.text.trim().isNotEmpty)
                      withTextDirection(
                        text: message.text,
                        child: Text(
                          message.text,
                          style: (theme.bodyLarge ?? const TextStyle())
                              .copyWith(color: colors.onUserBubble),
                        ),
                      ),
                    if (_sending)
                      Padding(
                        padding: EdgeInsets.only(top: spacing.xs),
                        // The still ring under reduced motion, a spinner
                        // otherwise, and a name either way.
                        child: Semantics(
                          label: context.l10n.chatSending,
                          child: AppSpinner(size: spacing.md),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BubbleCap extends StatelessWidget {
  const _BubbleCap({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: constraints.maxWidth.isFinite
            ? constraints.maxWidth * Spacing.bubbleWidthFactor
            : context.spacing.bubbleMaxWidth,
      ),
      child: child,
    ),
  );
}
