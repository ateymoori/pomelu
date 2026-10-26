// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composer_draft.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The draft of one chat's composer, kept on the phone while it is written.
/// The words live in the composer's text field and come here to be saved;
/// the files live here.

@ProviderFor(ComposerDraftController)
final composerDraftControllerProvider = ComposerDraftControllerFamily._();

/// The draft of one chat's composer, kept on the phone while it is written.
/// The words live in the composer's text field and come here to be saved;
/// the files live here.
final class ComposerDraftControllerProvider
    extends $NotifierProvider<ComposerDraftController, ComposerFiles> {
  /// The draft of one chat's composer, kept on the phone while it is written.
  /// The words live in the composer's text field and come here to be saved;
  /// the files live here.
  ComposerDraftControllerProvider._({
    required ComposerDraftControllerFamily super.from,
    required ChatTarget super.argument,
  }) : super(
         retry: null,
         name: r'composerDraftControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$composerDraftControllerHash();

  @override
  String toString() {
    return r'composerDraftControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ComposerDraftController create() => ComposerDraftController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ComposerFiles value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ComposerFiles>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ComposerDraftControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$composerDraftControllerHash() =>
    r'5e74589bcd0e42a52cf5143bededdab2877c5428';

/// The draft of one chat's composer, kept on the phone while it is written.
/// The words live in the composer's text field and come here to be saved;
/// the files live here.

final class ComposerDraftControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ComposerDraftController,
          ComposerFiles,
          ComposerFiles,
          ComposerFiles,
          ChatTarget
        > {
  ComposerDraftControllerFamily._()
    : super(
        retry: null,
        name: r'composerDraftControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The draft of one chat's composer, kept on the phone while it is written.
  /// The words live in the composer's text field and come here to be saved;
  /// the files live here.

  ComposerDraftControllerProvider call(ChatTarget target) =>
      ComposerDraftControllerProvider._(argument: target, from: this);

  @override
  String toString() => r'composerDraftControllerProvider';
}

/// The draft of one chat's composer, kept on the phone while it is written.
/// The words live in the composer's text field and come here to be saved;
/// the files live here.

abstract class _$ComposerDraftController extends $Notifier<ComposerFiles> {
  late final _$args = ref.$arg as ChatTarget;
  ChatTarget get target => _$args;

  ComposerFiles build(ChatTarget target);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ComposerFiles, ComposerFiles>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ComposerFiles, ComposerFiles>,
              ComposerFiles,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
