// ignore_for_file: prefer_final_locals

import 'package:freezed_annotation/freezed_annotation.dart';

/// Gateway JSON is loose: booleans may arrive as 0/1, numbers as int or
/// double, timestamps as float seconds. These converters normalize.
/// A boolean from `true`, a non-zero number, or `"true"` / `"1"`; anything
/// else is false.
class LooseBool implements JsonConverter<bool, Object?> {
  const LooseBool();

  @override
  bool fromJson(Object? json) => switch (json) {
    bool b => b,
    num n => n != 0,
    String s => s == 'true' || s == '1',
    _ => false,
  };

  @override
  Object? toJson(bool object) => object;
}

/// A number from a number or a numeric string; null otherwise.
class LooseDouble implements JsonConverter<double?, Object?> {
  const LooseDouble();

  @override
  double? fromJson(Object? json) => switch (json) {
    num n => n.toDouble(),
    String s => double.tryParse(s),
    _ => null,
  };

  @override
  Object? toJson(double? object) => object;
}

/// An integer from a number or a numeric string; 0 otherwise.
class LooseInt implements JsonConverter<int, Object?> {
  const LooseInt();

  @override
  int fromJson(Object? json) => const LooseIntOrNull().fromJson(json) ?? 0;

  @override
  Object? toJson(int object) => object;
}

/// [LooseInt], but null when the value is absent or not a number, for
/// fields an emitter omits rather than zeroes.
class LooseIntOrNull implements JsonConverter<int?, Object?> {
  const LooseIntOrNull();

  @override
  int? fromJson(Object? json) => switch (json) {
    int i => i,
    num n => n.isFinite ? n.toInt() : null,
    String s => int.tryParse(s),
    _ => null,
  };

  @override
  Object? toJson(int? object) => object;
}

/// A [Duration] stored as whole milliseconds; null when absent.
class DurationMillis implements JsonConverter<Duration?, Object?> {
  const DurationMillis();

  @override
  Duration? fromJson(Object? json) =>
      switch (const LooseIntOrNull().fromJson(json)) {
        final ms? => Duration(milliseconds: ms),
        null => null,
      };

  @override
  Object? toJson(Duration? object) => object?.inMilliseconds;
}

/// A string from anything: null is empty, other values are stringified.
class LooseString implements JsonConverter<String, Object?> {
  const LooseString();

  @override
  String fromJson(Object? json) => switch (json) {
    null => '',
    String s => s,
    _ => json.toString(),
  };

  @override
  Object? toJson(String object) => object;
}

/// [LooseString], but null stays null: for a field the gateway leaves out.
class LooseStringOrNull implements JsonConverter<String?, Object?> {
  const LooseStringOrNull();

  @override
  String? fromJson(Object? json) => switch (json) {
    null => null,
    String s => s,
    _ => json.toString(),
  };

  @override
  Object? toJson(String? object) => object;
}

/// An object, or null for anything else (a list, a string, a number).
class LooseMap implements JsonConverter<Map<String, dynamic>?, Object?> {
  const LooseMap();

  @override
  Map<String, dynamic>? fromJson(Object? json) =>
      json is Map<String, dynamic> ? json : null;

  @override
  Object? toJson(Map<String, dynamic>? object) => object;
}

/// A list of objects. Entries of any other type are dropped; anything that is
/// not a list is an empty list.
class LooseMapList
    implements JsonConverter<List<Map<String, dynamic>>, Object?> {
  const LooseMapList();

  @override
  List<Map<String, dynamic>> fromJson(Object? json) => json is List
      ? [
          for (final e in json)
            if (e is Map<String, dynamic>) e,
        ]
      : const [];

  @override
  Object? toJson(List<Map<String, dynamic>> object) => object;
}

/// Message content as text: a string as is; a multimodal part list joined by
/// its text parts, with `[image]` for each image part.
class ContentText implements JsonConverter<String, Object?> {
  const ContentText();

  @override
  String fromJson(Object? json) => switch (json) {
    null => '',
    String s => s,
    List<Object?> parts => [
      for (final p in parts)
        if (p is String)
          p
        else if (p is Map && p['text'] is String)
          p['text'] as String
        else if (p is Map && '${p['type']}'.contains('image'))
          '[image]',
    ].join('\n'),
    _ => json.toString(),
  };

  @override
  Object? toJson(String object) => object;
}

/// An ISO 8601 timestamp such as `2026-10-03T06:30:00+02:00`. Null when it is
/// absent or unreadable.
class LooseDateTime implements JsonConverter<DateTime?, Object?> {
  const LooseDateTime();

  @override
  DateTime? fromJson(Object? json) => switch (json) {
    String s => DateTime.tryParse(s),
    num n => dateTimeFromEpochSeconds(n),
    _ => null,
  };

  @override
  Object? toJson(DateTime? object) => object?.toIso8601String();
}

/// A list of strings. Entries of any other type are dropped; anything that is
/// not a list stays null.
class LooseStringList implements JsonConverter<List<String>?, Object?> {
  const LooseStringList();

  @override
  List<String>? fromJson(Object? json) => json is List
      ? [
          for (final e in json)
            if (e is String) e,
        ]
      : null;

  @override
  Object? toJson(List<String>? object) => object;
}

/// The latest instant a [DateTime] holds, in epoch milliseconds.
const int _maxEpochMillis = 8640000000000000;

/// Epoch seconds (float) → DateTime (UTC). Null for a value that is not
/// positive, not finite (NaN, infinity) or beyond what a [DateTime] holds:
/// a bad stamp never throws.
DateTime? dateTimeFromEpochSeconds(Object? v) {
  final d = const LooseDouble().fromJson(v);
  if (d == null || !d.isFinite || d <= 0) return null;
  final millis = d * 1000;
  if (millis > _maxEpochMillis) return null;
  return DateTime.fromMillisecondsSinceEpoch(millis.round(), isUtc: true);
}
