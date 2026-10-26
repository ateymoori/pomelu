import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import 'code_highlight.dart';

/// A fenced code block: mono text on `colors.codeBackground`, scrolled
/// horizontally instead of wrapped, with the language label and a copy action.
class CodeBlock extends StatefulWidget {
  const CodeBlock({required this.code, super.key, this.language = ''});

  /// Raw source, without the fences.
  final String code;

  /// Info string of the fence, e.g. `dart`. May be empty.
  final String language;

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final scale = context.textScale;
    final radius = BorderRadius.circular(context.radii.md);
    final label = widget.language.trim();
    final source = widget.code.trimRight();
    final mono = scale.mono(
      size: scale.code,
      height: scale.lineHeight,
      color: colors.codeText,
    );
    // Null whenever the grammar is unknown or the source is oversized; the
    // block then paints as plain mono text.
    final highlighted = CodeHighlight.spanFor(
      context,
      code: source,
      language: label,
      base: mono,
    );

    // Source code always reads left to right, even inside an RTL reply.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.sm),
        child: AppSurface(
          color: colors.codeBackground,
          borderColor: colors.divider,
          borderRadius: radius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: spacing.md,
                  end: spacing.xs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: scale.mono(
                          size: scale.caption2,
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                    _CopyButton(code: widget.code),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.md,
                  0,
                  spacing.md,
                  spacing.md,
                ),
                child: Scrollbar(
                  controller: _scroll,
                  child: SingleChildScrollView(
                    controller: _scroll,
                    scrollDirection: Axis.horizontal,
                    child: Text.rich(
                      highlighted ?? TextSpan(text: source, style: mono),
                      softWrap: false,
                      // Screen readers read the source, not the colouring.
                      semanticsLabel: source,
                      style: mono,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) => AppIconButton.plain(
    icon: CupertinoIcons.doc_on_doc,
    tooltip: context.l10n.chatCopy,
    onPressed: () => AppSnacks.of(context).copy(code, context.l10n.chatCopied),
    iconSize: context.spacing.lg,
    color: context.colors.textTertiary,
  );
}
