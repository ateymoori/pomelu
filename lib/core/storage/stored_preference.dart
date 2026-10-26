import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'key_value_store.dart';

/// A switch kept in the [KeyValueStore] under [key]: the notifier's `build`
/// returns [load], and [set] changes it on screen at once, then on disk.
mixin StoredFlag on AnyNotifier<bool, bool> {
  String get key;

  /// The value before the user sets one.
  bool get fallback;

  bool load() => ref.read(keyValueStoreProvider).getBool(key) ?? fallback;

  Future<void> set(bool value) async {
    state = value;
    await ref.read(keyValueStoreProvider).setBool(key, value);
  }
}

/// A pick of an enum, kept in the [KeyValueStore] by name under [key]; an
/// unknown name is [fallback]. As [StoredFlag].
mixin StoredChoice<E extends Enum> on AnyNotifier<E, E> {
  String get key;

  /// Every value, to find a stored name in.
  List<E> get choices;

  /// The value before the user picks one.
  E get fallback;

  E load() {
    final name = ref.read(keyValueStoreProvider).getString(key);
    return choices.firstWhere((c) => c.name == name, orElse: () => fallback);
  }

  Future<void> set(E value) async {
    state = value;
    await ref.read(keyValueStoreProvider).setString(key, value.name);
  }
}
