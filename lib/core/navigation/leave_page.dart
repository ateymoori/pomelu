import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';

/// Leaves a full-screen page: pops it, or goes home when it is the only
/// route.
void leavePage(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(Routes.home);
  }
}

/// Leaves like the system back, so the page's pop guard decides.
Future<void> requestLeavePage(BuildContext context) async {
  final handled = await Navigator.of(context).maybePop();
  if (!handled && context.mounted) context.go(Routes.home);
}
