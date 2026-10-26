// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the side pane is collapsed to its rail, kept on disk.

@ProviderFor(SidebarCollapsed)
final sidebarCollapsedProvider = SidebarCollapsedProvider._();

/// Whether the side pane is collapsed to its rail, kept on disk.
final class SidebarCollapsedProvider
    extends $NotifierProvider<SidebarCollapsed, bool> {
  /// Whether the side pane is collapsed to its rail, kept on disk.
  SidebarCollapsedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sidebarCollapsedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sidebarCollapsedHash();

  @$internal
  @override
  SidebarCollapsed create() => SidebarCollapsed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$sidebarCollapsedHash() => r'6858a578b96331adc22bb2679ce554419a8f908c';

/// Whether the side pane is collapsed to its rail, kept on disk.

abstract class _$SidebarCollapsed extends $Notifier<bool> {
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
