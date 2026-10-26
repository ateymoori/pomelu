import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../sidebar/presentation/sidebar_providers.dart';

/// The shell's keys on a hardware keyboard (a tablet's, a Chromebook's):
/// Control-Tab and Control-Shift-Tab step through the bots in the side
/// pane's order, Command (Control off Apple) with 1 to 9 opens the bot in
/// that place, and with comma the settings, as on a Mac.
class ShellShortcuts extends ConsumerWidget {
  const ShellShortcuts({required this.profile, required this.child, super.key});

  /// The open bot, null on `/`.
  final String? profile;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apple = switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };
    SingleActivator command(LogicalKeyboardKey key) =>
        SingleActivator(key, meta: apple, control: !apple);

    void open(int Function(int current, int count) pick) {
      final bots = ref.read(sidebarGroupsProvider).value;
      if (bots == null || bots.isEmpty) return;
      final current = bots.indexWhere((g) => g.name == profile);
      final next = pick(current, bots.length);
      if (next < 0 || next >= bots.length || next == current) return;
      context.go(Routes.chatPath(bots[next].name));
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.tab, control: true): () =>
            open((current, count) => (current + 1) % count),
        const SingleActivator(
          LogicalKeyboardKey.tab,
          control: true,
          shift: true,
        ): () => open(
          (current, count) => current < 0 ? count - 1 : (current - 1) % count,
        ),
        for (final (place, key) in _digits.indexed)
          command(key): () => open((_, _) => place),
        command(LogicalKeyboardKey.comma): () =>
            unawaited(context.push<void>(Routes.settings)),
      },
      child: child,
    );
  }
}

const List<LogicalKeyboardKey> _digits = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
];
