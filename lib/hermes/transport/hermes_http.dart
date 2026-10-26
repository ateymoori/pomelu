import 'dart:io';

import 'package:dio/dio.dart';

import '../auth/auth_credential.dart';
import '../hermes_constants.dart';
import '../hermes_failure.dart';
import '../hermes_log.dart';

/// HTTP client of one gateway: adds the auth headers, maps errors to
/// [HermesFailure], resolves paths under a proxy prefix.
///
/// Credentials go to the gateway's own origin only: no redirect is followed
/// with them, and a credential bound to another gateway is never sent.
class HermesHttp {
  /// A client for [baseUrl]. [onUnauthorized] renews the credential after a
  /// 401 and says whether to retry once; a failure that is no refusal is
  /// thrown, so it does not read as a sign-out. [dio] is for tests.
  HermesHttp({
    required this.baseUrl,
    required this.credential,
    this.onUnauthorized,
    Dio? dio,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: HermesTimeouts.http,
               receiveTimeout: HermesTimeouts.http,
               sendTimeout: HermesTimeouts.http,
               validateStatus: (_) => true,
               followRedirects: false,
             ),
           );

  /// Gateway base URL, possibly with a proxy path prefix.
  final Uri baseUrl;

  /// Read per request, so a rotation applies at once.
  final AuthCredential Function() credential;

  /// See the constructor.
  final Future<bool> Function()? onUnauthorized;

  final Dio _dio;
  bool _closed = false;

  /// [path] under the base URL, prefix kept.
  Uri resolve(String path, [Map<String, String>? query]) {
    final base = baseUrl.path.endsWith('/')
        ? baseUrl
        : baseUrl.replace(path: '${baseUrl.path}/');
    final u = base.resolve(path);
    return query == null || query.isEmpty
        ? u
        : u.replace(queryParameters: {...u.queryParameters, ...query});
  }

  /// [resolve] with a `ws` / `wss` scheme.
  Uri resolveWs(String path, [Map<String, String>? query]) {
    final u = resolve(path, query);
    return u.replace(scheme: u.scheme == 'https' ? 'wss' : 'ws');
  }

  /// Headers for requests made outside this client (players, image caches),
  /// for the gateway's own origin only. Empty when there is no usable
  /// credential.
  Map<String, String> authHeaders() {
    try {
      return _headers();
    } on HermesFailure {
      return const {};
    }
  }

  /// See [credentialFor].
  Map<String, String> _headers() =>
      credentialFor(baseUrl, credential).httpHeaders();

  /// Stops the client; later requests fail with a [NetworkFailure].
  void close() {
    _closed = true;
    _dio.close(force: true);
  }

  /// One request; the answer as it came (cookies are in its headers). An
  /// error status throws. A [body] that is a String goes out as it is (JSON
  /// encoded off the UI isolate). [timeout] replaces the send and receive
  /// timeouts; [headers] go out next to the credential.
  Future<Response<dynamic>> send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
    Object? body,
    bool auth = true,
    Duration? timeout,
    bool plain = false,
  }) async {
    if (_closed) throw const NetworkFailure('http client closed');
    final uri = resolve(path, query);
    Future<Response<dynamic>> attempt() async {
      try {
        return await _dio.requestUri<dynamic>(
          uri,
          data: body,
          options: Options(
            method: method,
            headers: {...?headers, if (auth) ..._headers()},
            contentType: body == null ? null : Headers.jsonContentType,
            sendTimeout: timeout,
            receiveTimeout: timeout,
            responseType: plain ? ResponseType.plain : null,
          ),
        );
      } on DioException catch (e) {
        throw failureForDio(e);
      }
    }

    var res = await attempt();
    if (auth && res.statusCode == HermesHttpStatus.unauthorized) {
      if (await _renew()) res = await attempt();
    }
    final failure = failureForStatus(res.statusCode ?? 0, res.data);
    if (failure != null) throw failure;
    return res;
  }

  /// [send] whose answer is a JSON object (empty for no body).
  Future<Map<String, dynamic>> json(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool auth = true,
    Duration? timeout,
  }) async {
    final res = await send(
      method,
      path,
      query: query,
      body: body,
      auth: auth,
      timeout: timeout,
    );
    final data = _data(res);
    if (data is Map<String, dynamic>) return data;
    if (data == null) return const {};
    throw ProtocolFailure('expected a JSON object', cause: data);
  }

  /// GET whose answer is a JSON array; entries that are no object are left
  /// out.
  Future<List<Map<String, dynamic>>> jsonList(
    String path, {
    Map<String, String>? query,
  }) async {
    final data = _data(await send('GET', path, query: query));
    if (data is List) return [...data.whereType<Map<String, dynamic>>()];
    if (data == null) return const [];
    throw ProtocolFailure('expected a JSON array', cause: data);
  }

  /// The body; a redirect is refused (it would be followed without the
  /// credential, or with it to a host that did not issue it).
  static Object? _data(Response<dynamic> res) {
    final code = res.statusCode ?? 0;
    if (code >= 300) {
      throw ServerFailure('unexpected redirect', httpStatus: code);
    }
    final data = res.data;
    return data is String && data.isEmpty ? null : data;
  }

  /// Streams a GET to [savePath]. Auth headers go to the gateway's own
  /// origin only, where redirects are not followed; a 401 renews and
  /// retries once. A failed download leaves no file.
  Future<void> download(
    Uri uri,
    String savePath, {
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final ours =
        uri.scheme == baseUrl.scheme &&
        uri.host == baseUrl.host &&
        uri.port == baseUrl.port;
    Future<void> attempt() => _dio.downloadUri(
      uri,
      savePath,
      options: Options(
        headers: ours ? _headers() : null,
        receiveTimeout: HermesTimeouts.upload,
        followRedirects: !ours,
        validateStatus: (s) => s != null && s < 300,
      ),
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
    );
    try {
      await attempt();
    } on DioException catch (e) {
      final unauthorized =
          e.response?.statusCode == HermesHttpStatus.unauthorized;
      if (!ours || !unauthorized || !await _renew()) throw failureForDio(e);
      try {
        await attempt();
      } on DioException catch (e) {
        throw failureForDio(e);
      }
    }
  }

  /// [onUnauthorized], with anything that is no [HermesFailure] as one.
  Future<bool> _renew() async {
    final renew = onUnauthorized;
    if (renew == null) return false;
    try {
      return await renew();
    } on HermesFailure {
      rethrow;
    } on Object catch (e) {
      throw UnauthorizedFailure('token renewal failed', cause: e);
    }
  }
}

/// The failure an HTTP status stands for; null below 400.
HermesFailure? failureForStatus(int code, Object? data) {
  if (code < 400) return null;
  if (code == HermesHttpStatus.unauthorized) {
    return UnauthorizedFailure('HTTP $code', cause: data);
  }
  if (code == HermesHttpStatus.forbidden) {
    return ForbiddenFailure('HTTP $code', cause: data);
  }
  var message = 'HTTP $code';
  if (code < 500 && data is Map<String, dynamic>) {
    final m = data['error'] ?? data['message'] ?? data['detail'];
    if (m is String && m.isNotEmpty) message = m;
  }
  return ServerFailure(message, httpStatus: code, data: data);
}

/// The failure a Dio error stands for, with no secret in its message. A
/// timeout after the request went out is an [OutcomeUnknownFailure].
HermesFailure failureForDio(DioException e) {
  if (CancelToken.isCancel(e)) return const CancelledFailure();
  final inner = e.error;
  if (inner is FileSystemException || inner is FormatException) {
    return ProtocolFailure('unreadable or unwritable answer', cause: e);
  }
  final code = e.response?.statusCode;
  if (code != null) {
    final failure = failureForStatus(code, null);
    if (failure != null) return failure;
  }
  final message = redactSecrets(switch (e.type) {
    _ when inner is SocketException => inner.message,
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => 'timeout',
    DioExceptionType.connectionError => 'connection error',
    _ => e.message ?? e.type.name,
  });
  return switch (e.type) {
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => OutcomeUnknownFailure(message, cause: e),
    _ => NetworkFailure(message, cause: e),
  };
}
