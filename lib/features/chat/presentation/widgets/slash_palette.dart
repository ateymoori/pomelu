import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/slash_command.dart';
import 'chat_icons.dart';

/// Autocomplete list docked above the composer while a `/command` is typed.
class SlashPalette extends StatelessWidget {
  const SlashPalette({
    required this.suggestions,
    required this.onPick,
    super.key,
  });

  final List<SlashCommand> suggestions;
  final ValueChanged<SlashCommand> onPick;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;

    return AppGlass(
      floating: true,
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: spacing.paletteMaxHeight),
        child: suggestions.isEmpty
            ? Padding(
                padding: EdgeInsets.all(spacing.md),
                // Its own node: loose words here would join the chat
                // header's node.
                child: Semantics(
                  container: true,
                  child: Text(
                    context.l10n.slashNoMatch,
                    style: theme.bodyMedium?.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ),
              )
            : ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  for (final c in suggestions)
                    _SlashRow(command: c, onTap: () => onPick(c)),
                ],
              ),
      ),
    );
  }
}

/// One command row: its icon, name and one-line description.
class _SlashRow extends StatelessWidget {
  const _SlashRow({required this.command, required this.onTap});

  final SlashCommand command;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final description = switch (command) {
      SlashCommand.newConversation => l10n.slashNewDesc,
      SlashCommand.restart => l10n.slashRestartDesc,
      SlashCommand.update => l10n.slashUpdateDesc,
      SlashCommand.compact => l10n.slashCompactDesc,
    };

    return ListTile(
      dense: true,
      leading: Icon(command.icon, color: colors.textTertiary),
      title: Text(command.slash, style: theme.titleSmall),
      subtitle: Text(
        description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.bodySmall?.copyWith(color: colors.textSecondary),
      ),
      onTap: onTap,
    );
  }
}
