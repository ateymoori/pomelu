// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_drainer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Delivers the turns of chats that are not open. After a cold start nothing
/// is open: when the app starts and each time the gateway comes back, this
/// builds the chat of every target with work; the chat holds itself while it
/// delivers and lets go once done. Watched by the chat shell.

@ProviderFor(OutboxDrainer)
final outboxDrainerProvider = OutboxDrainerProvider._();

/// Delivers the turns of chats that are not open. After a cold start nothing
/// is open: when the app starts and each time the gateway comes back, this
/// builds the chat of every target with work; the chat holds itself while it
/// delivers and lets go once done. Watched by the chat shell.
final class OutboxDrainerProvider
    extends $NotifierProvider<OutboxDrainer, void> {
  /// Delivers the turns of chats that are not open. After a cold start nothing
  /// is open: when the app starts and each time the gateway comes back, this
  /// builds the chat of every target with work; the chat holds itself while it
  /// delivers and lets go once done. Watched by the chat shell.
  OutboxDrainerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxDrainerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxDrainerHash();

  @$internal
  @override
  OutboxDrainer create() => OutboxDrainer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$outboxDrainerHash() => r'3396443a2d95e07bc922b4b1f73e5bb44f384671';

/// Delivers the turns of chats that are not open. After a cold start nothing
/// is open: when the app starts and each time the gateway comes back, this
/// builds the chat of every target with work; the chat holds itself while it
/// delivers and lets go once done. Watched by the chat shell.

abstract class _$OutboxDrainer extends $Notifier<void> {
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
