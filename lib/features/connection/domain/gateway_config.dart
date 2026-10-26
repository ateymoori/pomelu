import 'package:freezed_annotation/freezed_annotation.dart';

import 'gateway_address.dart';

part 'gateway_config.freezed.dart';

/// How the app authenticates against the gateway.
enum AuthMode { none, basic, token }

/// Persisted connection settings (secrets live in [SecretStore]).
@freezed
abstract class GatewayConfig with _$GatewayConfig {
  const GatewayConfig._();

  const factory GatewayConfig({
    required String url,
    @Default(AuthMode.none) AuthMode authMode,
    @Default('') String username,
  }) = _GatewayConfig;

  /// The gateway's base URL, or null when [url] is not one: http(s) with a
  /// host, and no `user:password@`. Credentials in a URL would be stored and
  /// logged in clear; the sign-in form is the place for them (see
  /// [hasUserInfo]). An address typed without a scheme gets one (see
  /// [withDefaultScheme]).
  Uri? get uri {
    if (url.trim().contains(RegExp(r'\s'))) return null;
    final u = Uri.tryParse(withDefaultScheme(url));
    if (u == null || !u.hasAuthority || u.host.isEmpty) return null;
    if (u.scheme != 'http' && u.scheme != 'https') return null;
    if (u.userInfo.isNotEmpty) return null;
    return u;
  }

  /// [url] carries `user:password@`. It is why [uri] is null for an address
  /// that otherwise parses, so the form can say so instead of "invalid".
  bool get hasUserInfo =>
      Uri.tryParse(withDefaultScheme(url))?.userInfo.isNotEmpty ?? false;

  /// Plain `http://` to a host on the internet: nothing on the way is
  /// encrypted, the password and the token included.
  bool get insecure {
    final u = uri;
    return u != null && sendsInClearOverInternet(u);
  }

  /// The account on this gateway, as a key for what is kept per account.
  String get accountKey => '$normalizedUrl#$username';

  /// Normalized for equality: trimmed, with a scheme, no trailing slash,
  /// lowercase host.
  String get normalizedUrl {
    final u = uri;
    if (u == null) return url.trim();
    final path = u.path.replaceAll(RegExp(r'/+$'), '');
    return u.replace(host: u.host.toLowerCase(), path: path).toString();
  }
}
