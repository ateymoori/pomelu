import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/models/bot_screen.dart';
import '../bot_screen_providers.dart';

/// Bot [profile]'s screen, when it has one.
ScreenStatus? watchBotScreen(WidgetRef ref, String profile) {
  final status = ref.watch(botScreenProvider(profile)).value;
  return status != null && status.available ? status : null;
}

/// Opens bot [profile]'s screen over its chat. The composer gives up focus
/// first, or the route would hand it back on close and raise the keyboard.
void openBotScreen(BuildContext context, String profile) {
  FocusManager.instance.primaryFocus?.unfocus();
  unawaited(GoRouter.of(context).push(Routes.screenPath(profile)));
}

/// The chat header's way to the bot's screen, shown only when it has one.
/// Its dot is lit while a person drives the screen: the bot waits until
/// they hand it back.
class ScreenAction extends ConsumerWidget {
  const ScreenAction({required this.profile, super.key});

  final String profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = watchBotScreen(ref, profile);
    if (status == null) return const SizedBox.shrink();
    final held = status.lease.humanHolds;
    return Padding(
      padding: EdgeInsetsDirectional.only(end: context.spacing.iconGap),
      child: AppIconButton(
        key: const Key('chat-top-screen'),
        icon: CupertinoIcons.desktopcomputer,
        tooltip: held
            ? context.l10n.screenActionHeld
            : context.l10n.screenAction,
        badge: held,
        onPressed: () => openBotScreen(context, profile),
      ),
    );
  }
}
