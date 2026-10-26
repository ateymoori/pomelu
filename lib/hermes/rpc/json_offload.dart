import 'dart:convert';
import 'dart:isolate';

import '../hermes_constants.dart';

/// Bytes that go into JSON as base64 after [prefix] (`data:<mime>;base64,`),
/// so a large file is encoded off the UI isolate with its frame.
final class Base64Bytes {
  const Base64Bytes(this.bytes, {this.prefix = ''});
  final List<int> bytes;
  final String prefix;

  /// The JSON value.
  String toJson() => '$prefix${base64Encode(bytes)}';
}

/// Whether [params] carry enough [Base64Bytes] to be encoded on another
/// isolate.
bool encodesApart(Map<String, dynamic> params) =>
    params.values.whereType<Base64Bytes>().fold(
      0,
      (n, b) => n + b.bytes.length,
    ) >=
    HermesLimits.offloadJsonBytes;

/// [value] as JSON on a short-lived isolate: tens of megabytes of base64
/// would stall the UI. Top level, so the closure sent carries only [value].
Future<String> encodeJsonApart(Object? value) =>
    Isolate.run(() => jsonEncode(value));

/// [raw] decoded on a short-lived isolate, for a frame too large to decode
/// on the UI isolate.
Future<Object?> decodeJsonApart(String raw) =>
    Isolate.run(() => jsonDecode(raw));
