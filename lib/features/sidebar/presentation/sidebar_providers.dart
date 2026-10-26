import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/app_logger.dart';
import '../../../hermes/client/hermes_client.dart';
import '../../../hermes/events/gateway_event.dart';
import '../../../hermes/hermes_constants.dart';
import '../../../hermes/hermes_failure.dart';
import '../../../hermes/models/profile.dart';
import '../../connection/presentation/connection_providers.dart';
import '../domain/bot_group.dart';

part 'sidebar_providers.g.dart';

/// The bots (profiles) on the gateway, refreshed on `sessions.changed` and
/// `gateway.ready`. The first load waits for the socket, but not for ever: a
/// gateway that is down or wants a sign-in ends in an error with Retry.
@Riverpod(keepAlive: true)
class Profiles extends _$Profiles {
  Timer? _debounce;

  @override
  Future<List<HermesProfile>> build() async {
    final api = ref.watch(hermesApiProvider);
    final client = ref.watch(hermesClientProvider);
    if (api == null || client == null) return const [];
    final sub = client.events.listen((ev) {
      if (ev.type == EventNames.sessionsChanged ||
          ev.type == EventNames.gatewayReady) {
        _scheduleRefresh();
      }
    });
    ref.onDispose(() {
      _debounce?.cancel();
      unawaited(sub.cancel());
    });
    await client.whenConnected(
      timeout: AppConfig.rosterConnectTimeout,
      failOnSignIn: true,
    );
    return api.listProfiles();
  }

  void _scheduleRefresh() {
    _debounce?.cancel();
    _debounce = Timer(
      AppConfig.sidebarRefreshDebounce,
      () => unawaited(refresh()),
    );
  }

  Future<void> refresh() async {
    final api = ref.read(hermesApiProvider);
    if (api == null) return;
    try {
      final profiles = await api.listProfiles();
      if (ref.mounted) state = AsyncData(profiles);
    } on HermesFailure catch (e, st) {
      log.w('profiles refresh failed', error: e);
      if (!ref.mounted || state.hasValue) return;
      state = AsyncError(e, st);
    }
  }
}

/// The name bot [profile] is shown by: its title, else the profile itself
/// (while the roster loads, or for a bot it does not list).
@riverpod
String botTitle(Ref ref, String profile) =>
    ref.watch(
      profilesProvider.select(
        (bots) =>
            bots.value?.where((b) => b.name == profile).firstOrNull?.title,
      ),
    ) ??
    profile;

/// The bots, sorted for display. Written out, not `whenData`: that drops
/// the error and the bots of a reload, so a retry would blank to a skeleton
/// and a refresh would hide the list.
@riverpod
AsyncValue<List<BotGroup>> sidebarGroups(Ref ref) {
  final profiles = ref.watch(profilesProvider);
  if (profiles.hasError) {
    return AsyncError(profiles.error!, profiles.stackTrace!);
  }
  if (!profiles.hasValue) return const AsyncLoading();
  return AsyncData(
    BotGroup.build(
      profiles: profiles.value!,
      now: DateTime.now().toUtc(),
      workerFreshness: HermesTimeouts.workerFreshness,
    ),
  );
}

/// A bot's avatar data URL, fetched once per client on its first connection
/// (not on every redial); a failed fetch is tried again on the next one.
@Riverpod(keepAlive: true)
Future<String?> profileAvatar(Ref ref, String name) async {
  final api = ref.watch(hermesApiProvider);
  final client = ref.watch(hermesClientProvider);
  if (api == null || client == null) return null;
  try {
    await client.whenConnected();
  } on NetworkFailure {
    return null;
  }
  if (!ref.mounted) return null;
  try {
    return await api.profileAvatar(name);
  } on HermesFailure catch (e) {
    log.w('avatar of $name failed', error: e);
    if (ref.mounted) {
      final retry = client.whenConnected(next: true).then((_) {
        if (ref.mounted) ref.invalidateSelf();
      }, onError: (Object _) {});
      unawaited(retry);
    }
    return null;
  }
}
