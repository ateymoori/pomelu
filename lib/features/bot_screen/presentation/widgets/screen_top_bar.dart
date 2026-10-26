import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/models/bot_screen.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/screen_view.dart';
import '../screen_session.dart';

/// What the Screen page shows of [status] and [view] in one line, and the
/// dot beside it.
(String, StatusKind) screenStatusLine(
  AppLocalizations l10n,
  ScreenStatus? status,
  ScreenView view,
) {
  if (status == null || !status.available) {
    return (l10n.screenNone, StatusKind.off);
  }
  if (!status.running) return (l10n.screenOff, StatusKind.off);
  return switch (view.stream) {
    ScreenStream.ended => (l10n.screenEnded, StatusKind.off),
    ScreenStream.idle ||
    ScreenStream.attaching => (l10n.screenConnecting, StatusKind.busy),
    ScreenStream.live => switch (status.lease.controlFor(view.viewerHash)) {
      ScreenControl.bot => (l10n.screenBotInControl, StatusKind.ok),
      ScreenControl.you => (
        switch (view.drag) {
          ScreenDrag.off => l10n.screenYouInControl,
          ScreenDrag.pick => l10n.screenDragPick,
          ScreenDrag.drop => l10n.screenDragDrop,
        },
        StatusKind.warn,
      ),
      ScreenControl.otherViewer => (l10n.screenOtherInControl, StatusKind.warn),
    },
  };
}

/// The Screen page's top row, floating over the desktop as the picture
/// viewer's does: close, the bot and who drives, and a ⋯ of the rarer
/// actions. [controls] sit in it too in a window too short for a second
/// row.
class ScreenTopBar extends StatelessWidget {
  const ScreenTopBar({
    required this.profile,
    required this.name,
    required this.status,
    required this.view,
    super.key,
    this.controls,
  });

  final String profile;
  final String name;
  final ScreenStatus? status;
  final ScreenView view;
  final Widget? controls;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final (line, kind) = screenStatusLine(context.l10n, status, view);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.all(spacing.gutter),
        child: Row(
          children: [
            AppIconButton(
              key: const Key('screen-close'),
              icon: CupertinoIcons.xmark,
              tooltip: context.l10n.actionClose,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Center(
                heightFactor: 1,
                child: _StatusPill(name: name, line: line, kind: kind),
              ),
            ),
            // The controls come first; the pill keeps a third at least.
            if (controls case final controls?) ...[
              SizedBox(width: spacing.sm),
              Flexible(flex: 2, child: controls),
            ],
            SizedBox(width: spacing.sm),
            _MoreActions(
              profile: profile,
              name: name,
              status: status,
              view: view,
            ),
          ],
        ),
      ),
    );
  }
}

/// The bot's name over who drives, on a solid pill: text on a desktop
/// picture loses contrast.
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.name,
    required this.line,
    required this.kind,
  });

  final String name;
  final String line;
  final StatusKind kind;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final text = Theme.of(context).textTheme;
    return AppSurface(
      border: false,
      borderRadius: BorderRadius.circular(context.radii.pill),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.xs,
      ),
      child: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelLarge,
              ),
            ),
            StatusDot(kind: kind, label: line),
          ],
        ),
      ),
    );
  }
}

enum _More { reconnect, giveBack }

class _MoreActions extends ConsumerWidget {
  const _MoreActions({
    required this.profile,
    required this.name,
    required this.status,
    required this.view,
  });

  final String profile;
  final String name;
  final ScreenStatus? status;
  final ScreenView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final running = status?.running ?? false;
    final control = status?.lease.controlFor(view.viewerHash);
    final items = [
      if (running)
        AppMenuItem(
          value: _More.reconnect,
          label: l10n.screenReconnect,
          icon: CupertinoIcons.arrow_clockwise,
        ),
      if (control == ScreenControl.otherViewer)
        AppMenuItem(
          value: _More.giveBack,
          label: l10n.screenGiveBack(name),
          icon: CupertinoIcons.hand_raised_slash,
          enabled: !view.busy,
        ),
    ];
    // Keeps the pill centred when there is nothing to offer.
    if (items.isEmpty) {
      return SizedBox.square(dimension: context.spacing.minTouch);
    }
    final session = ref.read(screenSessionProvider(profile).notifier);
    return AppIconButton(
      key: const Key('screen-more'),
      icon: CupertinoIcons.ellipsis,
      tooltip: l10n.chatMoreActions,
      onPressed: () async {
        final picked = await showAppMenu<_More>(context, items: items);
        if (!context.mounted) return;
        switch (picked) {
          case _More.reconnect:
            session.reconnect();
          case _More.giveBack:
            final go = await showConfirmDialog(
              context,
              title: l10n.screenGiveBackTitle(name),
              body: l10n.screenGiveBackBody(name),
              confirmLabel: l10n.screenGiveBack(name),
              icon: CupertinoIcons.hand_raised_slash,
            );
            if (go) await session.handBack();
          case null:
        }
      },
    );
  }
}
