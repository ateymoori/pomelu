import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/hermes_constants.dart';
import '../../../../hermes/requests/server_request.dart';
import 'clarify_card.dart';
import 'input_card.dart';
import 'request_frame.dart';

/// The question the agent is blocked on, docked above the composer. Keyed by
/// the request id: a new question starts clean, a re-delivery after a
/// reconnect keeps what the person staged. Each callback says whether the
/// answer went out; false lets the person try again.
class PendingRequestCard extends StatelessWidget {
  const PendingRequestCard({
    required this.request,
    required this.onClarify,
    required this.onSkip,
    required this.onApproval,
    required this.onInput,
    super.key,
  });

  final ServerRequest request;
  final bool Function(Map<String, String?> answers) onClarify;
  final bool Function() onSkip;
  final bool Function(String choice) onApproval;
  final bool Function(String value) onInput;

  @override
  Widget build(BuildContext context) => switch (request) {
    final ClarifyRequest r => ClarifyCard(
      key: ValueKey(r.id),
      request: r,
      onSend: onClarify,
      onSkip: onSkip,
    ),
    final ApprovalRequest r => _ApprovalCard(
      key: ValueKey(r.id),
      request: r,
      onDecide: onApproval,
    ),
    final InputRequest r => InputCard(
      key: ValueKey(r.id),
      request: r,
      onSend: onInput,
    ),
  };
}

/// A dangerous command waiting for a decision. The first choice leads, a
/// refusal carries the danger tint, the rest are plain secondaries.
class _ApprovalCard extends StatefulWidget {
  const _ApprovalCard({
    required this.request,
    required this.onDecide,
    super.key,
  });

  final ApprovalRequest request;
  final bool Function(String choice) onDecide;

  @override
  State<_ApprovalCard> createState() => _ApprovalCardState();
}

class _ApprovalCardState extends State<_ApprovalCard>
    with RequestAnswerGate<_ApprovalCard> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final request = widget.request;
    final spacing = context.spacing;
    final theme = Theme.of(context).textTheme;
    Widget button(int i, String choice) {
      final label = Text(switch (choice) {
        ApprovalChoices.once => l10n.chatChoiceOnce,
        ApprovalChoices.always => l10n.chatChoiceAlways,
        ApprovalChoices.session => l10n.chatChoiceSession,
        ApprovalChoices.deny || ApprovalChoices.no => l10n.chatChoiceDeny,
        _ => choice,
      });
      final onPressed = busy
          ? null
          : () => answerOnce(() => widget.onDecide(choice));
      final refuses = ApprovalChoices.refuses(choice);
      return i == 0 || refuses
          ? FilledButton(
              style: refuses ? context.destructiveButtonStyle : null,
              onPressed: onPressed,
              child: label,
            )
          : OutlinedButton(onPressed: onPressed, child: label);
    }

    return RequestCard(
      title: l10n.chatApprovalTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (request.command.isNotEmpty)
            AppSurface(
              borderRadius: BorderRadius.circular(context.radii.md),
              padding: EdgeInsets.all(spacing.sm),
              child: SelectableText(
                request.command,
                style: context.textScale.mono(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          if (request.description.isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            SizedBox(
              width: double.infinity,
              child: Text(
                request.description,
                style: theme.bodySmall,
                textDirection: directionOf(request.description),
              ),
            ),
          ],
          if (request.smartDenied) ...[
            SizedBox(height: spacing.sm),
            Text(
              l10n.chatApprovalRisky,
              style: theme.bodySmall?.copyWith(color: context.colors.danger),
            ),
          ],
        ],
      ),
      actions: [
        for (final (i, choice) in request.choices.indexed) button(i, choice),
      ],
    );
  }
}
