import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted persistence for tokens and passwords.
abstract interface class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureSecretStore implements SecretStore {
  SecureSecretStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage(iOptions: _ios);

  /// Readable once the phone was unlocked after a restart: the background
  /// check for bot messages runs while it is locked. Kept on this device.
  static const IOSOptions _ios = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  /// Writes [keys] again, so items stored under the old "while unlocked"
  /// level take the current one (a read finds them under any level).
  Future<void> rewrite(Iterable<String> keys) async {
    for (final key in keys) {
      final value = await read(key);
      if (value != null) await write(key, value);
    }
  }
}

final secretStoreProvider = Provider<SecretStore>((ref) => SecureSecretStore());
