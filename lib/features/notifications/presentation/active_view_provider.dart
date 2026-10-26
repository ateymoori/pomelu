import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/router.dart';
import '../../../app/routes.dart';
import '../../../core/platform/app_visibility.dart';
import '../domain/notification_policy.dart';

part 'active_view_provider.g.dart';

/// The view a router location shows: `/chat/<profile>` names a bot.
ActiveView activeViewFromLocation(
  String location, {
  required bool isForeground,
}) {
  // `pathSegments` are decoded already; decoding again would break a bot
  // named `100%`.
  final segments = Uri.parse(location).pathSegments;
  final onChat = segments.length > 1 && segments.first == Routes.chatSegment;
  return ActiveView(
    isForeground: isForeground,
    profile: onChat ? segments[1] : '',
  );
}

/// What the user looks at, from the router and the app lifecycle alone, so
/// the policy never rings for the chat on screen.
@Riverpod(keepAlive: true)
class ActiveViewNotifier extends _$ActiveViewNotifier {
  bool _resumed = true;

  @override
  ActiveView build() {
    final router = ref.watch(appRouterProvider);
    String location() {
      final config = router.routerDelegate.currentConfiguration;
      return config.isEmpty ? Routes.home : config.uri.toString();
    }

    void onRoute() =>
        state = activeViewFromLocation(location(), isForeground: _resumed);
    final info = router.routeInformationProvider..addListener(onRoute);
    _resumed = appIsVisible;
    final lifecycle = AppLifecycleListener(
      onShow: () => _setResumed(true),
      onHide: () => _setResumed(false),
      onPause: () => _setResumed(false),
      onRestart: () => _setResumed(true),
    );
    ref.onDispose(() {
      info.removeListener(onRoute);
      lifecycle.dispose();
    });
    return activeViewFromLocation(location(), isForeground: _resumed);
  }

  void _setResumed(bool value) {
    if (_resumed == value) return;
    _resumed = value;
    state = ActiveView(isForeground: value, profile: state.profile);
  }
}
