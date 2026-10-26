import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../chat/domain/chat_target.dart';
import '../../../connection/presentation/connection_providers.dart';
import '../../domain/bot_group.dart';
import '../sidebar_providers.dart';
import '../sidebar_state.dart';
import 'avatar.dart';
import 'sidebar_frame.dart';

/// The collapsed side menu: bot avatars, expand and settings. Below
/// `railMaxHeight` the rail is no choice, so it has no expand. The panel's
/// states (no gateway, loading, failed, empty) are one button each here.
class SidebarRail extends ConsumerWidget {
  const SidebarRail({super.key, this.selected});

  final ChatTarget? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final configured = ref.watch(gatewayConfigProvider) != null;
    final groups = ref.watch(sidebarGroupsProvider);

    // As the full menu's Retry: from scratch, so a roster that never
    // connected waits for it again.
    void retry() => ref.invalidate(profilesProvider);

    final canExpand =
        MediaQuery.sizeOf(context).height >= spacing.railMaxHeight;

    final Widget body = !configured
        ? _RailNotice(
            icon: CupertinoIcons.wifi_slash,
            label: l10n.connStateNotConfigured,
            onPressed: () => context.push<void>(Routes.settings),
          )
        : groups.when(
            loading: () => const _RailLoading(),
            error: (error, _) => _RailNotice(
              icon: CupertinoIcons.wifi_slash,
              label: l10n.sidebarRailLoadFailed,
              onPressed: retry,
              liveRegion: true,
            ),
            data: (list) => list.isEmpty
                ? _RailNotice(
                    icon: CupertinoIcons.person_2,
                    label: l10n.sidebarNoBots,
                    onPressed: retry,
                  )
                : _RailBots(groups: list, current: selected?.profile),
          );

    return SidebarFrame(
      width: spacing.railWidth,
      children: [
        if (canExpand) ...[
          AppIconButton(
            icon: CupertinoIcons.line_horizontal_3,
            tooltip: l10n.sidebarExpandMenu,
            onPressed: () =>
                ref.read(sidebarCollapsedProvider.notifier).set(false),
          ),
          SizedBox(height: spacing.md),
        ],
        Expanded(child: body),
        SizedBox(height: spacing.sm),
        AppIconButton(
          icon: CupertinoIcons.gear,
          tooltip: l10n.navSettings,
          onPressed: () => context.push<void>(Routes.settings),
        ),
        SizedBox(height: spacing.md),
      ],
    );
  }
}

/// One avatar a bot; the open one has an accent ring.
class _RailBots extends StatelessWidget {
  const _RailBots({required this.groups, required this.current});

  final List<BotGroup> groups;
  final String? current;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final surfaces = context.surfaces;
    return ListView(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      children: [
        for (final group in groups)
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.xs),
            // One announcement a bot.
            child: Tooltip(
              message: group.title,
              excludeFromSemantics: true,
              child: Semantics(
                button: true,
                label: group.title,
                selected: group.name == current,
                onTap: () => context.go(Routes.chatPath(group.name)),
                excludeSemantics: true,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => context.go(Routes.chatPath(group.name)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: spacing.minTouch),
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: group.name == current
                                ? colors.accent
                                : Colors.transparent,
                            width: surfaces.borderWidth * 2,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(spacing.xxs),
                          child: BotAvatar(
                            name: group.name,
                            title: group.title,
                            busy: group.working,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RailLoading extends StatelessWidget {
  const _RailLoading();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Semantics(
      label: context.l10n.spinnerLoading,
      child: Column(
        children: [
          for (var i = 0; i < spacing.skeletonRows; i++)
            Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.sm),
              child: ShimmerLine(
                width: spacing.avatar,
                height: spacing.avatar,
                borderRadius: BorderRadius.circular(context.radii.pill),
              ),
            ),
        ],
      ),
    );
  }
}

/// One round button for a state, doing what the panel's action does.
class _RailNotice extends StatelessWidget {
  const _RailNotice({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.liveRegion = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.topCenter,
    // One node: the state, a button and (for a failure) a live region.
    child: Semantics(
      container: true,
      button: true,
      liveRegion: liveRegion,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: AppIconButton(icon: icon, tooltip: label, onPressed: onPressed),
    ),
  );
}
