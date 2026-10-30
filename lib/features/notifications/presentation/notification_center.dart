import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/router.dart';
import '../../../app/routes.dart';
import '../../../core/config/app_config.dart';
import '../../../core/platform/app_visibility.dart';
import '../../../core/platform/push_bridge.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../hermes/client/connection_state.dart';
import '../../../hermes/hermes_failure.dart';
import '../../connection/domain/gateway_config.dart';
import '../../connection/presentation/connection_providers.dart';
import '../../sidebar/presentation/sidebar_providers.dart';
import '../data/message_check.dart';
import '../domain/app_notification.dart';
import '../domain/notification_policy.dart';
import 'active_view_provider.dart';
import 'background_redial_guard.dart';
import 'notification_providers.dart';
import 'push_registration.dart';

part 'notification_center.g.dart';

/// The same gateway account: the same address and user name.
bool sameAccount(GatewayConfig? a, GatewayConfig? b) =>
    (a == null) == (b == null) &&
    a?.normalizedUrl == b?.normalizedUrl &&
    a?.username == b?.username;

/// Gateway signals to system notifications, taps to the router, the
/// "Stay connected" switch to the foreground service, and the bots' messages
/// while the app is away (on `sessions.changed`, and from the background
/// check). Watched once from the app root.
@Riverpod(keepAlive: true)
class NotificationCenter extends _$NotificationCenter {
  @override
  void build() {
    final signals = ref.watch(sessionSignalsProvider);
    final gateway = ref.watch(notificationGatewayProvider);
    final requests = ref.watch(serverRequestRouterProvider);

    /// Posts what the policy makes of a signal, with the grant as it stands.
    Future<void> post(
      AppNotification? Function(NotificationPolicy, ActiveView) make,
    ) async {
      final policy = await _policy();
      if (!ref.mounted) return;
      final n = make(policy, ref.read(activeViewProvider));
      if (n != null) await ref.read(notificationGatewayProvider).show(n);
    }

    Timer? check;

    /// Only while away: on screen, the chat itself shows what came. With
    /// push the phone's push service shows it, unless the socket stays open
    /// (Android's Stay connected), which the push side then leaves to it.
    void checkSoon() {
      if (appIsVisible || !_appPostsMessages) return;
      check?.cancel();
      check = Timer(
        AppConfig.messageCheckDelay,
        () => unawaited(_checkMessages()),
      );
    }

    final subs = <StreamSubscription<Object?>>[
      signals.notices.listen(
        (n) => unawaited(
          post(
            (p, v) => p.forNotice(n, view: v, ref: signals.refFor(n.sessionId)),
          ),
        ),
      ),
      signals.backgrounds.listen(
        (b) => unawaited(
          post(
            (p, v) =>
                p.forBackground(b, view: v, ref: signals.refFor(b.sessionId)),
          ),
        ),
      ),
      signals.noticeClears.listen((key) => unawaited(gateway.cancel(key))),
      signals.storeChanges.listen((_) => checkSoon()),
      gateway.taps.listen(_openRoute),
      ref
          .read(pushBridgeProvider)
          .taps
          .listen((bot) => _openRoute(Routes.chatPath(bot))),
      // A question rings once on arrival (a replay is the same question) and
      // is retracted once answered or withdrawn.
      if (requests != null) ...[
        requests.arrivals.listen(
          (r) => unawaited(
            post(
              (p, v) =>
                  p.forRequest(r, view: v, ref: signals.refFor(r.sessionId)),
            ),
          ),
        ),
        requests.closed.listen(
          (id) => unawaited(gateway.cancel(NotificationPolicy.requestTag(id))),
        ),
      ],
    ];

    ref.listen(keepConnectionAliveSettingProvider, (_, _) => _syncSoon());
    ref.listen(notificationsEnabledSettingProvider, (_, _) => _syncSoon());
    // The chat on screen is read: its message row goes.
    ref.listen(activeViewProvider, (_, view) {
      if (view.isForeground && view.profile.isNotEmpty) {
        unawaited(gateway.cancel(NotificationPolicy.messageTag(view.profile)));
      }
    }, fireImmediately: true);
    // The shade belongs to the account: another gateway, another user or a
    // sign-out clears it.
    ref.listen(gatewayConfigProvider, (previous, next) {
      if (!sameAccount(previous, next)) unawaited(gateway.cancelAll());
      _syncSoon();
    });
    ref.listen(credentialProvider, (previous, next) {
      if (!(previous?.isEmpty ?? true) && next.isEmpty) {
        unawaited(gateway.cancelAll());
      }
      _syncSoon();
    });
    ref.listen(backgroundRedialGuardProvider, (_, _) {});
    ref.listen(pushRegistrationProvider, (_, _) => _syncSoon());
    // Also keeps the grant warm for the first notification.
    ref.listen(notificationPermissionProvider, (_, _) => _syncSoon());
    // The first live connection is when to ask for the permission: the app
    // has just shown it is useful.
    ref.listen(connectionStateProvider, (_, next) {
      if (next.value is! Connected) return;
      unawaited(_promptOnce());
      // What the bots wrote while the socket was down.
      checkSoon();
    }, fireImmediately: true);

    final lifecycle = AppLifecycleListener(
      onHide: () => unawaited(_leave()),
      onResume: () => unawaited(_onResume()),
    );
    unawaited(_start());
    ref.onDispose(() {
      check?.cancel();
      lifecycle.dispose();
      for (final s in subs) {
        unawaited(s.cancel());
      }
    });
  }

  void _syncSoon() {
    unawaited(_syncService());
    unawaited(_syncCheck());
  }

  Future<NotificationPolicy> _policy() async => NotificationPolicy(
    enabled: ref.read(notificationsEnabledSettingProvider),
    permissionGranted: await _permissionGranted(),
    l10n: platformL10n(),
  );

  Future<void> _start() async {
    // A launch in the background (a notification action) is still away.
    if (appIsVisible) unawaited(ref.read(awayStoreProvider).setAwaySince(null));
    final gateway = ref.read(notificationGatewayProvider);
    await gateway.initialize();
    // A tap that cold-started the app came before any listener.
    final route = await gateway.launchRoute();
    if (!ref.mounted) return;
    if (route != null) _openRoute(route);
    final bot = await ref.read(pushBridgeProvider).launchBot();
    if (!ref.mounted) return;
    if (bot != null) _openRoute(Routes.chatPath(bot));
    await _syncService();
    await _syncCheck();
  }

  /// The system may have ended the service while the app was away, and the
  /// background check may have renewed the credential.
  Future<void> _onResume() async {
    await ref.read(awayStoreProvider).setAwaySince(null);
    if (!ref.mounted) return;
    await ref.read(credentialProvider.notifier).reload();
    if (!ref.mounted) return;
    await ref.read(connectionServiceControllerProvider).resync();
    if (ref.mounted) await _syncService();
  }

  /// The app leaves the screen: what it has seen of each chat is the mark
  /// the message check counts from.
  Future<void> _leave() async {
    final now = DateTime.now();
    final store = ref.read(awayStoreProvider);
    await store.setAwaySince(now);
    if (!ref.mounted) return;
    final bots = ref.read(profilesProvider).value;
    final config = ref.read(gatewayConfigProvider);
    if (bots == null || config == null) return;
    await store.saveMarks(config.accountKey, marksOf(bots, now));
  }

  /// What the bots wrote while the app was away, read on the open socket.
  Future<void> _checkMessages() async {
    final api = ref.read(hermesApiProvider);
    final config = ref.read(gatewayConfigProvider);
    if (api == null || config == null) return;
    final policy = await _policy();
    if (!ref.mounted) return;
    try {
      await checkMessages(
        api: api,
        store: ref.read(awayStoreProvider),
        gateway: ref.read(notificationGatewayProvider),
        policy: policy,
        account: config.accountKey,
      );
    } on HermesFailure catch (e) {
      log.w('message check failed', error: e);
    }
  }

  /// The background check runs while notifications are on and the app can
  /// sign in on its own, and push does not already bring the messages.
  Future<void> _syncCheck() async {
    if (!ref.mounted) return;
    await ref
        .read(backgroundCheckSchedulerProvider)
        .sync(
          wanted:
              ref.read(notificationsEnabledSettingProvider) &&
              _signedIn &&
              ref.read(pushRegistrationProvider) != PushStatus.active,
        );
  }

  /// The app posts the bots' messages itself: without push, or while
  /// Android's Stay connected holds the socket (the push side then stays
  /// quiet, `PushService.kt`), so a message rings once.
  bool get _appPostsMessages =>
      ref.read(pushRegistrationProvider) != PushStatus.active ||
      ref.read(connectionServiceControllerProvider).isRunning;

  /// The system shows its dialog once: spend it on a working app.
  Future<void> _promptOnce() async {
    final permission = ref.read(notificationPermissionProvider.notifier);
    if (permission.wasPrompted()) return;
    if (!ref.read(notificationsEnabledSettingProvider)) return;
    await permission.request();
  }

  Future<bool> _permissionGranted() async {
    try {
      return await ref
          .read(notificationPermissionProvider.notifier)
          .isGranted();
    } on Object catch (e, st) {
      log.w('notification permission unreadable', error: e, stackTrace: st);
      return false;
    }
  }

  /// A tap never drops a page with unsaved work ([openFromOutside]).
  void _openRoute(String route) {
    if (route.isNotEmpty) openFromOutside(ref.read(appRouterProvider), route);
  }

  /// The switch is on and the app is set up.
  bool get _serviceWanted =>
      ref.read(keepConnectionAliveSettingProvider) && _signedIn;

  /// A gateway is set up, signed in if it needs to be.
  bool get _signedIn {
    final config = ref.read(gatewayConfigProvider);
    if (config == null) return false;
    return config.authMode == AuthMode.none ||
        !ref.read(credentialProvider).isEmpty;
  }

  /// The service runs while wanted, whatever the socket does: it exists to
  /// hold the process through a dropped connection, and once stopped it
  /// could not start again from the background. No permission gate: Android
  /// 13+ lists a service without the grant in the Task Manager.
  Future<void> _syncService() async {
    if (!ref.mounted) return;
    final controller = ref.read(connectionServiceControllerProvider);
    if (!controller.isSupported) return;
    if (!_serviceWanted) return controller.stop();
    if (controller.isRunning) return;
    // Android 12+ refuses a start from the background.
    if (!appIsVisible) {
      log.i('foreground service waits for the app to be in front');
      return;
    }
    final l10n = platformL10n();
    await controller.start(
      title: l10n.notificationServiceTitle,
      body: l10n.notificationServiceBody,
    );
  }
}
