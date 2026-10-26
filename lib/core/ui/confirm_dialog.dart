import 'package:flutter/cupertino.dart'
    show CupertinoDialogAction, CupertinoIcons;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/l10n_ext.dart';

/// Asks to confirm a destructive action: true only on the confirm button.
/// On iOS it is the system alert (Liquid Glass, red destructive action).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? body,
  IconData icon = CupertinoIcons.trash,
}) async {
  final l10n = context.l10n;
  final ios = Theme.of(context).platform == TargetPlatform.iOS;
  final result = await showAdaptiveDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog.adaptive(
      title: Text(title),
      content: body == null ? null : Text(body),
      actions: ios
          ? [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.actionCancel),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(confirmLabel),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton.icon(
                style: dialogContext.destructiveButtonStyle,
                onPressed: () => Navigator.of(dialogContext).pop(true),
                icon: Icon(icon),
                label: Text(confirmLabel),
              ),
            ],
    ),
  );
  return result ?? false;
}

/// Asks before a page drops unsaved changes; true on Discard.
Future<bool> confirmDiscard(BuildContext context, {required String body}) {
  final l10n = context.l10n;
  return showConfirmDialog(
    context,
    title: l10n.discardTitle,
    body: body,
    confirmLabel: l10n.actionDiscard,
    icon: CupertinoIcons.xmark,
  );
}
