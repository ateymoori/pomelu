// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// An open Screen page of bot [profile]: its viewer, its stream, Take over
/// and Hand back.
///
/// Control the page holds goes back to the bot when the page closes. While
/// the app is away it is kept [AppConfig.screenAwayHandBack] (a password
/// copied from another app), then handed back. A viewer id belongs to the
/// socket that minted it, so after a reconnect the page watches under a new
/// one, and takes again the control it held under the old.

@ProviderFor(ScreenSession)
final screenSessionProvider = ScreenSessionFamily._();

/// An open Screen page of bot [profile]: its viewer, its stream, Take over
/// and Hand back.
///
/// Control the page holds goes back to the bot when the page closes. While
/// the app is away it is kept [AppConfig.screenAwayHandBack] (a password
/// copied from another app), then handed back. A viewer id belongs to the
/// socket that minted it, so after a reconnect the page watches under a new
/// one, and takes again the control it held under the old.
final class ScreenSessionProvider
    extends $NotifierProvider<ScreenSession, ScreenView> {
  /// An open Screen page of bot [profile]: its viewer, its stream, Take over
  /// and Hand back.
  ///
  /// Control the page holds goes back to the bot when the page closes. While
  /// the app is away it is kept [AppConfig.screenAwayHandBack] (a password
  /// copied from another app), then handed back. A viewer id belongs to the
  /// socket that minted it, so after a reconnect the page watches under a new
  /// one, and takes again the control it held under the old.
  ScreenSessionProvider._({
    required ScreenSessionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'screenSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$screenSessionHash();

  @override
  String toString() {
    return r'screenSessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ScreenSession create() => ScreenSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScreenView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScreenView>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ScreenSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$screenSessionHash() => r'ed23d76c59f4ef1a75dc4c602ab49b9d633b1481';

/// An open Screen page of bot [profile]: its viewer, its stream, Take over
/// and Hand back.
///
/// Control the page holds goes back to the bot when the page closes. While
/// the app is away it is kept [AppConfig.screenAwayHandBack] (a password
/// copied from another app), then handed back. A viewer id belongs to the
/// socket that minted it, so after a reconnect the page watches under a new
/// one, and takes again the control it held under the old.

final class ScreenSessionFamily extends $Family
    with
        $ClassFamilyOverride<
          ScreenSession,
          ScreenView,
          ScreenView,
          ScreenView,
          String
        > {
  ScreenSessionFamily._()
    : super(
        retry: null,
        name: r'screenSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// An open Screen page of bot [profile]: its viewer, its stream, Take over
  /// and Hand back.
  ///
  /// Control the page holds goes back to the bot when the page closes. While
  /// the app is away it is kept [AppConfig.screenAwayHandBack] (a password
  /// copied from another app), then handed back. A viewer id belongs to the
  /// socket that minted it, so after a reconnect the page watches under a new
  /// one, and takes again the control it held under the old.

  ScreenSessionProvider call(String profile) =>
      ScreenSessionProvider._(argument: profile, from: this);

  @override
  String toString() => r'screenSessionProvider';
}

/// An open Screen page of bot [profile]: its viewer, its stream, Take over
/// and Hand back.
///
/// Control the page holds goes back to the bot when the page closes. While
/// the app is away it is kept [AppConfig.screenAwayHandBack] (a password
/// copied from another app), then handed back. A viewer id belongs to the
/// socket that minted it, so after a reconnect the page watches under a new
/// one, and takes again the control it held under the old.

abstract class _$ScreenSession extends $Notifier<ScreenView> {
  late final _$args = ref.$arg as String;
  String get profile => _$args;

  ScreenView build(String profile);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ScreenView, ScreenView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScreenView, ScreenView>,
              ScreenView,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
