import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/requests/clarify_question.dart';
import '../../../../hermes/requests/server_request.dart';
import '../../domain/clarify_draft.dart';
import 'request_frame.dart';

/// The agent's clarify tool: one to five questions, answered together.
///
/// Single choice reads as radio rows, multi-select as checkbox rows, and every
/// question with choices also takes an "Other" answer; a question without
/// choices is a text field. Nothing is sent until Send, with one exception: a
/// lone single-choice question sends the moment a choice is tapped, because a
/// second tap to confirm one tap would only be friction. Leaving a question
/// empty skips it.
class ClarifyCard extends StatefulWidget {
  const ClarifyCard({
    required this.request,
    required this.onSend,
    required this.onSkip,
    super.key,
  });

  final ClarifyRequest request;

  /// Sends the answers (qid → wire answer, null = skipped). Returns whether
  /// they went out; false re-enables the card.
  final bool Function(Map<String, String?> answers) onSend;

  /// Cancels the whole request. Returns whether it went out.
  final bool Function() onSkip;

  @override
  State<ClarifyCard> createState() => _ClarifyCardState();
}

class _ClarifyCardState extends State<ClarifyCard>
    with RequestAnswerGate<ClarifyCard> {
  late ClarifyDraft _draft = ClarifyDraft.restore(
    widget.request.questions,
    widget.request.lockedAnswers,
  );
  final Map<String, TextEditingController> _fields = {};

  List<ClarifyQuestion> get _questions => widget.request.questions;

  bool get _sendsOnTap =>
      _questions.length == 1 &&
      _questions.first.hasChoices &&
      !_questions.first.multiSelect;

  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  TextEditingController _field(ClarifyQuestion q) => _fields.putIfAbsent(
    q.qid,
    () => TextEditingController(text: _draft.typedFor(q)),
  );

  void _tap(ClarifyQuestion q, String choice) {
    if (busy) return;
    setState(() => _draft = _draft.tap(q, choice));
    // A single-select pick replaces typed text; the field must follow.
    if (!q.multiSelect) _field(q).clear();
    if (_sendsOnTap) _send();
  }

  void _type(ClarifyQuestion q, String text) =>
      setState(() => _draft = _draft.type(q, text));

  void _send() => answerOnce(() => widget.onSend(_draft.answers(_questions)));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    return RequestCard(
      title: l10n.chatClarifyTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, q) in _questions.indexed) ...[
            if (i > 0) SizedBox(height: spacing.lg),
            _question(context, q, i),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => answerOnce(widget.onSkip),
          child: Text(l10n.chatRequestSkip),
        ),
        FilledButton(
          onPressed: busy || !_draft.hasAnswer(_questions) ? null : _send,
          child: Text(l10n.chatRequestSend),
        ),
      ],
    );
  }

  Widget _question(BuildContext context, ClarifyQuestion q, int index) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_questions.length > 1)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.xs),
            child: Text(
              l10n.chatClarifyStep(index + 1, _questions.length),
              style: theme.labelMedium?.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
          ),
        // The agent's own words: laid out from what they say, full width so
        // a right-to-left question sits at the right edge.
        SizedBox(
          width: double.infinity,
          child: Text(
            q.question,
            style: theme.bodyMedium,
            textDirection: directionOf(q.question),
          ),
        ),
        SizedBox(height: spacing.sm),
        if (q.hasChoices)
          for (final choice in q.choices!)
            _ChoiceRow(
              choice: choice,
              multi: q.multiSelect,
              selected: _draft.isPicked(q, choice),
              onTap: busy ? null : () => _tap(q, choice),
            ),
        _answerField(context, q),
      ],
    );
  }

  Widget _answerField(BuildContext context, ClarifyQuestion q) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final free = !q.hasChoices;
    return Padding(
      padding: EdgeInsets.only(top: free ? 0 : spacing.xs),
      child: TextField(
        controller: _field(q),
        enabled: !busy,
        onChanged: (text) => _type(q, text),
        // Free text can run long; "Other" is a short line whose keyboard
        // action moves on or sends.
        keyboardType: free ? TextInputType.multiline : TextInputType.text,
        textInputAction: free
            ? TextInputAction.newline
            : _questions.length == 1
            ? TextInputAction.send
            : TextInputAction.next,
        onSubmitted: free || _questions.length > 1
            ? null
            : (_) {
                if (_draft.hasAnswer(_questions)) _send();
              },
        textCapitalization: TextCapitalization.sentences,
        minLines: 1,
        maxLines: free ? AppConfig.clarifyFreeTextLines : 1,
        decoration: InputDecoration(
          hintText: free ? l10n.chatClarifyHint : l10n.chatClarifyOther,
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.choice,
    required this.multi,
    required this.selected,
    required this.onTap,
  });

  final String choice;
  final bool multi;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final recommended = ClarifyQuestion.isRecommended(choice);
    final text = recommended ? ClarifyQuestion.bareChoice(choice) : choice;
    final mark = multi
        ? (selected
              ? CupertinoIcons.checkmark_square_fill
              : CupertinoIcons.square)
        : (selected
              ? CupertinoIcons.largecircle_fill_circle
              : CupertinoIcons.circle);
    return Semantics(
      // A screen reader hears a radio or a checkbox, not just a tinted row.
      inMutuallyExclusiveGroup: !multi,
      checked: selected,
      child: ListTile(
        selected: selected,
        enabled: onTap != null,
        onTap: onTap,
        leading: Icon(
          mark,
          color: selected ? colors.accent : colors.textTertiary,
        ),
        title: Text.rich(
          TextSpan(
            text: text,
            children: [
              if (recommended)
                TextSpan(
                  text: '  ${context.l10n.chatClarifyRecommended}',
                  style: theme.labelMedium?.copyWith(color: colors.accentText),
                ),
            ],
          ),
          style: selected ? theme.titleSmall : theme.bodyMedium,
          textDirection: directionOf(text),
        ),
      ),
    );
  }
}
