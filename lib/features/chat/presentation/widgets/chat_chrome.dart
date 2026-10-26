import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../bot_details/presentation/widgets/bot_details_sheet.dart';
import '../../../bot_screen/presentation/widgets/screen_action.dart';
import '../../domain/chat_target.dart';
import '../../domain/model_catalog.dart';
import '../chat_controller.dart';
import 'context_meter.dart';
import 'message_search.dart';

/// The chat pane's header: the bot's name over its model in a glass
/// capsule that opens the bot's details, then hidden messages, the context
/// ring, the bot's screen (when it has one) and find as glass buttons, in
/// the reading column. It has no bar: the transcript scrolls on under the
/// floating glass. On a narrow pane (by the pane's width, not the window's)
/// hidden messages and the screen fold into one overflow menu.
class ChatTopActions extends StatelessWidget {
  const ChatTopActions({
    required this.target,
    required this.botName,
    super.key,
    this.onOpenSidebar,
  });

  final ChatTarget target;
  final String botName;

  /// Opens the drawer on compact layouts; null hides the menu button.
  final VoidCallback? onOpenSidebar;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return LayoutBuilder(
      builder: (context, pane) {
        final compact = pane.maxWidth < spacing.headerWideMin;
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: spacing.minTouch),
          child: ReadingColumn(
            child: Row(
              children: [
                if (onOpenSidebar != null)
                  AppIconButton(
                    key: const Key('chat-top-menu'),
                    icon: CupertinoIcons.line_horizontal_3,
                    tooltip: context.l10n.actionOpenMenu,
                    onPressed: onOpenSidebar,
                  ),
                if (onOpenSidebar != null) SizedBox(width: spacing.iconGap),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Consumer(
                      builder: (context, ref, _) => _ChatTitle(
                        name: botName,
                        model: ref.watch(
                          chatControllerProvider(target).select((s) => s.model),
                        ),
                        onTap: () =>
                            unawaited(showBotDetails(context, target.profile)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spacing.sm),
                if (compact) ...[
                  ContextMeterAction(target: target),
                  _MoreActions(target: target),
                ] else ...[
                  _HiddenAction(target: target),
                  ContextMeterAction(target: target),
                  ScreenAction(profile: target.profile),
                ],
                AppIconButton(
                  key: const Key('chat-top-search'),
                  icon: CupertinoIcons.search,
                  tooltip: context.l10n.chatSearchOpen,
                  onPressed: MessageSearchLauncher.of(context)?.open,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The bot's name over the model it runs (no model line until it is
/// known) on a glass capsule, as tall as the buttons beside it. A tap opens
/// the bot's details.
class _ChatTitle extends StatelessWidget {
  const _ChatTitle({
    required this.name,
    required this.model,
    required this.onTap,
  });

  final String name;
  final String model;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final spacing = context.spacing;
    return AppGlass.capsule(
      // Says what a tap does: the capsule reads as a title.
      child: Semantics(
        container: true,
        hint: context.l10n.botDetailsAction,
        child: InkWell(
          key: const Key('chat-top-title'),
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: spacing.minTouch),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.titleMedium,
                    ),
                  ),
                  if (model.isNotEmpty)
                    Text(
                      modelDisplayName(model),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.labelMedium?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

int _hiddenCount(WidgetRef ref, ChatTarget target) =>
    ref.watch(chatControllerProvider(target).select((s) => s.hidden.length));

class _HiddenAction extends ConsumerWidget {
  const _HiddenAction({required this.target});

  final ChatTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = _hiddenCount(ref, target);
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsetsDirectional.only(end: context.spacing.iconGap),
      child: AppIconButton(
        key: const Key('chat-top-hidden'),
        icon: CupertinoIcons.eye_slash,
        tooltip: context.l10n.chatHiddenCount(count),
        onPressed: () => unawaited(_offerHidden(context, ref, target, count)),
      ),
    );
  }
}

Future<void> _offerHidden(
  BuildContext context,
  WidgetRef ref,
  ChatTarget target,
  int count,
) async {
  final l10n = context.l10n;
  final snacks = AppSnacks.of(context);
  final controller = ref.read(chatControllerProvider(target).notifier);
  final show = await showAppMenu<bool>(
    context,
    items: [
      AppMenuItem(
        value: true,
        label: l10n.chatShowHidden,
        icon: CupertinoIcons.eye,
      ),
    ],
  );
  if (show != true) return;
  controller.showAllHidden();
  snacks.show(l10n.chatShowHidden);
}

/// What the ⋯ menu picked.
enum _More { hidden, screen }

/// Hidden messages and the bot's screen on a narrow pane; nothing when
/// there is neither.
class _MoreActions extends ConsumerWidget {
  const _MoreActions({required this.target});

  final ChatTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final count = _hiddenCount(ref, target);
    final screen = watchBotScreen(ref, target.profile);
    if (count == 0 && screen == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsetsDirectional.only(end: context.spacing.iconGap),
      child: AppIconButton(
        key: const Key('chat-top-more'),
        icon: CupertinoIcons.ellipsis,
        // The dot says something is hidden; the label says how much.
        tooltip: count > 0
            ? l10n.chatMoreActionsHidden(count)
            : l10n.chatMoreActions,
        badge: count > 0,
        onPressed: () async {
          final picked = await showAppMenu<_More>(
            context,
            items: [
              if (count > 0)
                AppMenuItem(
                  key: const Key('chat-top-hidden'),
                  value: _More.hidden,
                  label: l10n.chatHiddenCount(count),
                  icon: CupertinoIcons.eye_slash,
                ),
              if (screen != null)
                AppMenuItem(
                  key: const Key('chat-top-screen'),
                  value: _More.screen,
                  label: l10n.screenAction,
                  icon: CupertinoIcons.desktopcomputer,
                  hint: screen.lease.humanHolds ? l10n.screenActionHeld : null,
                ),
            ],
          );
          if (!context.mounted) return;
          switch (picked) {
            case _More.hidden:
              await _offerHidden(context, ref, target, count);
            case _More.screen:
              openBotScreen(context, target.profile);
            case null:
          }
        },
      ),
    );
  }
}
