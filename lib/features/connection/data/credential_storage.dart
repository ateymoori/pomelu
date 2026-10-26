import 'dart:convert';

import '../../../core/storage/secret_store.dart';
import '../../../core/utils/app_logger.dart';
import '../../../hermes/auth/auth_credential.dart';
import '../../settings/domain/preference_keys.dart';

/// The gateway credential and the sign-in password, in the platform secret
/// store. A credential is stored as its own JSON plus a `type` key, which
/// tells the two kinds apart.
class SecureCredentialStorage {
  const SecureCredentialStorage(this._secrets);

  final SecretStore _secrets;

  static const String _type = 'type';
  static const String _sessionToken = 'sessionToken';
  static const String _bearer = 'bearer';

  Future<void> _write(String type, Map<String, dynamic> json) => _secrets.write(
    PreferenceKeys.gatewayToken,
    jsonEncode({_type: type, ...json}),
  );

  /// The saved credential. Never throws: anything unreadable is
  /// [NoCredential], so a bad keystore cannot keep the app on its splash.
  Future<AuthCredential> load() async {
    try {
      final raw = await _secrets.read(PreferenceKeys.gatewayToken);
      if (raw == null || raw.isEmpty) return const NoCredential();
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return switch (j[_type]) {
        _sessionToken => SessionTokenCredential.fromJson(j),
        _bearer => BearerCredential.fromJson(j),
        _ => const NoCredential(),
      };
    } on Object catch (e, st) {
      // Only the type: a FormatException quotes the stored JSON, tokens and
      // all.
      log.w('stored credential unreadable (${e.runtimeType})', stackTrace: st);
      return const NoCredential();
    }
  }

  /// Replaces the saved credential; [NoCredential] deletes it.
  Future<void> save(AuthCredential c) => switch (c) {
    NoCredential() => _secrets.delete(PreferenceKeys.gatewayToken),
    SessionTokenCredential() => _write(_sessionToken, c.toJson()),
    BearerCredential() => _write(_bearer, c.toJson()),
  };

  /// The saved password, for signing in again on its own.
  Future<String?> loadPassword() =>
      _secrets.read(PreferenceKeys.gatewayPassword);

  /// Replaces the saved password; null or empty deletes it.
  Future<void> savePassword(String? password) =>
      password == null || password.isEmpty
      ? _secrets.delete(PreferenceKeys.gatewayPassword)
      : _secrets.write(PreferenceKeys.gatewayPassword, password);
}
