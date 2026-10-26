import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/failure_text.dart';
import '../../../../core/utils/l10n_ext.dart';

/// Close and Compact under the usage sheet. Compact asks first (the
/// explainer replaces the note line), then runs `session.compress`; a
/// failure stays on screen instead of closing the sheet.
class ContextCompactBar extends StatefulWidget {
  const ContextCompactBar({super.key, this.onCompact});

  /// Runs the compaction. Null hides the button.
  final Future<void> Function()? onCompact;

  @override
  State<ContextCompactBar> createState() => _ContextCompactBarState();
}

class _ContextCompactBarState extends State<ContextCompactBar> {
  bool _confirming = false;
  bool _running = false;
  Object? _error;

  Future<void> _compact() async {
    setState(() {
      _running = true;
      _error = null;
    });
    try {
      await widget.onCompact!();
      if (mounted) Navigator.of(context).pop();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _running = false;
        _confirming = false;
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final theme = Theme.of(context).textTheme;
    final tap = Size(spacing.minTouch * 2, spacing.minTouch);
    final error = _error;
    final compactLabel = _confirming
        ? l10n.contextMeterCompactConfirm
        : l10n.contextMeterCompact;
    final note = _confirming
        ? Text(l10n.contextMeterCompactExplainer, style: theme.bodySmall)
        : error != null
        ? Semantics(
            liveRegion: true,
            child: Text(
              l10n.contextMeterCompactFailed(failureText(context, error)),
              key: const Key('context-meter-error'),
              style: theme.bodySmall?.copyWith(color: context.colors.danger),
            ),
          )
        : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: context.surfaces.borderWidth),
        Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.xl,
            spacing.sm,
            spacing.xl,
            spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ?note,
              if (note != null) SizedBox(height: spacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(minimumSize: tap),
                    onPressed: _running
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(l10n.actionClose),
                  ),
                  if (widget.onCompact != null) ...[
                    SizedBox(width: spacing.sm),
                    FilledButton(
                      key: Key(
                        _confirming
                            ? 'context-meter-compact-confirm'
                            : 'context-meter-compact',
                      ),
                      style: FilledButton.styleFrom(minimumSize: tap),
                      onPressed: _running
                          ? null
                          : _confirming
                          ? _compact
                          : () => setState(() => _confirming = true),
                      // The spinner keeps the button's name: a busy button is
                      // still "Compact now" to a screen reader.
                      child: _running
                          ? Semantics(
                              label: compactLabel,
                              child: const AppSpinner.icon(),
                            )
                          : Text(compactLabel),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
