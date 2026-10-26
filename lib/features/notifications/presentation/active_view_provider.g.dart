// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_view_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the user looks at, from the router and the app lifecycle alone, so
/// the policy never rings for the chat on screen.

@ProviderFor(ActiveViewNotifier)
final activeViewProvider = ActiveViewNotifierProvider._();

/// What the user looks at, from the router and the app lifecycle alone, so
/// the policy never rings for the chat on screen.
final class ActiveViewNotifierProvider
    extends $NotifierProvider<ActiveViewNotifier, ActiveView> {
  /// What the user looks at, from the router and the app lifecycle alone, so
  /// the policy never rings for the chat on screen.
  ActiveViewNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeViewProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeViewNotifierHash();

  @$internal
  @override
  ActiveViewNotifier create() => ActiveViewNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActiveView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActiveView>(value),
    );
  }
}

String _$activeViewNotifierHash() =>
    r'b4ddc35e7b14c2acd456b32b2ae7dfa586ba75d3';

/// What the user looks at, from the router and the app lifecycle alone, so
/// the policy never rings for the chat on screen.

abstract class _$ActiveViewNotifier extends $Notifier<ActiveView> {
  ActiveView build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ActiveView, ActiveView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ActiveView, ActiveView>,
              ActiveView,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
