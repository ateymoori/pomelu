import 'package:freezed_annotation/freezed_annotation.dart';

import '../hermes_constants.dart';
import '../models/json_converters.dart';

part 'clarify_question.freezed.dart';
part 'clarify_question.g.dart';

/// One question of a `clarify` request: single-select, multi-select or, with
/// no [choices], free text.
@freezed
abstract class ClarifyQuestion with _$ClarifyQuestion {
  const ClarifyQuestion._();

  /// One question.
  const factory ClarifyQuestion({
    @LooseString() @Default('') String qid,

    /// Question text. Plain text: the agent may write Markdown-ish prose, but
    /// the options belong in [choices], never in here.
    @LooseString() @Default('') String question,

    @LooseStringList() List<String>? choices,
    @JsonKey(name: 'multi_select')
    @LooseBool()
    @Default(false)
    bool multiSelect,
  }) = _ClarifyQuestion;

  /// Reads one question of the request.
  factory ClarifyQuestion.fromJson(Map<String, dynamic> json) =>
      _$ClarifyQuestionFromJson(json);

  /// The label the gateway appends to the first choice when the agent
  /// recommends it (`tools/clarify_tool.py::mark_recommended`). The client
  /// styles it and never writes it; the gateway strips it from the answer.
  static const String recommendedLabel = '(Recommended)';

  /// [choice] without the recommendation label.
  static String bareChoice(String choice) {
    final text = choice.trimRight();
    return text.endsWith(recommendedLabel)
        ? text.substring(0, text.length - recommendedLabel.length).trimRight()
        : choice;
  }

  /// Whether the gateway marked [choice] as the recommended one.
  static bool isRecommended(String choice) =>
      choice.trimRight().endsWith(recommendedLabel);

  bool get hasChoices => choices != null && choices!.isNotEmpty;

  /// This question with the rules every client applies, or null when it
  /// cannot be shown: blank id or text is dropped; blank or over-long choices
  /// are dropped, and no choice left means free text; multi-select only
  /// counts alongside choices.
  ClarifyQuestion? normalized() {
    final id = qid.trim();
    final text = question.trim();
    if (id.isEmpty || text.isEmpty) return null;
    final options = [
      for (final c in choices ?? const <String>[])
        if (c.trim().isNotEmpty &&
            bareChoice(c).length <= HermesLimits.maxChoiceChars)
          c,
    ];
    return ClarifyQuestion(
      qid: id,
      question: text,
      choices: options.isEmpty ? null : options,
      multiSelect: multiSelect && options.isNotEmpty,
    );
  }
}
