// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_request_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The question the agent is waiting on in the session [runtimeId], or null.
///
/// The router is the source of truth, not the chat state: it parks a question
/// while no chat is open and drops it when it is answered, withdrawn, or no
/// longer listed after a reconnect. Watching this rebuilds only the card.

@ProviderFor(pendingRequest)
final pendingRequestProvider = PendingRequestFamily._();

/// The question the agent is waiting on in the session [runtimeId], or null.
///
/// The router is the source of truth, not the chat state: it parks a question
/// while no chat is open and drops it when it is answered, withdrawn, or no
/// longer listed after a reconnect. Watching this rebuilds only the card.

final class PendingRequestProvider
    extends
        $FunctionalProvider<
          AsyncValue<ServerRequest?>,
          ServerRequest?,
          Stream<ServerRequest?>
        >
    with $FutureModifier<ServerRequest?>, $StreamProvider<ServerRequest?> {
  /// The question the agent is waiting on in the session [runtimeId], or null.
  ///
  /// The router is the source of truth, not the chat state: it parks a question
  /// while no chat is open and drops it when it is answered, withdrawn, or no
  /// longer listed after a reconnect. Watching this rebuilds only the card.
  PendingRequestProvider._({
    required PendingRequestFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pendingRequestProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pendingRequestHash();

  @override
  String toString() {
    return r'pendingRequestProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ServerRequest?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ServerRequest?> create(Ref ref) {
    final argument = this.argument as String;
    return pendingRequest(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PendingRequestProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pendingRequestHash() => r'290eb466a34f78d586bc3b556bca8360fbcb2ce5';

/// The question the agent is waiting on in the session [runtimeId], or null.
///
/// The router is the source of truth, not the chat state: it parks a question
/// while no chat is open and drops it when it is answered, withdrawn, or no
/// longer listed after a reconnect. Watching this rebuilds only the card.

final class PendingRequestFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ServerRequest?>, String> {
  PendingRequestFamily._()
    : super(
        retry: null,
        name: r'pendingRequestProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The question the agent is waiting on in the session [runtimeId], or null.
  ///
  /// The router is the source of truth, not the chat state: it parks a question
  /// while no chat is open and drops it when it is answered, withdrawn, or no
  /// longer listed after a reconnect. Watching this rebuilds only the card.

  PendingRequestProvider call(String runtimeId) =>
      PendingRequestProvider._(argument: runtimeId, from: this);

  @override
  String toString() => r'pendingRequestProvider';
}
