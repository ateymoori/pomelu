import 'key_value_store.dart';

/// [KeyValueStore] in a map: the fallback when the saved preferences cannot
/// be read in time, and the tests' store.
class MemoryKeyValueStore implements KeyValueStore {
  MemoryKeyValueStore([Map<String, Object>? seed]) : values = {...?seed};

  final Map<String, Object> values;

  @override
  String? getString(String key) => values[key] as String?;

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  bool? getBool(String key) => values[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}
