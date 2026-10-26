import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/l10n_ext.dart';

/// The composer's text field: bare inside the composer's pill, one line
/// growing to [AppConfig.maxComposerLines], then scrolling.
class ComposerField extends StatelessWidget {
  const ComposerField({
    required this.controller,
    required this.focusNode,
    required this.botName,
    required this.enabled,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// Named in the hint.
  final String botName;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final body = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    const none = InputBorder.none;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: spacing.minTouch),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.xs),
          // A stable id for UI tests (Android resource id, iOS accessibility
          // identifier): the hint is gone once a draft holds words.
          child: Semantics(
            identifier: 'composer',
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              minLines: 1,
              // Then it scrolls instead of pushing the conversation away.
              maxLines: AppConfig.maxComposerLines,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              textCapitalization: TextCapitalization.sentences,
              // The UI is English: a Persian message must say its direction.
              textDirection: directionOf(controller.text),
              cursorColor: colors.accent,
              style: body.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                border: none,
                enabledBorder: none,
                focusedBorder: none,
                disabledBorder: none,
                errorBorder: none,
                isCollapsed: true,
                filled: false,
                contentPadding: EdgeInsets.zero,
                hintText: context.l10n.chatPlaceholder(botName),
                hintMaxLines: 1,
                hintStyle: body.copyWith(color: colors.textTertiary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
