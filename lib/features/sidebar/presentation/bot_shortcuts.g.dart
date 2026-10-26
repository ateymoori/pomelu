// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_shortcuts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps the bots the system offers (the app icon's menu, the share sheet's
/// top row) on the sidebar's first ones, each with its picture where the
/// system shows one; picking one opens its chat. Alive for the whole app.

@ProviderFor(botShortcuts)
final botShortcutsProvider = BotShortcutsProvider._();

/// Keeps the bots the system offers (the app icon's menu, the share sheet's
/// top row) on the sidebar's first ones, each with its picture where the
/// system shows one; picking one opens its chat. Alive for the whole app.

final class BotShortcutsProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Keeps the bots the system offers (the app icon's menu, the share sheet's
  /// top row) on the sidebar's first ones, each with its picture where the
  /// system shows one; picking one opens its chat. Alive for the whole app.
  BotShortcutsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'botShortcutsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$botShortcutsHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return botShortcuts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$botShortcutsHash() => r'f2a70e5c15c8373b57cd77320d16eaed27bbc61c';
