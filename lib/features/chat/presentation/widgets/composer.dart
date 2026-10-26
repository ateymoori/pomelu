import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/app_settings.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/hermes_constants.dart';
import '../../../../hermes/models/local_attachment.dart';
import '../../../share/domain/composer_seed.dart';
import '../../data/attachments.dart';
import '../../domain/chat_target.dart';
import '../../domain/slash_command.dart';
import '../chat_controller.dart';
import '../composer_draft.dart';
import 'attachment_thumb.dart';
import 'chat_icons.dart';
import 'composer_field.dart';
import 'composer_settings_sheet.dart';
import 'composer_status.dart';
import 'location_picker.dart';
import 'media_strip.dart';
import 'mic_button.dart';
import 'recording_hint.dart';
import 'slash_palette.dart';

part 'composer_input.dart';

/// The docked composer: one row at every width (attach, one text line,
/// settings, send or mic), so the transcript keeps the screen. A composer
/// serves one chat for its life; another bot gets its own, with its draft.
class Composer extends ConsumerStatefulWidget {
  const Composer({
    required this.target,
    required this.botName,
    required this.enabled,
    required this.running,
    super.key,
    this.seed,
  });

  final ChatTarget target;
  final String botName;

  /// False while the session opens.
  final bool enabled;

  /// A turn runs: send becomes stop.
  final bool running;

  /// Content to put in once, from a share or a deep link.
  final ComposerSeed? seed;

  @override
  ConsumerState<Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<Composer> with _ComposerInput {
  // Leaving the app lets go of the field: on return Flutter would ask for
  // the keyboard again, and Samsung's keyboard can then close without its
  // inset going away, which leaves the composer floating mid-screen.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onHide: _focus.unfocus);
    _focus.onKeyEvent = _onKey;
    // The listener goes up before the seed, so what the seed adds is saved.
    _text.text = _draft.savedText();
    _text.addListener(_onTextChanged);
    _applySeed(widget.seed);
  }

  @override
  void didUpdateWidget(Composer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.seed != null && oldWidget.seed != widget.seed) {
      _applySeed(widget.seed);
    }
  }

  @override
  void dispose() {
    _draft.flush();
    _text
      ..removeListener(_onTextChanged)
      ..dispose();
    _lifecycle.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = context.l10n;
    // A narrow slice, compared by value: no rebuild per streamed token.
    final state = ref.watch(
      chatControllerProvider(widget.target).select(
        (s) => (
          canCompose: s.canCompose,
          online: s.online,
          queued: s.queuedCount,
          failed: s.failedCount,
          upload: s.upload,
          stopRequested: s.stopRequested,
        ),
      ),
    );
    final (:attachments, :transcribing) = ref.watch(
      composerDraftControllerProvider(widget.target),
    );
    final recording = _recording;
    final hasContent = _text.text.trim().isNotEmpty || attachments.isNotEmpty;
    // Composing works with the socket down: an offline turn is queued.
    final active = (widget.enabled || state.canCompose) && !transcribing;
    final showPalette =
        attachments.isEmpty &&
        SlashCommand.isNameQuery(_text.text) &&
        _paletteDismissedFor != _text.text;
    final pictures = [
      for (final a in attachments)
        if (MediaItem.fromLocal(a) case final item?) (a, item),
    ];
    final files = attachments.where((a) => !a.isImage).toList();

    // A take in progress keeps the mic: the recording lives in its gesture.
    final Widget action;
    if (widget.running && recording == null) {
      action = AppIconButton(
        icon: CupertinoIcons.stop_fill,
        tooltip: l10n.chatStop,
        filled: true,
        // One interrupt per turn.
        onPressed: state.stopRequested
            ? null
            : () => unawaited(_controller.stop()),
      );
    } else if (hasContent && recording == null) {
      action = AppIconButton(
        icon: CupertinoIcons.arrow_up,
        tooltip: l10n.chatSend,
        filled: true,
        onPressed: active ? () => unawaited(_send()) : null,
      );
    } else {
      action = MicButton(
        enabled: active,
        onChanged: (p) => setState(() => _recording = p),
        onRecorded: (a) => unawaited(_onRecorded(a)),
        // A refusal for good is undone in the system settings only.
        onDenied: () => AppSnacks.of(context).show(
          l10n.attachMicDenied,
          action: SnackBarAction(
            label: l10n.actionOpenSettings,
            onPressed: () => unawaited(openAppSettings()),
          ),
        ),
        onTooShort: () => _snack(l10n.chatRecord),
      );
    }

    final previewPadding = EdgeInsets.symmetric(
      horizontal: spacing.sm,
      vertical: spacing.xs,
    );
    // One gutter, one width with the transcript and the request card.
    return ReadingColumn(
      padding: EdgeInsets.only(top: spacing.xxs, bottom: spacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showPalette)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.sm),
              // The field's tap group: a tap anywhere else dismisses.
              child: TextFieldTapRegion(
                onTapOutside: (_) =>
                    setState(() => _paletteDismissedFor = _text.text),
                child: SlashPalette(
                  suggestions: SlashCommand.suggest(_text.text),
                  onPick: (c) => unawaited(_runSlash(c)),
                ),
              ),
            ),
          AppGlass(
            // A true pill: each end a half circle around its button.
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(
                spacing.minTouch / 2 + spacing.composerInset,
              ),
            ),
            floating: true,
            padding: EdgeInsets.all(spacing.composerInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (pictures.isNotEmpty)
                  Padding(
                    padding: previewPadding,
                    child: MediaStrip(
                      items: [for (final p in pictures) p.$2],
                      onRemove: (i) => _draft.remove(pictures[i].$1),
                    ),
                  ),
                if (files.isNotEmpty)
                  Padding(
                    padding: previewPadding,
                    child: Wrap(
                      spacing: spacing.sm,
                      runSpacing: spacing.sm,
                      children: [
                        for (final a in files)
                          AttachmentThumb(
                            key: ValueKey(a.id),
                            attachment: a,
                            onRemove: () => _draft.remove(a),
                          ),
                      ],
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Its own context: the menu opens at the button.
                    Builder(
                      builder: (button) => AppIconButton(
                        icon: CupertinoIcons.plus,
                        tooltip: l10n.chatAttach,
                        onPressed: active
                            ? () => unawaited(_pick(button))
                            : null,
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    Expanded(
                      child: recording == null
                          ? ComposerField(
                              controller: _text,
                              focusNode: _focus,
                              botName: widget.botName,
                              enabled: active || transcribing,
                            )
                          : RecordingHint(progress: recording),
                    ),
                    SizedBox(width: spacing.sm),
                    AppIconButton(
                      icon: CupertinoIcons.slider_horizontal_3,
                      tooltip: l10n.composerModelAndEffort,
                      onPressed: active
                          ? () => unawaited(_openSettings())
                          : null,
                    ),
                    SizedBox(width: spacing.iconGap),
                    action,
                  ],
                ),
                ComposerStatus(
                  online: state.online,
                  queued: state.queued,
                  failed: state.failed,
                  transcribing: transcribing,
                  upload: state.upload,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
