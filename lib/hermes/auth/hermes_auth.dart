import 'dart:convert';
import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../hermes_constants.dart';
import '../hermes_failure.dart';
import '../models/gateway_status.dart';
import '../models/json_converters.dart';
import '../models/json_parse.dart';
import '../transport/hermes_http.dart';
import 'auth_credential.dart';

part 'hermes_auth.freezed.dart';
part 'hermes_auth.g.dart';

/// A row of `GET /api/auth/providers`.
@freezed
abstract class AuthProvider with _$AuthProvider {
  /// One sign-in option.
  const factory AuthProvider({
    @LooseString() @Default('') String name,
    @JsonKey(name: 'display_name')
    @LooseString()
    @Default('')
    String displayName,
    @JsonKey(name: 'supports_password')
    @LooseBool()
    @Default(false)
    bool supportsPassword,
  }) = _AuthProvider;

  /// Reads one row.
  factory AuthProvider.fromJson(Map<String, dynamic> json) =>
      _$AuthProviderFromJson(json);
}

/// Answer of `POST /auth/native/refresh`.
@freezed
abstract class TokenRefresh with _$TokenRefresh {
  const TokenRefresh._();

  /// A rotated token pair.
  const factory TokenRefresh({
    @JsonKey(name: 'access_token')
    @LooseString()
    @Default('')
    String accessToken,
    @JsonKey(name: 'refresh_token') @LooseStringOrNull() String? refreshToken,
    @LooseStringOrNull() String? provider,
    @JsonKey(name: 'expires_at') @LooseDateTime() DateTime? expiresAt,
  }) = _TokenRefresh;

  /// Reads the answer.
  factory TokenRefresh.fromJson(Map<String, dynamic> json) =>
      _$TokenRefreshFromJson(json);

  @override
  String toString() => 'TokenRefresh(provider: $provider, tokens: ***)';
}

/// Sign-in, renewal and ws tickets for one gateway.
class HermesAuth {
  /// Auth over [_http].
  const HermesAuth(this._http);

  final HermesHttp _http;

  static final RegExp _sessionTokenPattern = RegExp(
    '${HermesProtocol.sessionTokenGlobal}\\s*=\\s*"([^"]+)"',
  );

  String get _origin => gatewayOrigin(_http.baseUrl);

  /// `GET /api/status`: version and whether sign-in is required.
  Future<GatewayStatus> status() async => parseObject(
    await _http.json('GET', HermesPaths.status, auth: false),
    GatewayStatus.fromJson,
    what: 'gateway status',
  );

  /// The sign-in options of a gated gateway.
  Future<List<AuthProvider>> providers() async => parseRows(
    (await _http.json(
      'GET',
      HermesPaths.authProviders,
      auth: false,
    ))['providers'],
    AuthProvider.fromJson,
    what: 'auth provider',
  );

  /// The session token an un-gated gateway embeds in its index page, bound
  /// to this gateway; null when there is none (a gated gateway).
  Future<SessionTokenCredential?> discoverSessionCredential() async {
    final res = await _http.send(
      'GET',
      HermesPaths.root,
      auth: false,
      plain: true,
    );
    final body = res.data;
    final token = body is String
        ? _sessionTokenPattern.firstMatch(body)?.group(1)
        : null;
    if (token == null || token.isEmpty) return null;
    return SessionTokenCredential(token, origin: _origin);
  }

  /// Username and password sign-in; the tokens come back as cookies.
  Future<BearerCredential> passwordLogin({
    required String provider,
    required String username,
    required String password,
  }) async {
    final res = await _http.send(
      'POST',
      HermesPaths.passwordLogin,
      body: {
        'provider': provider,
        'username': username,
        'password': password,
        'next': '',
      },
      auth: false,
    );
    final cookies = <String, String>{};
    for (final raw
        in res.headers[HttpHeaders.setCookieHeader] ?? const <String>[]) {
      try {
        final c = Cookie.fromSetCookieValue(raw);
        var value = c.value;
        if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
          value = value.substring(1, value.length - 1);
        }
        cookies[c.name.replaceFirst(RegExp('^__(Host|Secure)-'), '')] = value;
      } on Object {
        continue;
      }
    }
    final at = cookies[HermesProtocol.sessionAccessCookie];
    if (at == null || at.isEmpty) {
      throw const ProtocolFailure('login succeeded but no session cookie');
    }
    return BearerCredential(
      accessToken: at,
      refreshToken: cookies[HermesProtocol.sessionRefreshCookie],
      provider: cookies[HermesProtocol.sessionProviderCookie] ?? provider,
      expiresAt: expiryFromToken(at),
      username: username,
      origin: _origin,
    );
  }

  /// Rotates the tokens. A 401 or 403 means the refresh token is refused
  /// (sign in again); any other failure says nothing about the credential.
  Future<BearerCredential> refresh(BearerCredential cred) async {
    final rt = cred.refreshToken;
    if (rt == null || rt.isEmpty) {
      throw const UnauthorizedFailure('no refresh token');
    }
    final rotated = parseObject(
      await _http.json(
        'POST',
        HermesPaths.nativeRefresh,
        body: {'refresh_token': rt, 'provider': cred.provider},
        auth: false,
      ),
      TokenRefresh.fromJson,
      what: 'token refresh',
    );
    final at = rotated.accessToken;
    if (at.isEmpty) throw const ProtocolFailure('refresh returned no token');
    return BearerCredential(
      accessToken: at,
      refreshToken: rotated.refreshToken ?? rt,
      provider: rotated.provider ?? cred.provider,
      expiresAt: rotated.expiresAt ?? expiryFromToken(at),
      username: cred.username,
      origin: _origin,
    );
  }

  /// A single-use ticket for one socket upgrade.
  Future<String> mintTicket() async {
    final json = await _http.json('POST', HermesPaths.wsTicket, body: const {});
    final t = json['ticket']?.toString() ?? '';
    if (t.isEmpty) throw const ProtocolFailure('gateway returned no ticket');
    return t;
  }

  /// The `exp` claim of a Hermes token (base64url JSON then an HMAC) or of
  /// a JWT; null when there is none.
  static DateTime? expiryFromToken(String token) {
    final parts = token.split('.');
    for (final c in [if (parts.length >= 2) parts[1], token]) {
      try {
        final text = latin1.decode(
          base64Url.decode(base64Url.normalize(c)),
          allowInvalid: true,
        );
        final m = RegExp(r'"exp"\s*:\s*(\d+)').firstMatch(text);
        final at = dateTimeFromEpochSeconds(int.tryParse(m?.group(1) ?? ''));
        if (at != null) return at;
      } on FormatException {
        continue;
      }
    }
    return null;
  }
}
