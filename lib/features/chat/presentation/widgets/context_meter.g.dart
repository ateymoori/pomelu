// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_meter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live usage of one session, straight off the socket: a tick repaints the
/// meter alone, never the transcript. Null until the first tick.

@ProviderFor(contextUsage)
final contextUsageProvider = ContextUsageFamily._();

/// Live usage of one session, straight off the socket: a tick repaints the
/// meter alone, never the transcript. Null until the first tick.

final class ContextUsageProvider
    extends
        $FunctionalProvider<
          AsyncValue<SessionUsage?>,
          SessionUsage?,
          Stream<SessionUsage?>
        >
    with $FutureModifier<SessionUsage?>, $StreamProvider<SessionUsage?> {
  /// Live usage of one session, straight off the socket: a tick repaints the
  /// meter alone, never the transcript. Null until the first tick.
  ContextUsageProvider._({
    required ContextUsageFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'contextUsageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$contextUsageHash();

  @override
  String toString() {
    return r'contextUsageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<SessionUsage?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SessionUsage?> create(Ref ref) {
    final argument = this.argument as String;
    return contextUsage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ContextUsageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$contextUsageHash() => r'a0f44d443bedd4872fdcb224228269079d17c634';

/// Live usage of one session, straight off the socket: a tick repaints the
/// meter alone, never the transcript. Null until the first tick.

final class ContextUsageFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SessionUsage?>, String> {
  ContextUsageFamily._()
    : super(
        retry: null,
        name: r'contextUsageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live usage of one session, straight off the socket: a tick repaints the
  /// meter alone, never the transcript. Null until the first tick.

  ContextUsageProvider call(String runtimeId) =>
      ContextUsageProvider._(argument: runtimeId, from: this);

  @override
  String toString() => r'contextUsageProvider';
}

/// The window share of a session whose usage carries none: the gateway
/// reports occupancy only once its agent has made a call in this process
/// (not after a resume or a restart), but its breakdown estimates it from
/// the transcript, with no model call. Null when it cannot tell either (no
/// live agent, a model of unknown window).

@ProviderFor(contextEstimate)
final contextEstimateProvider = ContextEstimateFamily._();

/// The window share of a session whose usage carries none: the gateway
/// reports occupancy only once its agent has made a call in this process
/// (not after a resume or a restart), but its breakdown estimates it from
/// the transcript, with no model call. Null when it cannot tell either (no
/// live agent, a model of unknown window).

final class ContextEstimateProvider
    extends $FunctionalProvider<AsyncValue<double?>, double?, FutureOr<double?>>
    with $FutureModifier<double?>, $FutureProvider<double?> {
  /// The window share of a session whose usage carries none: the gateway
  /// reports occupancy only once its agent has made a call in this process
  /// (not after a resume or a restart), but its breakdown estimates it from
  /// the transcript, with no model call. Null when it cannot tell either (no
  /// live agent, a model of unknown window).
  ContextEstimateProvider._({
    required ContextEstimateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'contextEstimateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$contextEstimateHash();

  @override
  String toString() {
    return r'contextEstimateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<double?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double?> create(Ref ref) {
    final argument = this.argument as String;
    return contextEstimate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ContextEstimateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$contextEstimateHash() => r'bd7b3dab86ba8d64681beada6172804a642cce40';

/// The window share of a session whose usage carries none: the gateway
/// reports occupancy only once its agent has made a call in this process
/// (not after a resume or a restart), but its breakdown estimates it from
/// the transcript, with no model call. Null when it cannot tell either (no
/// live agent, a model of unknown window).

final class ContextEstimateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<double?>, String> {
  ContextEstimateFamily._()
    : super(
        retry: null,
        name: r'contextEstimateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The window share of a session whose usage carries none: the gateway
  /// reports occupancy only once its agent has made a call in this process
  /// (not after a resume or a restart), but its breakdown estimates it from
  /// the transcript, with no model call. Null when it cannot tell either (no
  /// live agent, a model of unknown window).

  ContextEstimateProvider call(String runtimeId) =>
      ContextEstimateProvider._(argument: runtimeId, from: this);

  @override
  String toString() => r'contextEstimateProvider';
}

/// What fills the window, asked each time the usage sheet opens.

@ProviderFor(contextBreakdown)
final contextBreakdownProvider = ContextBreakdownFamily._();

/// What fills the window, asked each time the usage sheet opens.

final class ContextBreakdownProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContextBreakdown?>,
          ContextBreakdown?,
          FutureOr<ContextBreakdown?>
        >
    with
        $FutureModifier<ContextBreakdown?>,
        $FutureProvider<ContextBreakdown?> {
  /// What fills the window, asked each time the usage sheet opens.
  ContextBreakdownProvider._({
    required ContextBreakdownFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'contextBreakdownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$contextBreakdownHash();

  @override
  String toString() {
    return r'contextBreakdownProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ContextBreakdown?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ContextBreakdown?> create(Ref ref) {
    final argument = this.argument as String;
    return contextBreakdown(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ContextBreakdownProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$contextBreakdownHash() => r'06ec80057b1f588b94de071ad0e39782e6f1e841';

/// What fills the window, asked each time the usage sheet opens.

final class ContextBreakdownFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ContextBreakdown?>, String> {
  ContextBreakdownFamily._()
    : super(
        retry: null,
        name: r'contextBreakdownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What fills the window, asked each time the usage sheet opens.

  ContextBreakdownProvider call(String runtimeId) =>
      ContextBreakdownProvider._(argument: runtimeId, from: this);

  @override
  String toString() => r'contextBreakdownProvider';
}
