import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/platform/app_visibility.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../hermes/client/connection_state.dart';
import '../../../hermes/client/hermes_client.dart';
import '../../connection/presentation/connection_providers.dart';
import '../domain/background_redial_budget.dart';
import 'notification_providers.dart';

part 'background_redial_guard.g.dart';

/// Runs the [BackgroundRedialBudget] while "Stay connected" is on (without
/// it Android suspends the process and nothing redials). True while the
/// redialling is stopped.
@Riverpod(keepAlive: true)
class BackgroundRedialGuard extends _$BackgroundRedialGuard {
  @override
  bool build() {
    final client = ref.watch(hermesClientProvider);
    final keepAlive = ref.watch(keepConnectionAliveSettingProvider);
    if (client == null || !keepAlive) return false;

    final budget = BackgroundRedialBudget(
      budget: AppConfig.backgroundRedialBudget,
      park: () => _park(client),
      wake: () => _wake(client),
    );
    void onState(HermesConnectionState s) =>
        budget.connection(unreachable: s is! Connected && s is! AuthRequired);
    final states = client.states.listen(onState);
    final net = ref.read(connectivityChangesProvider).listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        budget.networkChanged();
      }
    }, onError: (Object e) => log.w('connectivity stream failed', error: e));
    final lifecycle = AppLifecycleListener(
      onShow: () => budget.foreground(visible: true),
      onHide: () => budget.foreground(visible: false),
    );
    budget.foreground(visible: appIsVisible);
    onState(client.state);

    ref.onDispose(() {
      lifecycle.dispose();
      unawaited(states.cancel());
      unawaited(net.cancel());
      // The switch went off or the gateway changed: a client in use keeps
      // its redialling.
      if (budget.parked) unawaited(client.connect());
      budget.dispose();
    });
    return false;
  }

  Future<void> _park(HermesClient client) async {
    log.i('gateway unreachable in the background: redialling stops');
    if (ref.mounted) state = true;
    await client.disconnect();
    await _say(platformL10n().notificationServiceParkedBody);
  }

  Future<void> _wake(HermesClient client) async {
    if (ref.mounted) state = false;
    await _say(platformL10n().notificationServiceBody);
    try {
      await client.connect();
    } on Object catch (e, st) {
      log.w('redial after a pause failed', error: e, stackTrace: st);
    }
  }

  Future<void> _say(String body) => ref
      .read(connectionServiceControllerProvider)
      .update(title: platformL10n().notificationServiceTitle, body: body);
}
