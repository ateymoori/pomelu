// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incoming_share_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shares and links. Android's share bridge and iOS's share extension speak
/// one channel; other platforms get links alone.

@ProviderFor(shareIntakeService)
final shareIntakeServiceProvider = ShareIntakeServiceProvider._();

/// Shares and links. Android's share bridge and iOS's share extension speak
/// one channel; other platforms get links alone.

final class ShareIntakeServiceProvider
    extends
        $FunctionalProvider<
          ShareIntakeService,
          ShareIntakeService,
          ShareIntakeService
        >
    with $Provider<ShareIntakeService> {
  /// Shares and links. Android's share bridge and iOS's share extension speak
  /// one channel; other platforms get links alone.
  ShareIntakeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareIntakeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareIntakeServiceHash();

  @$internal
  @override
  $ProviderElement<ShareIntakeService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShareIntakeService create(Ref ref) {
    return shareIntakeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareIntakeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareIntakeService>(value),
    );
  }
}

String _$shareIntakeServiceHash() =>
    r'eb7185a1535ec067761e4fd878d16aff1210ec45';

/// The share waiting for the user to pick a bot. Kept too: a link that only
/// names a bot (it says where to go), and a share whose files were all left
/// out (the picker says why nothing came).

@ProviderFor(PendingShare)
final pendingShareProvider = PendingShareProvider._();

/// The share waiting for the user to pick a bot. Kept too: a link that only
/// names a bot (it says where to go), and a share whose files were all left
/// out (the picker says why nothing came).
final class PendingShareProvider
    extends $NotifierProvider<PendingShare, IncomingShare?> {
  /// The share waiting for the user to pick a bot. Kept too: a link that only
  /// names a bot (it says where to go), and a share whose files were all left
  /// out (the picker says why nothing came).
  PendingShareProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingShareProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingShareHash();

  @$internal
  @override
  PendingShare create() => PendingShare();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IncomingShare? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IncomingShare?>(value),
    );
  }
}

String _$pendingShareHash() => r'da91af8807c5dd076461888ad5d3eff57ec7f094';

/// The share waiting for the user to pick a bot. Kept too: a link that only
/// names a bot (it says where to go), and a share whose files were all left
/// out (the picker says why nothing came).

abstract class _$PendingShare extends $Notifier<IncomingShare?> {
  IncomingShare? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<IncomingShare?, IncomingShare?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IncomingShare?, IncomingShare?>,
              IncomingShare?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
