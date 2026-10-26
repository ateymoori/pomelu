// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Installed app version, for the About row.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// Installed app version, for the About row.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Installed app version, for the About row.
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'ba3c22ffcbb681a34abb9097ad16cde90c9e2247';

/// Whether the form holds changes Save would write and closing would lose.

@ProviderFor(settingsDirty)
final settingsDirtyProvider = SettingsDirtyProvider._();

/// Whether the form holds changes Save would write and closing would lose.

final class SettingsDirtyProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the form holds changes Save would write and closing would lose.
  SettingsDirtyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsDirtyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsDirtyHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return settingsDirty(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$settingsDirtyHash() => r'1b9395297b8784044eb9655f02f75452acf7c482';

/// Drives the settings form: probe the URL, sign in, test, save.
///
/// Nothing is stored before [saveAndConnect], the password included. After
/// every `await` a result is dropped when the page is gone or the URL
/// changed meanwhile: it answers for another address (a token from host A
/// is never saved for host B). A started save runs to its end.

@ProviderFor(SettingsController)
final settingsControllerProvider = SettingsControllerProvider._();

/// Drives the settings form: probe the URL, sign in, test, save.
///
/// Nothing is stored before [saveAndConnect], the password included. After
/// every `await` a result is dropped when the page is gone or the URL
/// changed meanwhile: it answers for another address (a token from host A
/// is never saved for host B). A started save runs to its end.
final class SettingsControllerProvider
    extends $NotifierProvider<SettingsController, SettingsFormState> {
  /// Drives the settings form: probe the URL, sign in, test, save.
  ///
  /// Nothing is stored before [saveAndConnect], the password included. After
  /// every `await` a result is dropped when the page is gone or the URL
  /// changed meanwhile: it answers for another address (a token from host A
  /// is never saved for host B). A started save runs to its end.
  SettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerHash();

  @$internal
  @override
  SettingsController create() => SettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsFormState>(value),
    );
  }
}

String _$settingsControllerHash() =>
    r'98a466c62a899def2064a80c1ff42548900b8b74';

/// Drives the settings form: probe the URL, sign in, test, save.
///
/// Nothing is stored before [saveAndConnect], the password included. After
/// every `await` a result is dropped when the page is gone or the URL
/// changed meanwhile: it answers for another address (a token from host A
/// is never saved for host B). A started save runs to its end.

abstract class _$SettingsController extends $Notifier<SettingsFormState> {
  SettingsFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SettingsFormState, SettingsFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SettingsFormState, SettingsFormState>,
              SettingsFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
