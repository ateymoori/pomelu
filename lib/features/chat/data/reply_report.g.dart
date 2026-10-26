// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_report.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(replyReporter)
final replyReporterProvider = ReplyReporterProvider._();

final class ReplyReporterProvider
    extends $FunctionalProvider<ReplyReporter, ReplyReporter, ReplyReporter>
    with $Provider<ReplyReporter> {
  ReplyReporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'replyReporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$replyReporterHash();

  @$internal
  @override
  $ProviderElement<ReplyReporter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReplyReporter create(Ref ref) {
    return replyReporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReplyReporter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReplyReporter>(value),
    );
  }
}

String _$replyReporterHash() => r'30cae5e927bcb02090461eb7b0d0dc8ebcc704c7';
