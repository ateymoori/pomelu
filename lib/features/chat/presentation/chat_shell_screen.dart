import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_observer.dart';
import '../../../app/routes.dart';
import '../../../core/layout/fold_geometry.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/app_logger.dart';
import '../../connection/presentation/connection_providers.dart';
import '../../share/domain/incoming_share.dart';
import '../../share/presentation/incoming_share_provider.dart';
import '../../sidebar/domain/bot_group.dart';
import '../../sidebar/presentation/sidebar_panel.dart';
import '../../sidebar/presentation/sidebar_providers.dart';
import '../../sidebar/presentation/sidebar_state.dart';
import '../../sidebar/presentation/widgets/sidebar_rail.dart';
import '../data/chat_store.dart';
import '../domain/chat_target.dart';
import 'chat_view.dart';
import 'outbox_drainer.dart';
import 'widgets/shell_empty_state.dart';
import 'widgets/shell_shortcuts.dart';

/// Adaptive shell: the sidebar is an elevated drawer on compact layouts and a
/// persistent pane from medium up; the chat fills the rest.
class ChatShellScreen extends ConsumerStatefulWidget {
  const ChatShellScreen({super.key, this.profile});

  /// Bot name from the route, null on `/`.
  final String? profile;

  @override
  ConsumerState<ChatShellScreen> createState() => _ChatShellScreenState();
}

class _ChatShellScreenState extends ConsumerState<ChatShellScreen>
    with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _pickerOpen = false;

  bool _autoNavigated = false;

  GlobalKey? _chatKey;
  String? _chatKeyTarget;

  ModalRoute<dynamic>? _route;

  GlobalKey _chatViewKey(ChatTarget target) {
    if (_chatKeyTarget != target.key || _chatKey == null) {
      _chatKeyTarget = target.key;
      _chatKey = GlobalKey(debugLabel: 'chat:${target.key}');
    }
    return _chatKey!;
  }

  ChatTarget? get _target =>
      widget.profile == null ? null : ChatTarget.bot(widget.profile!);

  @override
  void initState() {
    super.initState();
    _saveLastTarget();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _handleShare(ref.read(pendingShareProvider));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route != _route) {
      appRouteObserver.unsubscribe(this);
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// After the frame: a picker that was backed out of drops its share in a
  /// frame callback of its own, which must run first.
  @override
  void didPopNext() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) _handleShare(ref.read(pendingShareProvider));
  });

  @override
  void didUpdateWidget(ChatShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) _saveLastTarget();
  }

  bool get _isCurrentRoute => ModalRoute.of(context)?.isCurrent ?? true;

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _closeDrawer() => _scaffoldKey.currentState?.closeDrawer();

  void _saveLastTarget() {
    final target = _target;
    if (target == null) return;
    unawaited(ref.read(chatStoreProvider).saveLastBot(target.profile));
  }

  void _autoNavigate(AsyncValue<List<BotGroup>> groups) {
    if (_autoNavigated || widget.profile != null) return;
    if (ref.read(gatewayConfigProvider) == null || !_isCurrentRoute) return;
    final list = groups.value;
    if (list == null || list.isEmpty) return;
    _autoNavigated = true;

    final lastProfile = ref.read(chatStoreProvider).lastBot();
    BotGroup? group;
    for (final candidate in list) {
      if (candidate.name == lastProfile) group = candidate;
      if (group == null && candidate.profile.isDefault) group = candidate;
    }
    group ??= list.first;
    final path = Routes.chatPath(group.name);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(path);
    });
  }

  void _handleShare(IncomingShare? share) {
    if (share == null) return;
    if (share.isEmpty && !share.hasTarget && !share.hasNotice) return;
    if (!mounted || !_isCurrentRoute) return;
    final pending = ref.read(pendingShareProvider.notifier);
    if (share.hasTarget) {
      final roster = ref.read(profilesProvider);
      if (!roster.hasValue && !roster.hasError) return;
      final known = roster.value?.any((p) => p.name == share.profile) ?? false;
      if (known) {
        // The link has chosen: the last-used chat must not take over.
        _autoNavigated = true;
        context.go(pending.routeTo(ChatTarget.bot(share.profile!), share));
        return;
      }
      log.w('deep link names an unknown bot: ${share.profile}');
      if (share.isEmpty) {
        pending.consume();
        return;
      }
    }
    if (_pickerOpen) return;
    _pickerOpen = true;
    // The share has the screen now: the last-used chat must not open under it.
    _autoNavigated = true;
    unawaited(context.push<void>(Routes.share));
    // From the next frame the picker is the current route, which guards
    // ([_isCurrentRoute]). Not reset on the push's future: a picker that
    // leaves with `go` never completes it, and every later share was lost.
    WidgetsBinding.instance.addPostFrameCallback((_) => _pickerOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    // Turns of chats that are not open still go out.
    ref.watch(outboxDrainerProvider);
    ref.listen(pendingShareProvider, (previous, next) => _handleShare(next));
    // A link names a bot: wait for the roster that says whether it exists.
    ref.listen(
      profilesProvider,
      (previous, next) => _handleShare(ref.read(pendingShareProvider)),
    );
    _autoNavigate(ref.watch(sidebarGroupsProvider));

    final target = _target;
    final spacing = context.spacing;
    final window = MediaQuery.sizeOf(context);

    // The side by side layout needs room for the sidebar *and* a usable chat
    // pane: from the window width where both fit, not from a fixed 600 dp,
    // which would leave the chat a 320 dp sliver at 600 to 639.
    final twoPane = window.width >= spacing.sidebarWidth + spacing.chatPaneMin;
    if (!twoPane) {
      // A real drawer (route semantics, the theme's flat shell), never wider
      // than the screen minus one touch target, so the chat stays visible
      // and tappable beside it on the narrowest phone.
      final drawerWidth = math.min(
        spacing.sidebarWidth,
        MediaQuery.sizeOf(context).width - spacing.minTouch,
      );
      return ShellShortcuts(
        profile: widget.profile,
        child: Scaffold(
          key: _scaffoldKey,
          drawerEdgeDragWidth: spacing.minTouch,
          drawer: Drawer(
            width: drawerWidth,
            child: SidebarPanel(
              width: drawerWidth,
              elevated: true,
              selected: target,
              onNavigate: _closeDrawer,
            ),
          ),
          body: target == null
              ? _emptyState(compact: true)
              : ChatView(
                  key: _chatViewKey(target),
                  target: target,
                  onOpenSidebar: _openDrawer,
                ),
        ),
      );
    }

    // Two-pane. The boundary lands on the device fold when that leaves both
    // panes usable, so no single surface straddles the crease.
    final split = PaneSplit.resolve(
      fold: FoldGeometry.of(context),
      // A tablet's window has room for more of each bot's last line.
      preferredLeading: window.width >= spacing.wideWindowMin
          ? spacing.sidebarWidthWide
          : spacing.sidebarWidth,
      railWidth: spacing.railWidth,
      maxLeading: spacing.sidebarPaneMax,
      minTrailing: spacing.chatPaneMin,
      // A short window (a phone on its side) keeps its height for the chat:
      // the sidebar is a rail whatever was chosen.
      collapsed:
          ref.watch(sidebarCollapsedProvider) ||
          window.height < spacing.railMaxHeight,
    );
    return ShellShortcuts(
      profile: widget.profile,
      child: Scaffold(
        body: Row(
          children: [
            if (split.useRail)
              SidebarRail(selected: target)
            else
              SidebarPanel(
                width: split.leadingWidth,
                selected: target,
                collapsible: true,
              ),
            // Dead space over an occluding hinge: nothing is painted here.
            if (split.hingeGap > 0) SizedBox(width: split.hingeGap),
            Expanded(
              child: target == null
                  ? _emptyState(compact: false)
                  : ChatView(key: _chatViewKey(target), target: target),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState({required bool compact}) => ShellEmptyState(
    configured: ref.watch(gatewayConfigProvider) != null,
    onOpenMenu: compact ? _openDrawer : null,
  );
}
