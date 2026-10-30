// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns one open chat: its [ChatState] and what the user can do to it. With
/// no gateway configured it builds in an error state and every method does
/// nothing.

@ProviderFor(ChatController)
final chatControllerProvider = ChatControllerFamily._();

/// Owns one open chat: its [ChatState] and what the user can do to it. With
/// no gateway configured it builds in an error state and every method does
/// nothing.
final class ChatControllerProvider
    extends $NotifierProvider<ChatController, ChatState> {
  /// Owns one open chat: its [ChatState] and what the user can do to it. With
  /// no gateway configured it builds in an error state and every method does
  /// nothing.
  ChatControllerProvider._({
    required ChatControllerFamily super.from,
    required ChatTarget super.argument,
  }) : super(
         retry: null,
         name: r'chatControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatControllerHash();

  @override
  String toString() {
    return r'chatControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatController create() => ChatController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatControllerHash() => r'9b69c8e2fb17945ebef2dda5d52d0d9b339fdfe0';

/// Owns one open chat: its [ChatState] and what the user can do to it. With
/// no gateway configured it builds in an error state and every method does
/// nothing.

final class ChatControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatController,
          ChatState,
          ChatState,
          ChatState,
          ChatTarget
        > {
  ChatControllerFamily._()
    : super(
        retry: null,
        name: r'chatControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Owns one open chat: its [ChatState] and what the user can do to it. With
  /// no gateway configured it builds in an error state and every method does
  /// nothing.

  ChatControllerProvider call(ChatTarget target) =>
      ChatControllerProvider._(argument: target, from: this);

  @override
  String toString() => r'chatControllerProvider';
}

/// Owns one open chat: its [ChatState] and what the user can do to it. With
/// no gateway configured it builds in an error state and every method does
/// nothing.

abstract class _$ChatController extends $Notifier<ChatState> {
  late final _$args = ref.$arg as ChatTarget;
  ChatTarget get target => _$args;

  ChatState build(ChatTarget target);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChatState, ChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatState, ChatState>,
              ChatState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
