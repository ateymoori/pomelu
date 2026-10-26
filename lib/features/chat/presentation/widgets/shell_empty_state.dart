import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';

/// The shell with no chat open: set up a gateway first, else pick a bot
/// ([onOpenMenu] opens the drawer that lists them; null hides the button).
class ShellEmptyState extends StatelessWidget {
  const ShellEmptyState({required this.configured, super.key, this.onOpenMenu});

  /// Whether a gateway is set up.
  final bool configured;
  final VoidCallback? onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!configured) {
      return EmptyState(
        icon: CupertinoIcons.wifi_slash,
        title: l10n.connStateNotConfigured,
        message: l10n.shellNoGatewayBody,
        action: FilledButton.icon(
          onPressed: () => context.push<void>(Routes.settings),
          icon: const Icon(CupertinoIcons.gear),
          label: Text(l10n.actionOpenSettings),
        ),
      );
    }
    final open = onOpenMenu;
    return EmptyState(
      icon: CupertinoIcons.chat_bubble_2,
      title: l10n.chatSelectTitle,
      message: l10n.chatSelectBody,
      action: open == null
          ? null
          : OutlinedButton.icon(
              onPressed: open,
              icon: const Icon(CupertinoIcons.line_horizontal_3),
              label: Text(l10n.actionOpenMenu),
            ),
    );
  }
}
