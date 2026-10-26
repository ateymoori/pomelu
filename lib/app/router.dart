import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/bot_screen/presentation/bot_screen_page.dart';
import '../features/chat/presentation/chat_shell_screen.dart';
import '../features/settings/presentation/connect_guide_page.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/share/presentation/share_target_screen.dart';
import 'route_observer.dart';
import 'routes.dart';

part 'router.g.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Whether [uri] comes from outside and is no route: a deep link (also as
/// `/?profile=<name>`) or a share's `content://` data. The router never
/// navigates for one: links arrive through `app_links` as a pending share,
/// which the chat shell opens when no page above it holds unsaved work.
bool isExternalLocation(Uri uri) =>
    uri.hasScheme || (uri.path == Routes.home && uri.query.isNotEmpty);

/// The router's `onEnter`: an [isExternalLocation] changes nothing.
OnEnterResult refuseExternal(
  BuildContext context,
  GoRouterState current,
  GoRouterState next,
  GoRouter router,
) => isExternalLocation(next.uri) ? const Block.stop() : const Allow();

/// Opens [location] from a notification tap: replaces a bare chat or home,
/// but is pushed over any page above them, so unsaved work there is kept.
void openFromOutside(GoRouter router, String location) {
  final navigator = rootNavigatorKey.currentState;
  if (navigator != null && navigator.canPop()) {
    unawaited(router.push<void>(location));
  } else {
    router.go(location);
  }
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.home,
    restorationScopeId: 'router',
    onEnter: refuseExternal,
    observers: [appRouteObserver],
    // An unknown in-app path goes home.
    onException: (_, state, router) {
      if (!isExternalLocation(state.uri) ||
          router.routerDelegate.currentConfiguration.isEmpty) {
        router.go(Routes.home);
      }
    },
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const ChatShellScreen(),
      ),
      // A sibling of home: a chat opened at launch is the only page, so
      // back leaves the app instead of showing an empty home first.
      GoRoute(
        path: Routes.chat,
        builder: (context, state) =>
            ChatShellScreen(profile: state.pathParameters[Routes.profileParam]),
      ),
      _fullScreen(Routes.settings, const SettingsScreen()),
      _fullScreen(Routes.connectGuide, const ConnectGuidePage()),
      _fullScreen(Routes.share, const ShareTargetScreen()),
      GoRoute(
        path: Routes.screen,
        pageBuilder: (context, state) => _fullScreenPage(
          state,
          BotScreenPage(profile: state.pathParameters[Routes.profileParam]!),
        ),
      ),
    ],
  );
}

/// A page at [path] that comes up over the chat and closes with a cross,
/// restored after a process death.
GoRoute _fullScreen(String path, Widget page) => GoRoute(
  path: path,
  pageBuilder: (context, state) => _fullScreenPage(state, page),
);

Page<void> _fullScreenPage(GoRouterState state, Widget page) =>
    MaterialPage<void>(
      key: state.pageKey,
      restorationId: state.pageKey.value,
      fullscreenDialog: true,
      child: page,
    );
