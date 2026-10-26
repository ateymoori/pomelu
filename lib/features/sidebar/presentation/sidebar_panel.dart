import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/config/assets.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../hermes/client/connection_state.dart';
import '../../chat/domain/chat_target.dart';
import '../../connection/presentation/connection_providers.dart';
import 'sidebar_providers.dart';
import 'sidebar_state.dart';
import 'widgets/bot_roster.dart';
import 'widgets/new_bot_button.dart';
import 'widgets/sidebar_frame.dart';

/// Inset of the bot list from the pane edge.
double _listInset(Spacing s) => s.sm;

/// Where a row's avatar starts: the list inset plus the tile padding.
double _avatarStart(Spacing s) => _listInset(s) + s.md;

/// Centres a round `minTouch` button on the avatar column.
double _buttonInset(Spacing s) => _avatarStart(s) + (s.avatar - s.minTouch) / 2;

/// The side menu: header, bots, footer. A drawer below 640 dp, a pane from
/// there, which can collapse to the `SidebarRail`.
class SidebarPanel extends ConsumerWidget {
  const SidebarPanel({
    super.key,
    this.selected,
    this.onNavigate,
    this.width,
    this.elevated = false,
    this.collapsible = false,
  });

  /// The chat on screen: its row is selected.
  final ChatTarget? selected;

  /// After a route change, so the shell can close its drawer.
  final VoidCallback? onNavigate;

  /// Null fills the parent.
  final double? width;

  /// The elevated drawer fill.
  final bool elevated;

  /// Shows the collapse button (the pane only).
  final bool collapsible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final configured = ref.watch(gatewayConfigProvider) != null;
    Future<void> refresh() => ref.read(profilesProvider.notifier).refresh();
    void open(String location) {
      onNavigate?.call();
      unawaited(context.push<void>(location));
    }

    final Widget body;
    if (configured) {
      body = BotRoster(
        selected: selected?.profile,
        padding: EdgeInsets.symmetric(
          horizontal: _listInset(spacing),
          vertical: spacing.xs,
        ),
        onRefresh: refresh,
        onPick: (profile) {
          context.go(Routes.chatPath(profile));
          onNavigate?.call();
        },
      );
    } else if (collapsible) {
      // Beside the chat pane, which already says "No gateway": say it once.
      body = const SizedBox.shrink();
    } else {
      body = EmptyState(
        icon: CupertinoIcons.wifi_slash,
        title: l10n.connStateNotConfigured,
        message: l10n.shellNoGatewayBody,
        action: FilledButton.icon(
          onPressed: () => open(Routes.settings),
          icon: const Icon(CupertinoIcons.gear),
          label: Text(l10n.actionOpenSettings),
        ),
      );
    }

    final buttonInset = _buttonInset(spacing);
    return SidebarFrame(
      width: width,
      elevated: elevated,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          onCollapse: collapsible
              ? () => ref.read(sidebarCollapsedProvider.notifier).set(true)
              : null,
        ),
        Expanded(child: body),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            buttonInset,
            spacing.sm,
            buttonInset,
            spacing.md,
          ),
          child: Row(
            children: [
              AppIconButton(
                icon: CupertinoIcons.gear,
                tooltip: l10n.navSettings,
                onPressed: () => open(Routes.settings),
              ),
              const Spacer(),
              if (configured) ...[
                NewBotButton(onNavigate: onNavigate),
                SizedBox(width: spacing.sm),
              ],
              AppIconButton(
                icon: CupertinoIcons.arrow_clockwise,
                tooltip: l10n.sidebarRefresh,
                onPressed: refresh,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// App mark and the live gateway status; while offline the status is a
/// reconnect button.
class _Header extends ConsumerWidget {
  const _Header({this.onCollapse});

  final VoidCallback? onCollapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final state = ref.watch(connectionStateProvider).value;
    final (kind, label) = switch (state) {
      Connected() => (StatusKind.ok, l10n.connStateConnected),
      Connecting() || null => (StatusKind.busy, l10n.connStateConnecting),
      Reconnecting() => (StatusKind.busy, l10n.connStateReconnecting),
      AuthRequired() => (StatusKind.warn, l10n.connStateAuthRequired),
      Disconnected() => (StatusKind.off, l10n.connStateDisconnected),
    };
    final Widget title = Align(
      alignment: AlignmentDirectional.centerStart,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: spacing.xxs),
          StatusDot(kind: kind, label: label),
        ],
      ),
    );

    // The mark sits on the avatar column and the name where a row's name
    // starts, so header, rows and footer line up.
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        _avatarStart(spacing),
        0,
        _buttonInset(spacing),
        spacing.sm,
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: spacing.avatar,
            child: Center(
              child: Image.asset(
                Assets.logo,
                height: spacing.avatarSm,
                excludeFromSemantics: true,
                errorBuilder: (context, error, stack) => Icon(
                  CupertinoIcons.circle_grid_hex,
                  size: spacing.avatarSm,
                  color: context.colors.accent,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: spacing.minTouch),
              child: state == null || state is Connected
                  ? title
                  : Semantics(
                      button: true,
                      hint: l10n.sidebarReconnect,
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(context.radii.sm),
                          onTap: () => ref
                              .read(connectionSupervisorProvider.notifier)
                              .reconnect(),
                          child: title,
                        ),
                      ),
                    ),
            ),
          ),
          if (onCollapse != null)
            AppIconButton(
              icon: CupertinoIcons.sidebar_left,
              tooltip: l10n.sidebarCollapseMenu,
              onPressed: onCollapse,
            ),
        ],
      ),
    );
  }
}
