import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/hermes_constants.dart';
import '../../../../hermes/models/bot_screen.dart';
import '../../domain/screen_view.dart';
import '../screen_session.dart';

/// Take over, or (with control) drag and drop, the keyboard, paste and
/// Hand back, on one glass capsule; Whole screen while the view is zoomed
/// in.
class ScreenControls extends ConsumerWidget {
  const ScreenControls({
    required this.profile,
    required this.name,
    required this.status,
    required this.view,
    required this.typing,
    super.key,
  });

  final String profile;
  final String name;
  final ScreenStatus status;
  final ScreenView view;

  /// The hidden field the keyboard types into.
  final FocusNode typing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final session = ref.read(screenSessionProvider(profile).notifier);
    final control = status.lease.controlFor(view.viewerHash);
    final live = view.stream == ScreenStream.live;
    return AppGlass.capsule(
      padding: EdgeInsets.all(spacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (view.zoomed)
            AppIconButton(
              key: const Key('screen-fit'),
              icon: CupertinoIcons.fullscreen_exit,
              tooltip: l10n.screenFit,
              onPressed: session.fit,
            ),
          if (control == ScreenControl.you) ...[
            AppIconButton(
              key: const Key('screen-drag'),
              icon: CupertinoIcons.move,
              tooltip: view.drag == ScreenDrag.off
                  ? l10n.screenDrag
                  : l10n.screenDragCancel,
              filled: view.drag != ScreenDrag.off,
              onPressed: live ? session.toggleDrag : null,
            ),
            AppIconButton(
              key: const Key('screen-keyboard'),
              icon: CupertinoIcons.keyboard,
              tooltip: l10n.screenKeyboard,
              onPressed: () =>
                  typing.hasFocus ? typing.unfocus() : typing.requestFocus(),
            ),
            AppIconButton(
              key: const Key('screen-paste'),
              icon: CupertinoIcons.doc_on_clipboard,
              tooltip: l10n.screenPaste,
              onPressed: () => unawaited(pasteOnScreen(context, session)),
            ),
            SizedBox(width: spacing.xs),
            Flexible(
              child: _Primary(
                key: const Key('screen-hand-back'),
                label: l10n.screenHandBack,
                icon: CupertinoIcons.hand_raised_slash,
                busy: view.task == ScreenTask.handBack,
                onPressed: view.busy ? null : session.handBack,
              ),
            ),
          ] else
            Flexible(
              child: _Primary(
                key: const Key('screen-take-over'),
                label: l10n.screenTakeOver,
                icon: CupertinoIcons.hand_raised,
                busy: view.task == ScreenTask.takeOver,
                onPressed: live && !view.busy
                    ? () => unawaited(_takeOver(context, session, control))
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _takeOver(
    BuildContext context,
    ScreenSession session,
    ScreenControl control,
  ) async {
    if (control == ScreenControl.otherViewer) {
      final l10n = context.l10n;
      final go = await showConfirmDialog(
        context,
        title: l10n.screenTakeOverTitle,
        body: l10n.screenTakeOverBody(name),
        confirmLabel: l10n.screenTakeOver,
        icon: CupertinoIcons.hand_raised,
      );
      if (!go) return;
    }
    await session.takeOver();
  }
}

/// The phone's clipboard to the desktop: typed where its cursor is (what a
/// login field takes), and on its clipboard for its own Paste.
Future<void> pasteOnScreen(BuildContext context, ScreenSession session) async {
  final l10n = context.l10n;
  final snacks = AppSnacks.of(context);
  final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
  if (text.isEmpty) {
    snacks.show(l10n.screenPasteEmpty);
  } else if (utf8.encode(text).length > HermesLimits.screenClipboardBytes) {
    snacks.show(l10n.screenPasteTooLong);
  } else if (!session.paste(text)) {
    snacks.show(l10n.screenPasteOnClipboard);
  }
}

/// The capsule's one prominent action; its label is cut short before the
/// capsule overflows (large text on a small phone).
class _Primary extends StatelessWidget {
  const _Primary({
    required this.label,
    required this.icon,
    required this.busy,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: busy ? null : onPressed,
    icon: busy ? const AppSpinner.icon() : Icon(icon),
    label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
  );
}
