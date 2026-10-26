// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_screen_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The screen of bot [profile] as its gateway last said; null when there is
/// none (an older Hermes). Starts and stops, and control changing hands,
/// arrive as events (every gateway client sees them); a reconnect reads it
/// again, as the gateway may have restarted (which stops every screen).

@ProviderFor(BotScreen)
final botScreenProvider = BotScreenFamily._();

/// The screen of bot [profile] as its gateway last said; null when there is
/// none (an older Hermes). Starts and stops, and control changing hands,
/// arrive as events (every gateway client sees them); a reconnect reads it
/// again, as the gateway may have restarted (which stops every screen).
final class BotScreenProvider
    extends $AsyncNotifierProvider<BotScreen, ScreenStatus?> {
  /// The screen of bot [profile] as its gateway last said; null when there is
  /// none (an older Hermes). Starts and stops, and control changing hands,
  /// arrive as events (every gateway client sees them); a reconnect reads it
  /// again, as the gateway may have restarted (which stops every screen).
  BotScreenProvider._({
    required BotScreenFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'botScreenProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$botScreenHash();

  @override
  String toString() {
    return r'botScreenProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BotScreen create() => BotScreen();

  @override
  bool operator ==(Object other) {
    return other is BotScreenProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$botScreenHash() => r'6d8f81dbed88fa99b58880ea1d89b7caf1049754';

/// The screen of bot [profile] as its gateway last said; null when there is
/// none (an older Hermes). Starts and stops, and control changing hands,
/// arrive as events (every gateway client sees them); a reconnect reads it
/// again, as the gateway may have restarted (which stops every screen).

final class BotScreenFamily extends $Family
    with
        $ClassFamilyOverride<
          BotScreen,
          AsyncValue<ScreenStatus?>,
          ScreenStatus?,
          FutureOr<ScreenStatus?>,
          String
        > {
  BotScreenFamily._()
    : super(
        retry: null,
        name: r'botScreenProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The screen of bot [profile] as its gateway last said; null when there is
  /// none (an older Hermes). Starts and stops, and control changing hands,
  /// arrive as events (every gateway client sees them); a reconnect reads it
  /// again, as the gateway may have restarted (which stops every screen).

  BotScreenProvider call(String profile) =>
      BotScreenProvider._(argument: profile, from: this);

  @override
  String toString() => r'botScreenProvider';
}

/// The screen of bot [profile] as its gateway last said; null when there is
/// none (an older Hermes). Starts and stops, and control changing hands,
/// arrive as events (every gateway client sees them); a reconnect reads it
/// again, as the gateway may have restarted (which stops every screen).

abstract class _$BotScreen extends $AsyncNotifier<ScreenStatus?> {
  late final _$args = ref.$arg as String;
  String get profile => _$args;

  FutureOr<ScreenStatus?> build(String profile);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ScreenStatus?>, ScreenStatus?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ScreenStatus?>, ScreenStatus?>,
              AsyncValue<ScreenStatus?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
