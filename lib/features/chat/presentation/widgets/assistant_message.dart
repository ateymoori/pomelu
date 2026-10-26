import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/models/local_attachment.dart';
import '../../../connection/presentation/connection_providers.dart';
import '../../domain/chat_message.dart';
import '../../domain/chat_target.dart';
import '../../domain/transcript_item.dart';
import 'markdown_body.dart';
import 'media_attachment.dart';
import 'media_strip.dart';
import 'message_actions.dart';
import 'message_parts.dart';
import 'reasoning_chip.dart';
import 'tool_card.dart';

/// One assistant turn as plain text across the reading column: reasoning
/// and tools, the Markdown, media, and the caret while text arrives.
class AssistantMessage extends ConsumerWidget {
  const AssistantMessage({
    required this.message,
    required this.target,
    super.key,
    this.item,
    this.latest,
  });

  final ChatMessage message;

  /// The chat the row is in; its profile scopes the gateway media URLs.
  final ChatTarget target;

  /// Which piece of a long reply; null for a whole message.
  final TranscriptItem? item;

  /// The message as it is now: an untouched piece is reused, so [message]
  /// may be older, and the actions must not act on that.
  final ChatMessage Function()? latest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final spacing = context.spacing;
    final scale = context.textScale;
    final theme = Theme.of(context).textTheme;
    final first = item?.isFirst ?? true;
    final last = item?.isLast ?? true;
    final text = item?.text ?? message.text;
    final api = ref.watch(hermesApiProvider);
    final pictures = [
      if (last)
        for (final m in message.media) ?MediaItem.fromRef(m, api),
    ];
    final base = message.interim
        ? (theme.bodyMedium ?? const TextStyle()).copyWith(
            color: colors.textSecondary,
          )
        : theme.bodyLarge ?? const TextStyle();
    final body = base.copyWith(height: scale.bodyLineHeight);
    void actions({Offset? at}) => showMessageActions(
      context,
      ref,
      target,
      latest?.call() ?? message,
      pointer: at,
    );
    final error = message.error;

    return Padding(
      padding: EdgeInsets.only(bottom: last ? spacing.turnGap : 0),
      child: MessageActionsSemantics(
        onActions: actions,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPress: actions,
          // A right-click on the text opens the text's own menu, which
          // carries these actions too.
          onSecondaryTapUp: (d) => actions(at: d.globalPosition),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (first && message.visibleReasoning.isNotEmpty)
                ReasoningChip(reasoning: message.visibleReasoning),
              if (first && message.tools.isNotEmpty)
                ToolGroup(
                  key: ValueKey('tools/${message.id}'),
                  tools: message.tools,
                ),
              if (text.trim().isNotEmpty)
                MarkdownPiece(
                  text,
                  gap: item?.gap ?? false,
                  style: body,
                  onMoreActions: actions,
                  direction: item?.direction,
                ),
              if (pictures.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: spacing.sm),
                  child: MediaStrip(items: pictures),
                ),
              if (last)
                for (final media in message.media)
                  if (media.kind != AttachmentKind.image)
                    Padding(
                      padding: EdgeInsets.only(top: spacing.sm),
                      child: MediaAttachment(
                        media: media,
                        profile: target.profile,
                      ),
                    ),
              if (last && message.streaming) const StreamCaret(),
              // Only once settled: a clock under arriving text would jump.
              if (last && !message.streaming && !message.interim)
                MessageTimestamp.leading(time: message.timestamp),
              if (last && error != null)
                Padding(
                  padding: EdgeInsets.only(top: spacing.xs),
                  child: Text(
                    error.trim().isEmpty
                        ? context.l10n.errorUnknown
                        : context.l10n.chatErrorTurn(error),
                    style: theme.bodySmall?.copyWith(color: colors.danger),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
