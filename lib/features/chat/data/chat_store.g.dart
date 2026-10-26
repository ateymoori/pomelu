// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ComposerDraft _$ComposerDraftFromJson(Map<String, dynamic> json) =>
    _ComposerDraft(
      text: json['text'] as String? ?? '',
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => LocalAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <LocalAttachment>[],
    );

Map<String, dynamic> _$ComposerDraftToJson(_ComposerDraft instance) =>
    <String, dynamic>{
      'text': instance.text,
      'attachments': instance.attachments,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [gatewayIdentity] of the configured gateway. A change rebuilds the store
/// and every open chat.

@ProviderFor(chatGatewayScope)
final chatGatewayScopeProvider = ChatGatewayScopeProvider._();

/// [gatewayIdentity] of the configured gateway. A change rebuilds the store
/// and every open chat.

final class ChatGatewayScopeProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// [gatewayIdentity] of the configured gateway. A change rebuilds the store
  /// and every open chat.
  ChatGatewayScopeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatGatewayScopeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatGatewayScopeHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return chatGatewayScope(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$chatGatewayScopeHash() => r'6aa6413fd6ca51937adc52d6ff34a1c3413b218f';

@ProviderFor(chatStore)
final chatStoreProvider = ChatStoreProvider._();

final class ChatStoreProvider
    extends $FunctionalProvider<ChatStore, ChatStore, ChatStore>
    with $Provider<ChatStore> {
  ChatStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatStoreHash();

  @$internal
  @override
  $ProviderElement<ChatStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatStore create(Ref ref) {
    return chatStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatStore>(value),
    );
  }
}

String _$chatStoreHash() => r'ff6fe7509c2a48cbf0b4af3ec397b0aa446e9135';
