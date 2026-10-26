import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/hermes_constants.dart';
import '../../../../hermes/models/bot_soul.dart';
import '../../../chat/domain/markdown_chunks.dart';
import '../../../chat/presentation/widgets/markdown_body.dart';
import '../bot_details_providers.dart';
import 'capability_async.dart';
import 'soul_editor_page.dart';

/// `SOUL.md` as formatted text; edited on a page of its own.
class SoulTab extends ConsumerStatefulWidget {
  const SoulTab({required this.profile, super.key});

  final String profile;

  @override
  ConsumerState<SoulTab> createState() => _SoulTabState();
}

class _SoulTabState extends ConsumerState<SoulTab> {
  /// After a save: the note shows in the sheet, where a snack bar would be
  /// hidden.
  bool _saved = false;

  Future<void> _edit() async {
    // The file as it is now: after a save the tab may still show the old.
    final BotSoul soul;
    try {
      soul = await ref.read(botSoulProvider(widget.profile).future);
    } on Object {
      return; // The tab shows the failure, with Retry.
    }
    if (!mounted) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => SoulEditorPage(profile: widget.profile, initial: soul),
      ),
    );
    if (saved != true || !mounted) return;
    ref.invalidate(botSoulProvider(widget.profile));
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = botSoulProvider(widget.profile);
    return CapabilityAsync(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      data: (soul) => soul.isBlank
          ? EmptyState(
              icon: CupertinoIcons.doc_text,
              title: l10n.botSoulEmptyTitle,
              message: l10n.botSoulEmptyBody,
              action: FilledButton(
                onPressed: _edit,
                child: Text(l10n.botSoulWrite),
              ),
            )
          : _SoulView(soul: soul, saved: _saved, onEdit: _edit),
    );
  }
}

class _SoulView extends StatelessWidget {
  const _SoulView({
    required this.soul,
    required this.saved,
    required this.onEdit,
  });

  final BotSoul soul;
  final bool saved;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    // The label and notes line up with the card's text.
    final inset = spacing.lg * 2;
    final body = theme.bodyMedium;
    final chunks = MarkdownChunks.split(
      soul.content,
      target: AppConfig.replyChunkChars,
    );
    // One direction for the whole file, as for a reply.
    final direction = markdownDirection(soul.content);

    return Column(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            inset,
            spacing.md,
            spacing.sm,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  HermesProtocol.soulFile,
                  style: context.textScale.mono(color: colors.textSecondary),
                ),
              ),
              TextButton(onPressed: onEdit, child: Text(l10n.botSoulEdit)),
            ],
          ),
        ),
        if (saved)
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              inset,
              spacing.sm,
              inset,
              0,
            ),
            child: Semantics(
              liveRegion: true,
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    size: spacing.lg,
                    color: colors.success,
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Text(
                      l10n.botSoulSaved,
                      style: theme.bodySmall?.copyWith(color: colors.success),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // In pieces, like a long reply: only those on screen are built.
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              spacing.lg,
              spacing.sm,
              spacing.lg,
              spacing.xl,
            ),
            itemCount: chunks.length,
            itemBuilder: (context, i) => CardSlice(
              first: i == 0,
              last: i == chunks.length - 1,
              child: MarkdownPiece(
                chunks[i].text,
                gap: chunks[i].gap,
                style: body,
                direction: direction,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
