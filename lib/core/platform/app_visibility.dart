import 'package:flutter/widgets.dart';

/// Whether the app is on screen now: resumed, or visible but unfocused
/// (`inactive`, a system dialog over it). No state yet (the first frame)
/// counts as on screen. Android 12+ refuses a foreground-service start
/// otherwise, and a notification for the chat on screen is noise.
bool get appIsVisible {
  final state = WidgetsBinding.instance.lifecycleState;
  return state == null ||
      state == AppLifecycleState.resumed ||
      state == AppLifecycleState.inactive;
}
