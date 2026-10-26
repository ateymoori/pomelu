import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/chat_message.dart';
import '../../domain/chat_target.dart';
import 'code_block.dart';
import 'message_actions.dart';

/// Transcript row for a slash command the user ran: the command as a quiet
/// label, then its text output in a monospace block. While the gateway is
/// still working the row says so, over the log so far; a failed command
/// shows its error.
class SlashOutput extends ConsumerWidget {
  const SlashOutput({required this.message, required this.target, super.key});

  /// A `ChatRole.system` row whose `command` is set.
  final ChatMessage message;
  final ChatTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final spacing = context.spacing;
    final theme = Theme.of(context).textTheme;
    final text = message.text.trim();
    final running = message.delivery == DeliveryState.sending;
    final failed = message.delivery == DeliveryState.failed;

    void actions({Offset? at}) =>
        showMessageActions(context, ref, target, message, pointer: at);

    // The whole row answers a long press, as every message does. The command
    // label is also a plain button, which a keyboard, a switch or a screen
    // reader can reach.
    return MessageActionsSemantics(
      onActions: actions,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: actions,
        onSecondaryTapUp: (d) => actions(at: d.globalPosition),
        child: Padding(
          padding: EdgeInsets.only(bottom: spacing.turnGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                hint: context.l10n.chatMessageActionsLabel,
                child: InkWell(
                  onTap: actions,
                  borderRadius: BorderRadius.circular(context.radii.sm),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: spacing.inlineRow),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.command,
                          size: spacing.md,
                          color: colors.textTertiary,
                        ),
                        SizedBox(width: spacing.xs),
                        Expanded(
                          child: Text(
                            message.command ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.labelMedium?.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing.xs),
              if (running) ...[
                PulseFade(
                  child: Text(
                    context.l10n.slashRunning,
                    style: theme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                if (text.isNotEmpty) ...[
                  SizedBox(height: spacing.xs),
                  CodeBlock(code: text),
                ],
              ] else if (failed)
                Text(
                  text.isEmpty ? context.l10n.slashFailed : text,
                  style: theme.bodySmall?.copyWith(color: colors.danger),
                )
              else if (text.isEmpty)
                Text(
                  context.l10n.slashDone,
                  style: theme.bodySmall?.copyWith(color: colors.textSecondary),
                )
              else
                CodeBlock(code: text),
            ],
          ),
        ),
      ),
    );
  }
}
