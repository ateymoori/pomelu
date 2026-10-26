import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/app_logger.dart';
import '../../../hermes/client/connection_state.dart';
import '../../../hermes/client/hermes_client.dart';
import '../../../hermes/events/gateway_event.dart';
import '../../../hermes/hermes_failure.dart';
import '../../../hermes/models/bot_screen.dart';
import '../../../hermes/models/json_parse.dart';
import '../../connection/presentation/connection_providers.dart';

part 'bot_screen_providers.g.dart';

/// The screen of bot [profile] as its gateway last said; null when there is
/// none (an older Hermes). Starts and stops, and control changing hands,
/// arrive as events (every gateway client sees them); a reconnect reads it
/// again, as the gateway may have restarted (which stops every screen).
@riverpod
class BotScreen extends _$BotScreen {
  @override
  Future<ScreenStatus?> build(String profile) async {
    final api = ref.watch(hermesApiProvider);
    final client = ref.watch(hermesClientProvider);
    if (api == null || client == null) return null;
    final events = client.events.listen(_onEvent);
    ref.onDispose(() => unawaited(events.cancel()));
    ref.listen(connectionStateProvider, (_, next) {
      // Not while the first read waits for the socket itself.
      if (next.value is Connected && (state.hasValue || state.hasError)) {
        unawaited(refresh());
      }
    });
    await client.whenConnected(
      timeout: AppConfig.rosterConnectTimeout,
      failOnSignIn: true,
    );
    return api.screenStatus(profile);
  }

  /// Reads the screen again; a failure keeps what was shown.
  Future<void> refresh() async {
    final api = ref.read(hermesApiProvider);
    if (api == null) return;
    try {
      final status = await api.screenStatus(profile);
      if (ref.mounted) state = AsyncData(status);
    } on HermesFailure catch (e, st) {
      if (!ref.mounted) return;
      if (state.hasValue) {
        log.w('reading the screen of $profile failed', error: e);
      } else {
        state = AsyncError(e, st);
      }
    }
  }

  /// Starts the screen; answers once it is up.
  Future<void> start() async {
    final api = ref.read(hermesApiProvider);
    if (api == null) throw NetworkFailure.notConnected;
    accept(await api.startScreen(profile));
  }

  /// Takes [status] (an answer or an event) unless its control is older
  /// than the one shown.
  void accept(ScreenStatus status) {
    if (!ref.mounted) return;
    final shown = state.value?.lease;
    state = AsyncData(
      shown != null && status.lease.epoch < shown.epoch
          ? status.copyWith(lease: shown)
          : status,
    );
  }

  /// Takes [lease] unless it is older than the one shown.
  void acceptLease(ScreenLease lease) {
    final shown = state.value;
    if (!ref.mounted || shown == null || lease.epoch < shown.lease.epoch) {
      return;
    }
    state = AsyncData(shown.copyWith(lease: lease));
  }

  void _onEvent(GatewayEvent ev) {
    final shown = state.value;
    if (shown == null ||
        shown.profileKey.isEmpty ||
        ev['profile_key'] != shown.profileKey) {
      return;
    }
    try {
      switch (ev.type) {
        case EventNames.displayStatus:
          accept(parseObject(ev.payload, ScreenStatus.fromJson));
        case EventNames.displayLease:
          acceptLease(parseObject(ev['lease'], ScreenLease.fromJson));
      }
    } on ProtocolFailure catch (e) {
      log.w('a malformed ${ev.type} event', error: e);
    }
  }
}
