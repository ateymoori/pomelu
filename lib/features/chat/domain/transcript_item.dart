import 'dart:ui' show TextDirection;

import 'package:flutter/foundation.dart' show listEquals;

import 'chat_message.dart';

/// One list row: a whole message, or one piece of a long reply. A reply in
/// pieces draws its head (reasoning, tools) on the first row and its tail
/// (media, caret, clock, error) on the last.
class TranscriptItem {
  const TranscriptItem(
    this.message, {
    this.part = 0,
    this.parts = 1,
    this.text,
    this.gap = false,
    this.direction,
  });

  final ChatMessage message;
  final int part;
  final int parts;

  /// The Markdown of this piece; null for the whole message.
  final String? text;

  /// A blank line stood before the piece; the row paints it.
  final bool gap;

  /// The whole reply's direction: an all-English piece of a Persian answer
  /// still reads from the right.
  final TextDirection? direction;

  /// Stable while the reply streams.
  String get key => parts == 1 ? message.id : '${message.id}#$part';
  bool get isFirst => part == 0;
  bool get isLast => part == parts - 1;

  /// Whether the row built for [other] paints the same. A piece compares only
  /// what its place draws: a streamed token must not rebuild the pieces it
  /// did not touch.
  bool paintsSameAs(TranscriptItem other) {
    if (parts == 1 || other.parts == 1) {
      return parts == other.parts && message == other.message;
    }
    final a = message;
    final b = other.message;
    return part == other.part &&
        parts == other.parts &&
        text == other.text &&
        gap == other.gap &&
        direction == other.direction &&
        a.interim == b.interim &&
        (!isFirst ||
            (a.visibleReasoning == b.visibleReasoning &&
                listEquals(a.tools, b.tools))) &&
        (!isLast ||
            (a.streaming == b.streaming &&
                a.timestamp == b.timestamp &&
                a.error == b.error &&
                listEquals(a.media, b.media)));
  }
}

/// Midnight of the local day [time] falls on: a message at 01:00 CEST
/// belongs to that day for the reader, whatever UTC calls it.
DateTime dayOf(DateTime time) {
  final local = time.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// The messages that open a new day, by id. Per snapshot, not per row: it
/// depends on the message before. A message with no time is skipped.
Map<String, DateTime> dayBreaks(List<ChatMessage> messages) {
  final breaks = <String, DateTime>{};
  DateTime? current;
  for (final m in messages) {
    final time = m.timestamp;
    if (time == null) continue;
    final day = dayOf(time);
    if (day != current) breaks[m.id] = current = day;
  }
  return breaks;
}
