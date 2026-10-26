import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/failure_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/models/bot_soul.dart';
import '../bot_details_providers.dart';

/// The `SOUL.md` editor: a page, as a route can refuse to close over unsaved
/// work and a sheet's drag cannot. Pops `true` once the gateway has the text
/// ([SoulSave] does the saving).
class SoulEditorPage extends ConsumerStatefulWidget {
  const SoulEditorPage({
    required this.profile,
    required this.initial,
    super.key,
  });

  final String profile;

  /// The file when the editor opened: unsaved work, and on save a change
  /// made elsewhere, are told against it.
  final BotSoul initial;

  @override
  ConsumerState<SoulEditorPage> createState() => _SoulEditorPageState();
}

class _SoulEditorPageState extends ConsumerState<SoulEditorPage> {
  // Rebuilds on a change of dirtiness or direction, not on every keystroke.
  late final TextEditingController _text = TextEditingController(
    text: widget.initial.content,
  )..addListener(_onTextChanged);
  late TextDirection _direction = directionOf(widget.initial.content);
  Timer? _directionTimer;
  bool _dirty = false;

  void _onTextChanged() {
    final dirty = _text.text != widget.initial.content;
    if (dirty != _dirty) setState(() => _dirty = dirty);
    // The direction settles once typing pauses.
    _directionTimer?.cancel();
    _directionTimer = Timer(context.motion.normal, () {
      final direction = directionOf(_text.text);
      if (mounted && direction != _direction) {
        setState(() => _direction = direction);
      }
    });
  }

  @override
  void dispose() {
    _directionTimer?.cancel();
    _text.dispose();
    super.dispose();
  }

  Future<void> _confirmDiscard() async {
    final discard = await confirmDiscard(
      context,
      body: context.l10n.botSoulDiscardBody,
    );
    if (discard && mounted) Navigator.of(context).pop(false);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final text = _text.text;
    if (text.trim().isEmpty && !widget.initial.isBlank) {
      final go = await showConfirmDialog(
        context,
        title: l10n.botSoulEmptyConfirmTitle,
        body: l10n.botSoulEmptyConfirmBody,
        confirmLabel: l10n.botSoulSaveEmpty,
        icon: CupertinoIcons.checkmark,
      );
      if (!go || !mounted) return;
    }
    final saved = await ref
        .read(soulSaveProvider(widget.profile).notifier)
        .save(
          text,
          base: widget.initial.content,
          confirmReplace: () async =>
              mounted &&
              await showConfirmDialog(
                context,
                title: l10n.botSoulChangedTitle,
                body: l10n.botSoulChangedBody,
                confirmLabel: l10n.botSoulReplace,
                icon: CupertinoIcons.checkmark,
              ),
        );
    if (saved && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final save = ref.watch(soulSaveProvider(widget.profile));
    final saving = save.isLoading;
    final error = save.error;

    return PopScope(
      // A save in flight cannot be undone: stay until it answers.
      canPop: !_dirty && !saving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !saving) unawaited(_confirmDiscard());
      },
      child: Scaffold(
        appBar: readingAppBar(
          context,
          title: l10n.botSoulEditorTitle,
          onClose: () => Navigator.of(context).maybePop(),
          action: AppIconButton(
            icon: CupertinoIcons.checkmark,
            tooltip: l10n.botSoulSave,
            busy: saving,
            onPressed: _dirty && !saving ? _save : null,
          ),
        ),
        body: SafeArea(
          child: ReadingColumn(
            padding: EdgeInsets.only(top: spacing.sm, bottom: spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.sm),
                    child: ErrorText(
                      l10n.botSoulSaveFailed(failureText(context, error)),
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: _text,
                    enabled: !saving,
                    expands: true,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    textDirection: _direction,
                    style: context.textScale.mono(),
                    // A page of text, as iOS Notes: no field drawn.
                    decoration: InputDecoration.collapsed(
                      hintText: l10n.botSoulEditorHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
