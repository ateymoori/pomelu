import '../../../core/storage/key_value_store.dart';
import '../../settings/domain/preference_keys.dart';
import '../domain/gateway_config.dart';

/// The stored gateway settings in [kv]; null when none are set. Also read
/// by the background check, which has no providers.
GatewayConfig? readGatewayConfig(KeyValueStore kv) {
  final url = kv.getString(PreferenceKeys.gatewayUrl);
  if (url == null || url.isEmpty) return null;
  final mode = kv.getString(PreferenceKeys.gatewayAuthMode);
  return GatewayConfig(
    url: url,
    authMode: AuthMode.values.firstWhere(
      (m) => m.name == mode,
      orElse: () => AuthMode.none,
    ),
    username: kv.getString(PreferenceKeys.gatewayUsername) ?? '',
  );
}
