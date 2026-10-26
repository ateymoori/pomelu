import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/failure_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../bot_details/presentation/bot_edit_providers.dart';

/// Asks for a name, creates the bot and opens its chat.
class NewBotButton extends ConsumerWidget {
  const NewBotButton({super.key, this.onNavigate});

  /// After the new chat opens, so the shell can close its drawer.
  final VoidCallback? onNavigate;

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final snacks = AppSnacks.of(context);
    final router = GoRouter.of(context);
    final name = await AppSheet.show<String>(
      context,
      builder: (sheet) => TextEntrySheet(
        title: l10n.botNew,
        initial: '',
        submitLabel: sheet.l10n.botNewCreate,
      ),
    );
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    final id = await ref.read(botCreateProvider.notifier).create(name);
    if (!context.mounted) return;
    if (id == null) {
      final error = ref.read(botCreateProvider).error;
      if (error != null) {
        snacks.show(l10n.botNewFailed(failureText(context, error)));
      }
      return;
    }
    router.go(Routes.chatPath(id));
    onNavigate?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched: keeps the create alive while the sheet is gone, and spins.
    final busy = ref.watch(botCreateProvider).isLoading;
    return AppIconButton(
      icon: CupertinoIcons.plus,
      tooltip: context.l10n.botNew,
      busy: busy,
      onPressed: busy ? null : () => unawaited(_create(context, ref)),
    );
  }
}
