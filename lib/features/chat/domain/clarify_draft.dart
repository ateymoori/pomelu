import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../hermes/requests/clarify_question.dart';

/// The answers a person has staged for a clarify request, before they send
/// them. Immutable: every edit returns a new draft.
///
/// This is also where answers take their wire form: a choice or typed text is
/// sent as is, a multi-select answer as a JSON-encoded array in a string (the
/// picked choices in display order, then any typed text as one more item), and
/// an unanswered question as null (skipped).
@immutable
class ClarifyDraft {
  const ClarifyDraft._(this._picked, this._typed);

  /// A draft with nothing staged.
  static const ClarifyDraft empty = ClarifyDraft._({}, {});

  /// A draft that starts from answers the gateway already holds (a reconnect
  /// replay), so a question answered before the drop still shows its answer.
  factory ClarifyDraft.restore(
    List<ClarifyQuestion> questions,
    Map<String, String?> locked,
  ) {
    var draft = empty;
    for (final q in questions) {
      final answer = locked[q.qid];
      if (answer == null || answer.isEmpty) continue;
      draft = draft._withAnswer(q, answer);
    }
    return draft;
  }

  final Map<String, Set<String>> _picked;
  final Map<String, String> _typed;

  /// Whether [choice] is picked for [q].
  bool isPicked(ClarifyQuestion q, String choice) =>
      _picked[q.qid]?.contains(choice) ?? false;

  /// The text typed for [q], either its free-text answer or its "Other".
  String typedFor(ClarifyQuestion q) => _typed[q.qid] ?? '';

  /// [q] with [choice] tapped: a single-select question switches to it (and
  /// drops typed text), a multi-select one toggles it.
  ClarifyDraft tap(ClarifyQuestion q, String choice) {
    final current = _picked[q.qid] ?? const <String>{};
    if (q.multiSelect) {
      final next = {...current};
      if (!next.remove(choice)) next.add(choice);
      return _copy(picked: {..._picked, q.qid: next});
    }
    return _copy(
      picked: {
        ..._picked,
        q.qid: {choice},
      },
      typed: {..._typed}..remove(q.qid),
    );
  }

  /// [q] with [text] typed: a single-select question drops its picked choice
  /// once there is text (an "Other" answer replaces it), a multi-select one
  /// keeps its picks.
  ClarifyDraft type(ClarifyQuestion q, String text) {
    final typed = {..._typed, q.qid: text};
    if (text.trim().isEmpty) typed.remove(q.qid);
    final dropPick = q.hasChoices && !q.multiSelect && text.trim().isNotEmpty;
    return _copy(
      typed: typed,
      picked: dropPick ? ({..._picked}..remove(q.qid)) : _picked,
    );
  }

  /// The wire answer for [q], or null when nothing is staged.
  String? answerFor(ClarifyQuestion q) {
    final typed = typedFor(q).trim();
    if (!q.hasChoices) return typed.isEmpty ? null : typed;
    final picked = _picked[q.qid] ?? const <String>{};
    if (q.multiSelect) {
      final items = [
        for (final c in q.choices!)
          if (picked.contains(c)) c,
        if (typed.isNotEmpty) typed,
      ];
      return items.isEmpty ? null : jsonEncode(items);
    }
    if (picked.isNotEmpty) return picked.first;
    return typed.isEmpty ? null : typed;
  }

  /// Every question's wire answer, null for the unanswered.
  Map<String, String?> answers(List<ClarifyQuestion> questions) => {
    for (final q in questions) q.qid: answerFor(q),
  };

  /// Whether at least one of [questions] has an answer.
  bool hasAnswer(List<ClarifyQuestion> questions) =>
      questions.any((q) => answerFor(q) != null);

  ClarifyDraft _copy({
    Map<String, Set<String>>? picked,
    Map<String, String>? typed,
  }) => ClarifyDraft._(picked ?? _picked, typed ?? _typed);

  ClarifyDraft _withAnswer(ClarifyQuestion q, String answer) {
    if (!q.hasChoices) return type(q, answer);
    final bare = {for (final c in q.choices!) ClarifyQuestion.bareChoice(c): c};
    String? match(String text) => bare[ClarifyQuestion.bareChoice(text)];
    if (!q.multiSelect) {
      final choice = match(answer);
      return choice == null ? type(q, answer) : tap(q, choice);
    }
    final decoded = _decodeList(answer) ?? [answer];
    var draft = this;
    for (final item in decoded) {
      final choice = match(item);
      draft = choice == null ? draft.type(q, item) : draft.tap(q, choice);
    }
    return draft;
  }

  static List<String>? _decodeList(String text) {
    try {
      final decoded = jsonDecode(text);
      return decoded is List ? [for (final e in decoded) '$e'] : null;
    } on FormatException {
      return null;
    }
  }
}
