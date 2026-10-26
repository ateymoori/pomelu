/// A JSON-RPC error object; a request handler throws one to answer with it.
final class JsonRpcError implements Exception {
  const JsonRpcError({required this.code, required this.message, this.data});
  final int code;
  final String message;
  final Object? data;

  /// The `error` member of a reply.
  Map<String, Object?> toJson() => {
    'code': code,
    'message': message,
    'data': ?data,
  };

  @override
  String toString() => 'JsonRpcError($code, $message)';
}
