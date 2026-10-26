part of 'markdown_body.dart';

/// Paints the find-in-conversation hits.
///
/// An inline pattern rather than a rewrite of the source: the query is user
/// input, and injecting markers into the Markdown would change what the
/// document means. Patterns are matched ahead of the built-in components, so a
/// hit inside a link label or a heading still lights up.
InlinePattern _highlightPattern(String query, HermesColors colors) =>
    InlinePattern(
      pattern: RegExp(RegExp.escape(query), caseSensitive: false),
      builder: (context, match, style) => TextSpan(
        text: match.group(0),
        style: style.copyWith(
          backgroundColor: colors.accentSoft,
          color: colors.textPrimary,
        ),
      ),
      // Returning a TextSpan, so a link label is safe to decorate too.
      scopes: MarkdownComponent.allScopes,
    );

/// One `- [x]` task-list entry: a read-only box and its label.
///
/// Read-only because the message is the model: nothing in a transcript can be
/// re-checked, and a control that moves but changes nothing is a lie.
class _TaskItem extends StatelessWidget {
  const _TaskItem({required this.checked, required this.content});

  /// Whether the box is ticked.
  final bool checked;

  /// The entry's text.
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      checked: checked,
      enabled: false,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.xxs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              // The gap sits on the label's side of the box, which is the
              // right one in a right-to-left reply.
              padding: EdgeInsetsDirectional.only(
                top: spacing.xxs,
                end: spacing.sm,
              ),
              child: Icon(
                checked
                    ? CupertinoIcons.checkmark_square_fill
                    : CupertinoIcons.square,
                size: spacing.lg,
                color: checked ? colors.accent : colors.textTertiary,
              ),
            ),
            Flexible(child: content),
          ],
        ),
      ),
    );
  }
}
