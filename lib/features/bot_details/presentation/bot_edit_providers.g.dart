// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_edit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Renames bot [profile], changes its picture, or deletes it. Each answers
/// true once the gateway has it; a failure stays in the state.

@ProviderFor(BotEdit)
final botEditProvider = BotEditFamily._();

/// Renames bot [profile], changes its picture, or deletes it. Each answers
/// true once the gateway has it; a failure stays in the state.
final class BotEditProvider
    extends $NotifierProvider<BotEdit, AsyncValue<void>> {
  /// Renames bot [profile], changes its picture, or deletes it. Each answers
  /// true once the gateway has it; a failure stays in the state.
  BotEditProvider._({
    required BotEditFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'botEditProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$botEditHash();

  @override
  String toString() {
    return r'botEditProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BotEdit create() => BotEdit();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BotEditProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$botEditHash() => r'944fe6dd6e6f13545673d6b2a6e2cc5ae7bc71be';

/// Renames bot [profile], changes its picture, or deletes it. Each answers
/// true once the gateway has it; a failure stays in the state.

final class BotEditFamily extends $Family
    with
        $ClassFamilyOverride<
          BotEdit,
          AsyncValue<void>,
          AsyncValue<void>,
          AsyncValue<void>,
          String
        > {
  BotEditFamily._()
    : super(
        retry: null,
        name: r'botEditProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Renames bot [profile], changes its picture, or deletes it. Each answers
  /// true once the gateway has it; a failure stays in the state.

  BotEditProvider call(String profile) =>
      BotEditProvider._(argument: profile, from: this);

  @override
  String toString() => r'botEditProvider';
}

/// Renames bot [profile], changes its picture, or deletes it. Each answers
/// true once the gateway has it; a failure stays in the state.

abstract class _$BotEdit extends $Notifier<AsyncValue<void>> {
  late final _$args = ref.$arg as String;
  String get profile => _$args;

  AsyncValue<void> build(String profile);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Creates a bot named [title]: a free profile id from it, and the title as
/// its name when the two differ. The new id once the gateway has it, else
/// null with the failure in the state.

@ProviderFor(BotCreate)
final botCreateProvider = BotCreateProvider._();

/// Creates a bot named [title]: a free profile id from it, and the title as
/// its name when the two differ. The new id once the gateway has it, else
/// null with the failure in the state.
final class BotCreateProvider
    extends $NotifierProvider<BotCreate, AsyncValue<void>> {
  /// Creates a bot named [title]: a free profile id from it, and the title as
  /// its name when the two differ. The new id once the gateway has it, else
  /// null with the failure in the state.
  BotCreateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'botCreateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$botCreateHash();

  @$internal
  @override
  BotCreate create() => BotCreate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$botCreateHash() => r'3acdbb1bc84493b4e4754078ebf3015d55cb68b9';

/// Creates a bot named [title]: a free profile id from it, and the title as
/// its name when the two differ. The new id once the gateway has it, else
/// null with the failure in the state.

abstract class _$BotCreate extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
