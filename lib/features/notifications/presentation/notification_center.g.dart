// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_center.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Gateway signals to system notifications, taps to the router, the
/// "Stay connected" switch to the foreground service, and the bots' messages
/// while the app is away (on `sessions.changed`, and from the background
/// check). Watched once from the app root.

@ProviderFor(NotificationCenter)
final notificationCenterProvider = NotificationCenterProvider._();

/// Gateway signals to system notifications, taps to the router, the
/// "Stay connected" switch to the foreground service, and the bots' messages
/// while the app is away (on `sessions.changed`, and from the background
/// check). Watched once from the app root.
final class NotificationCenterProvider
    extends $NotifierProvider<NotificationCenter, void> {
  /// Gateway signals to system notifications, taps to the router, the
  /// "Stay connected" switch to the foreground service, and the bots' messages
  /// while the app is away (on `sessions.changed`, and from the background
  /// check). Watched once from the app root.
  NotificationCenterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationCenterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationCenterHash();

  @$internal
  @override
  NotificationCenter create() => NotificationCenter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$notificationCenterHash() =>
    r'0a23ea17de09d3e4633d2cc3550da3e56fdd7c06';

/// Gateway signals to system notifications, taps to the router, the
/// "Stay connected" switch to the foreground service, and the bots' messages
/// while the app is away (on `sessions.changed`, and from the background
/// check). Watched once from the app root.

abstract class _$NotificationCenter extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
