// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The bots (profiles) on the gateway, refreshed on `sessions.changed` and
/// `gateway.ready`. The first load waits for the socket, but not for ever: a
/// gateway that is down or wants a sign-in ends in an error with Retry.

@ProviderFor(Profiles)
final profilesProvider = ProfilesProvider._();

/// The bots (profiles) on the gateway, refreshed on `sessions.changed` and
/// `gateway.ready`. The first load waits for the socket, but not for ever: a
/// gateway that is down or wants a sign-in ends in an error with Retry.
final class ProfilesProvider
    extends $AsyncNotifierProvider<Profiles, List<HermesProfile>> {
  /// The bots (profiles) on the gateway, refreshed on `sessions.changed` and
  /// `gateway.ready`. The first load waits for the socket, but not for ever: a
  /// gateway that is down or wants a sign-in ends in an error with Retry.
  ProfilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilesHash();

  @$internal
  @override
  Profiles create() => Profiles();
}

String _$profilesHash() => r'197da8179e7b2d55fd5ab6c021bb5c7c53cf5f9e';

/// The bots (profiles) on the gateway, refreshed on `sessions.changed` and
/// `gateway.ready`. The first load waits for the socket, but not for ever: a
/// gateway that is down or wants a sign-in ends in an error with Retry.

abstract class _$Profiles extends $AsyncNotifier<List<HermesProfile>> {
  FutureOr<List<HermesProfile>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<HermesProfile>>, List<HermesProfile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<HermesProfile>>, List<HermesProfile>>,
              AsyncValue<List<HermesProfile>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The name bot [profile] is shown by: its title, else the profile itself
/// (while the roster loads, or for a bot it does not list).

@ProviderFor(botTitle)
final botTitleProvider = BotTitleFamily._();

/// The name bot [profile] is shown by: its title, else the profile itself
/// (while the roster loads, or for a bot it does not list).

final class BotTitleProvider extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The name bot [profile] is shown by: its title, else the profile itself
  /// (while the roster loads, or for a bot it does not list).
  BotTitleProvider._({
    required BotTitleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'botTitleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$botTitleHash();

  @override
  String toString() {
    return r'botTitleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    final argument = this.argument as String;
    return botTitle(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BotTitleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$botTitleHash() => r'd92ad4893a3f037e4ba519ad2d6da9a0eeb45e14';

/// The name bot [profile] is shown by: its title, else the profile itself
/// (while the roster loads, or for a bot it does not list).

final class BotTitleFamily extends $Family
    with $FunctionalFamilyOverride<String, String> {
  BotTitleFamily._()
    : super(
        retry: null,
        name: r'botTitleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The name bot [profile] is shown by: its title, else the profile itself
  /// (while the roster loads, or for a bot it does not list).

  BotTitleProvider call(String profile) =>
      BotTitleProvider._(argument: profile, from: this);

  @override
  String toString() => r'botTitleProvider';
}

/// The bots, sorted for display. Written out, not `whenData`: that drops
/// the error and the bots of a reload, so a retry would blank to a skeleton
/// and a refresh would hide the list.

@ProviderFor(sidebarGroups)
final sidebarGroupsProvider = SidebarGroupsProvider._();

/// The bots, sorted for display. Written out, not `whenData`: that drops
/// the error and the bots of a reload, so a retry would blank to a skeleton
/// and a refresh would hide the list.

final class SidebarGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BotGroup>>,
          AsyncValue<List<BotGroup>>,
          AsyncValue<List<BotGroup>>
        >
    with $Provider<AsyncValue<List<BotGroup>>> {
  /// The bots, sorted for display. Written out, not `whenData`: that drops
  /// the error and the bots of a reload, so a retry would blank to a skeleton
  /// and a refresh would hide the list.
  SidebarGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sidebarGroupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sidebarGroupsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<BotGroup>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<BotGroup>> create(Ref ref) {
    return sidebarGroups(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<BotGroup>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<BotGroup>>>(value),
    );
  }
}

String _$sidebarGroupsHash() => r'76fa810e1ee9ab700733a8e76c3948d914e6e943';

/// A bot's avatar data URL, fetched once per client on its first connection
/// (not on every redial); a failed fetch is tried again on the next one.

@ProviderFor(profileAvatar)
final profileAvatarProvider = ProfileAvatarFamily._();

/// A bot's avatar data URL, fetched once per client on its first connection
/// (not on every redial); a failed fetch is tried again on the next one.

final class ProfileAvatarProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// A bot's avatar data URL, fetched once per client on its first connection
  /// (not on every redial); a failed fetch is tried again on the next one.
  ProfileAvatarProvider._({
    required ProfileAvatarFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileAvatarProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileAvatarHash();

  @override
  String toString() {
    return r'profileAvatarProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return profileAvatar(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileAvatarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileAvatarHash() => r'7c939ecb37cbdbeab1e5ac9f8d450d0cacb85749';

/// A bot's avatar data URL, fetched once per client on its first connection
/// (not on every redial); a failed fetch is tried again on the next one.

final class ProfileAvatarFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  ProfileAvatarFamily._()
    : super(
        retry: null,
        name: r'profileAvatarProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// A bot's avatar data URL, fetched once per client on its first connection
  /// (not on every redial); a failed fetch is tried again on the next one.

  ProfileAvatarProvider call(String name) =>
      ProfileAvatarProvider._(argument: name, from: this);

  @override
  String toString() => r'profileAvatarProvider';
}
