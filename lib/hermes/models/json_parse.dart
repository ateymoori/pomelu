import '../hermes_failure.dart';
import '../hermes_log.dart';

/// Reads one JSON object into a model.
///
/// A value that is no object, or that the model cannot take (a missing or
/// mistyped field the model needs), is a [ProtocolFailure]: a malformed
/// answer never escapes the SDK as a `TypeError`.
T parseObject<T>(
  Object? raw,
  T Function(Map<String, dynamic> json) fromJson, {
  String what = 'answer',
}) {
  if (raw is! Map<String, dynamic>) {
    throw ProtocolFailure(
      'expected a JSON object for $what, got ${raw.runtimeType}',
      cause: raw,
    );
  }
  try {
    return fromJson(raw);
  } on HermesFailure {
    rethrow;
  } on Object catch (e) {
    throw ProtocolFailure('malformed $what', cause: e);
  }
}

/// Reads a JSON list into models, row by row.
///
/// A row that is no object, or that the model cannot take, is skipped and
/// reported to [log]; the rest of the list still loads. [keep] drops rows
/// that parse but are of no use (a bot without a name). Anything that is not
/// a list is an empty list.
List<T> parseRows<T>(
  Object? raw,
  T Function(Map<String, dynamic> json) fromJson, {
  String what = 'row',
  HermesLog? log,
  bool Function(T row)? keep,
}) {
  if (raw is! List) {
    if (raw != null) {
      log?.call('expected a JSON list of $what, got ${raw.runtimeType}');
    }
    return const [];
  }
  final out = <T>[];
  for (final entry in raw) {
    if (entry is! Map<String, dynamic>) {
      log?.call('skipped a $what that is not an object', entry.runtimeType);
      continue;
    }
    try {
      final row = fromJson(entry);
      if (keep == null || keep(row)) out.add(row);
    } on Object catch (e) {
      log?.call('skipped a malformed $what', e);
    }
  }
  return out;
}
