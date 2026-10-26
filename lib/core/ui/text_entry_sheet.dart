import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'app_close_button.dart';
import 'app_icon_button.dart';
import 'form_section.dart';

/// A sheet that asks for one text, as iOS 27 does: ✕ and ✓ glass circles
/// either side of the [title], the field the one row of a card below.
/// Pops with the text, or null when closed. A single line also submits from
/// the keyboard's done key.
class TextEntrySheet extends StatefulWidget {
  const TextEntrySheet({
    required this.title,
    required this.initial,
    required this.submitLabel,
    super.key,
    this.maxLines = 1,
  });

  final String title;
  final String initial;

  /// Names the ✓ for a screen reader ("Create").
  final String submitLabel;

  /// Above 1 makes the field multi-line.
  final int maxLines;

  @override
  State<TextEntrySheet> createState() => _TextEntrySheetState();
}

class _TextEntrySheetState extends State<TextEntrySheet> {
  late final TextEditingController _controller =
      TextEditingController.fromValue(
        TextEditingValue(
          text: widget.initial,
          selection: TextSelection.collapsed(offset: widget.initial.length),
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final multiline = widget.maxLines > 1;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        spacing.lg,
        0,
        spacing.lg,
        spacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppCloseButton(onPressed: () => Navigator.of(context).pop()),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              AppIconButton(
                icon: CupertinoIcons.checkmark,
                tooltip: widget.submitLabel,
                onPressed: _submit,
                disc: true,
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          FormSection(
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                maxLines: widget.maxLines,
                keyboardType: multiline ? TextInputType.multiline : null,
                textInputAction: multiline ? null : TextInputAction.done,
                onSubmitted: multiline ? null : (_) => _submit(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
