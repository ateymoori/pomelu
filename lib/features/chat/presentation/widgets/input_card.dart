import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/requests/server_request.dart';
import 'request_frame.dart';

/// A sudo password or a named secret. Masked, never suggested, corrected or
/// autofilled; skipping sends an empty value, which the agent reads as
/// declined.
class InputCard extends StatefulWidget {
  const InputCard({required this.request, required this.onSend, super.key});

  final InputRequest request;
  final bool Function(String value) onSend;

  @override
  State<InputCard> createState() => _InputCardState();
}

class _InputCardState extends State<InputCard>
    with RequestAnswerGate<InputCard> {
  final TextEditingController _value = TextEditingController();
  bool _hidden = true;

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  void _send(String value) => answerOnce(() => widget.onSend(value));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final request = widget.request;
    return RequestCard(
      title: switch (request.kind) {
        InputKind.sudo => l10n.chatInputSudoTitle,
        InputKind.secret =>
          request.prompt.isNotEmpty
              ? request.prompt
              : l10n.chatInputSecretTitle,
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (request.subject.isNotEmpty) ...[
            SelectableText(
              request.subject,
              style: context.textScale.mono(
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(height: context.spacing.sm),
          ],
          TextField(
            controller: _value,
            enabled: !busy,
            obscureText: _hidden,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.send,
            onChanged: (_) => setState(() {}),
            onSubmitted: (value) {
              if (value.isNotEmpty) _send(value);
            },
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: l10n.chatInputHint,
              suffixIcon: AppIconButton.plain(
                icon: _hidden ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                tooltip: _hidden ? l10n.chatInputShow : l10n.chatInputHide,
                onPressed: () => setState(() => _hidden = !_hidden),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => _send(''),
          child: Text(l10n.chatRequestSkip),
        ),
        FilledButton(
          onPressed: busy || _value.text.isEmpty
              ? null
              : () => _send(_value.text),
          child: Text(l10n.chatRequestSend),
        ),
      ],
    );
  }
}
