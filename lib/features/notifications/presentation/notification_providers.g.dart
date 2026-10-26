// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// System notifications on Android and iOS, silence elsewhere.

@ProviderFor(notificationGateway)
final notificationGatewayProvider = NotificationGatewayProvider._();

/// System notifications on Android and iOS, silence elsewhere.

final class NotificationGatewayProvider
    extends
        $FunctionalProvider<
          NotificationGateway,
          NotificationGateway,
          NotificationGateway
        >
    with $Provider<NotificationGateway> {
  /// System notifications on Android and iOS, silence elsewhere.
  NotificationGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationGatewayHash();

  @$internal
  @override
  $ProviderElement<NotificationGateway> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationGateway create(Ref ref) {
    return notificationGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationGateway>(value),
    );
  }
}

String _$notificationGatewayHash() =>
    r'196e058834e6c04c0ba0249f34f7440a2a6c9ba6';

/// Since when the app is away, and what was notified, shared with the
/// background check.

@ProviderFor(awayStore)
final awayStoreProvider = AwayStoreProvider._();

/// Since when the app is away, and what was notified, shared with the
/// background check.

final class AwayStoreProvider
    extends $FunctionalProvider<AwayStore, AwayStore, AwayStore>
    with $Provider<AwayStore> {
  /// Since when the app is away, and what was notified, shared with the
  /// background check.
  AwayStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'awayStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$awayStoreHash();

  @$internal
  @override
  $ProviderElement<AwayStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AwayStore create(Ref ref) {
    return awayStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AwayStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AwayStore>(value),
    );
  }
}

String _$awayStoreHash() => r'ae1bf895f71e43ff5313bef9e6c020e1f126cc2d';

/// The periodic check for bot messages; a no-op off Android and iOS.

@ProviderFor(backgroundCheckScheduler)
final backgroundCheckSchedulerProvider = BackgroundCheckSchedulerProvider._();

/// The periodic check for bot messages; a no-op off Android and iOS.

final class BackgroundCheckSchedulerProvider
    extends
        $FunctionalProvider<
          BackgroundCheckScheduler,
          BackgroundCheckScheduler,
          BackgroundCheckScheduler
        >
    with $Provider<BackgroundCheckScheduler> {
  /// The periodic check for bot messages; a no-op off Android and iOS.
  BackgroundCheckSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backgroundCheckSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backgroundCheckSchedulerHash();

  @$internal
  @override
  $ProviderElement<BackgroundCheckScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BackgroundCheckScheduler create(Ref ref) {
    return backgroundCheckScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackgroundCheckScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackgroundCheckScheduler>(value),
    );
  }
}

String _$backgroundCheckSchedulerHash() =>
    r'f6111401df87f9b76d0f7806afb771db0bef2ac3';

/// The "stay connected" service; a no-op off Android.

@ProviderFor(connectionServiceController)
final connectionServiceControllerProvider =
    ConnectionServiceControllerProvider._();

/// The "stay connected" service; a no-op off Android.

final class ConnectionServiceControllerProvider
    extends
        $FunctionalProvider<
          ConnectionServiceController,
          ConnectionServiceController,
          ConnectionServiceController
        >
    with $Provider<ConnectionServiceController> {
  /// The "stay connected" service; a no-op off Android.
  ConnectionServiceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionServiceControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionServiceControllerHash();

  @$internal
  @override
  $ProviderElement<ConnectionServiceController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConnectionServiceController create(Ref ref) {
    return connectionServiceController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionServiceController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionServiceController>(value),
    );
  }
}

String _$connectionServiceControllerHash() =>
    r'45038b9bbe58c18bd5db947c35ce23a2da61c71d';

/// The non-transcript gateway events (session refs, notices, background
/// results), once per connection.

@ProviderFor(sessionSignals)
final sessionSignalsProvider = SessionSignalsProvider._();

/// The non-transcript gateway events (session refs, notices, background
/// results), once per connection.

final class SessionSignalsProvider
    extends $FunctionalProvider<SessionSignals, SessionSignals, SessionSignals>
    with $Provider<SessionSignals> {
  /// The non-transcript gateway events (session refs, notices, background
  /// results), once per connection.
  SessionSignalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionSignalsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionSignalsHash();

  @$internal
  @override
  $ProviderElement<SessionSignals> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionSignals create(Ref ref) {
    return sessionSignals(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionSignals value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionSignals>(value),
    );
  }
}

String _$sessionSignalsHash() => r'74871a8a990a2fd737f4380962dde5f569ec3801';

/// "Notify me", on by default: the OS permission is the real gate.

@ProviderFor(NotificationsEnabledSetting)
final notificationsEnabledSettingProvider =
    NotificationsEnabledSettingProvider._();

/// "Notify me", on by default: the OS permission is the real gate.
final class NotificationsEnabledSettingProvider
    extends $NotifierProvider<NotificationsEnabledSetting, bool> {
  /// "Notify me", on by default: the OS permission is the real gate.
  NotificationsEnabledSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsEnabledSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsEnabledSettingHash();

  @$internal
  @override
  NotificationsEnabledSetting create() => NotificationsEnabledSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$notificationsEnabledSettingHash() =>
    r'4233e442a4456273d78837eff1929591b86c3b09';

/// "Notify me", on by default: the OS permission is the real gate.

abstract class _$NotificationsEnabledSetting extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// "Stay connected", on by default: Android cuts a background app off the
/// network within seconds, so without it replies wait until the app is
/// opened again. It costs an ongoing row; the user can turn it off.

@ProviderFor(KeepConnectionAliveSetting)
final keepConnectionAliveSettingProvider =
    KeepConnectionAliveSettingProvider._();

/// "Stay connected", on by default: Android cuts a background app off the
/// network within seconds, so without it replies wait until the app is
/// opened again. It costs an ongoing row; the user can turn it off.
final class KeepConnectionAliveSettingProvider
    extends $NotifierProvider<KeepConnectionAliveSetting, bool> {
  /// "Stay connected", on by default: Android cuts a background app off the
  /// network within seconds, so without it replies wait until the app is
  /// opened again. It costs an ongoing row; the user can turn it off.
  KeepConnectionAliveSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keepConnectionAliveSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keepConnectionAliveSettingHash();

  @$internal
  @override
  KeepConnectionAliveSetting create() => KeepConnectionAliveSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$keepConnectionAliveSettingHash() =>
    r'3db8f0d9a164056bc102e8fa1362af5bddacad14';

/// "Stay connected", on by default: Android cuts a background app off the
/// network within seconds, so without it replies wait until the app is
/// opened again. It costs an ongoing row; the user can turn it off.

abstract class _$KeepConnectionAliveSetting extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether notifications are allowed, read again on every resume: the
/// user can change it in system settings.

@ProviderFor(NotificationPermission)
final notificationPermissionProvider = NotificationPermissionProvider._();

/// Whether notifications are allowed, read again on every resume: the
/// user can change it in system settings.
final class NotificationPermissionProvider
    extends $AsyncNotifierProvider<NotificationPermission, bool> {
  /// Whether notifications are allowed, read again on every resume: the
  /// user can change it in system settings.
  NotificationPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionHash();

  @$internal
  @override
  NotificationPermission create() => NotificationPermission();
}

String _$notificationPermissionHash() =>
    r'100430d14d2d9d2a47533da5a0f0406199eba705';

/// Whether notifications are allowed, read again on every resume: the
/// user can change it in system settings.

abstract class _$NotificationPermission extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
