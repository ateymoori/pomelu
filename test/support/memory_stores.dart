import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:hermes/core/storage/key_value_store.dart';
import 'package:hermes/core/storage/memory_key_value_store.dart';
import 'package:hermes/core/storage/secret_store.dart';
import 'package:hermes/features/notifications/data/away_store.dart';
import 'package:hermes/features/notifications/data/background_check.dart';

import 'throwing.dart';

export 'package:hermes/core/storage/memory_key_value_store.dart';

/// [SecretStore] in a map.
class MemorySecretStore implements SecretStore {
  /// Everything stored, by key.
  final Map<String, String> values = {};

  /// Thrown by every read, when set: a keystore that will not open.
  Object? readError;

  @override
  Future<String?> read(String key) async {
    final e = readError;
    if (e != null) throwInjected(e);
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// [AwayStore] in fields.
class MemoryAwayStore implements AwayStore {
  DateTime? away;
  String account = '';
  Map<String, ChatMark> saved = {};

  @override
  Future<DateTime?> awaySince() async => away;

  @override
  Future<void> setAwaySince(DateTime? since) async => away = since;

  @override
  Future<Map<String, ChatMark>> marks(String account) async =>
      account == this.account ? {...saved} : {};

  @override
  Future<void> saveMarks(String account, Map<String, ChatMark> marks) async {
    this.account = account;
    saved = {...marks};
  }
}

/// Records what the background check was asked to be.
class FakeCheckScheduler implements BackgroundCheckScheduler {
  bool? wanted;

  @override
  Future<void> sync({required bool wanted}) async => this.wanted = wanted;
}

/// Overrides `keyValueStoreProvider` with a fresh [MemoryKeyValueStore].
///
/// `main.dart` overrides it in the app, and every chat store reads it, so a
/// test that mounts a chat spreads this into its overrides.
List<Override> memoryStoreOverrides([Map<String, Object>? seed]) => [
  keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore(seed)),
];
