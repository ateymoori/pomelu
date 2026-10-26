import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';

/// One input row, as iOS lays out a login form: the label at the start,
/// the frameless field after it. The label is also the field's accessible
/// name: read once, with the field.
class SettingsField extends StatelessWidget {
  const SettingsField({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final labelText = ExcludeSemantics(
      child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
    );
    final field = Semantics(label: label, child: child);
    // At accessibility text sizes iOS stacks the label over the field.
    if (MediaQuery.textScalerOf(context).scale(1) >=
        spacing.formStackTextScale) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: spacing.lg,
              end: spacing.lg,
              top: spacing.sm,
            ),
            child: labelText,
          ),
          field,
        ],
      );
    }
    return Row(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: spacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: spacing.formLabelWidth),
            child: labelText,
          ),
        ),
        Expanded(child: field),
      ],
    );
  }
}

/// Copy inside a settings card that is not an input: inset like the text
/// of a field or a row, so the left edges in a card line up.
class SettingsInset extends StatelessWidget {
  const SettingsInset({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.symmetric(
      horizontal: context.spacing.lg,
      vertical: context.spacing.sm,
    ),
    child: child,
  );
}

/// A status dot and a sentence that wraps. [StatusDot] keeps its label to one
/// line; the sentences on this page (and a user's long name) must stay
/// readable at large text, so they wrap here instead of ending in an ellipsis.
class SettingsStatus extends StatelessWidget {
  const SettingsStatus({required this.kind, required this.label, super.key});

  final StatusKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Semantics(
      container: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // The dot lines up with the first line of the text.
            padding: EdgeInsets.only(top: spacing.xs),
            child: StatusDot(kind: kind),
          ),
          SizedBox(width: spacing.sm),
          Flexible(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
