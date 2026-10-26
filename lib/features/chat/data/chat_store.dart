import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/key_value_store.dart';
import '../../../core/utils/app_logger.dart';
import '../../../hermes/models/local_attachment.dart';
import '../../connection/presentation/connection_providers.dart';
import '../../settings/domain/preference_keys.dart';
import '../domain/outbox.dart';

part 'chat_store.freezed.dart';
part 'chat_store.g.dart';

/// What a composer holds before it is sent.
@freezed
abstract class ComposerDraft with _$ComposerDraft {
  const ComposerDraft._();

  const factory ComposerDraft({
    @Default('') String text,
    @Default(<LocalAttachment>[]) List<LocalAttachment> attachments,
  }) = _ComposerDraft;

  factory ComposerDraft.fromJson(Map<String, dynamic> json) =>
      _$ComposerDraftFromJson(json);

  bool get isEmpty => text.trim().isEmpty && attachments.isEmpty;
}

/// The chat's lists on the phone: the send queue, drafts, hidden rows and the
/// bot opened last. Bots are named per gateway, so every key carries the
/// gateway's identity. Reads and writes never throw: a lost copy is bad, a
/// crashed send is worse.
class ChatStore {
  ChatStore(this._kv, this.gateway);

  final KeyValueStore _kv;

  /// [gatewayIdentity] of the gateway, or empty.
  final String gateway;

  /// The target part of the one key that lists every bot with a queue.
  static const String _allTargets = 'targets';

  String _key(String prefix, String target) =>
      gateway.isEmpty ? '$prefix$target' : '$prefix$gateway|$target';

  Object? _read(String key) {
    final raw = _kv.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } on FormatException catch (e) {
      log.w('unreadable $key dropped', error: e);
      return null;
    }
  }

  Future<void> _write(String key, Object? json) async {
    try {
      await (json == null
          ? _kv.remove(key)
          : _kv.setString(key, jsonEncode(json)));
    } on Object catch (e, st) {
      log.w('$key not saved', error: e, stackTrace: st);
    }
  }

  /// Each row of [json] that decodes; one bad row costs that row only.
  static List<T> _decodeAll<T>(
    List<Object?> json,
    T Function(Map<String, dynamic>) decode,
    String what,
  ) {
    final out = <T>[];
    for (final row in json) {
      try {
        if (row is Map<String, dynamic>) out.add(decode(row));
      } on Object catch (e) {
        log.w('unreadable row of $what skipped', error: e);
      }
    }
    return List.unmodifiable(out);
  }

  /// The queue of [target], oldest first.
  List<OutboxEntry> outbox(String target) {
    final json = _read(_key(PreferenceKeys.chatOutboxPrefix, target));
    return json is List
        ? _decodeAll(json, OutboxEntry.fromJson, 'outbox')
        : const [];
  }

  Future<void> saveOutbox(String target, List<OutboxEntry> entries) async {
    final pending = pendingTargets();
    final next = entries.isEmpty
        ? (pending..remove(target))
        : (pending..add(target));
    await Future.wait([
      _write(
        _key(PreferenceKeys.chatOutboxPrefix, target),
        entries.isEmpty ? null : [for (final e in entries) e.toJson()],
      ),
      _write(
        _key(PreferenceKeys.chatPendingOutboxesPrefix, _allTargets),
        next.isEmpty ? null : next.toList(),
      ),
    ]);
  }

  /// Targets with a queue, so it can go out while their chat is closed.
  Set<String> pendingTargets() {
    final json = _read(
      _key(PreferenceKeys.chatPendingOutboxesPrefix, _allTargets),
    );
    return json is List ? {...json.whereType<String>()} : <String>{};
  }

  ComposerDraft draft(String target) {
    final key = _key(PreferenceKeys.chatDraftPrefix, target);
    final json = _read(key);
    if (json is! Map<String, dynamic>) return const ComposerDraft();
    try {
      return ComposerDraft.fromJson(json);
    } on Object catch (e) {
      log.w('unreadable $key dropped', error: e);
      return const ComposerDraft();
    }
  }

  Future<void> saveDraft(String target, ComposerDraft d) => _write(
    _key(PreferenceKeys.chatDraftPrefix, target),
    d.isEmpty ? null : d.toJson(),
  );

  /// Gateway row ids hidden in [target]. Hiding is view-only.
  Set<int> hidden(String target) {
    final json = _read(_key(PreferenceKeys.chatHiddenPrefix, target));
    return json is List ? {...json.whereType<int>()} : <int>{};
  }

  Future<void> saveHidden(String target, Set<int> ids) => _write(
    _key(PreferenceKeys.chatHiddenPrefix, target),
    ids.isEmpty ? null : (ids.toList()..sort()),
  );

  String get _lastBotKey => gateway.isEmpty
      ? PreferenceKeys.lastProfile
      : '${PreferenceKeys.lastProfile}|$gateway';

  /// The bot opened last, so a cold start opens it again.
  String? lastBot() => _kv.getString(_lastBotKey);

  Future<void> saveLastBot(String profile) =>
      _kv.setString(_lastBotKey, profile);
}

/// The origin of [uri] (host in lower case), so `https://Host:443/` and
/// `https://host` are one gateway. Empty for none.
String gatewayIdentity(Uri? uri) =>
    uri == null ? '' : uri.replace(host: uri.host.toLowerCase()).origin;

/// [gatewayIdentity] of the configured gateway. A change rebuilds the store
/// and every open chat.
@Riverpod(keepAlive: true)
String chatGatewayScope(Ref ref) =>
    ref.watch(gatewayConfigProvider.select((c) => gatewayIdentity(c?.uri)));

@Riverpod(keepAlive: true)
ChatStore chatStore(Ref ref) => ChatStore(
  ref.watch(keyValueStoreProvider),
  ref.watch(chatGatewayScopeProvider),
);
