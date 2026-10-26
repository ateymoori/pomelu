import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/leave_page.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/failure_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../connection/domain/connection_probe.dart';
import '../settings_controller.dart';
import 'settings_section.dart';

/// "Test connection" and "Save and connect", plus what came back.
class SettingsConnectionActions extends ConsumerWidget {
  const SettingsConnectionActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final state = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final enabled = state.urlValid && !state.busy;
    final error = state.error;

    final result = state.testResult;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormSection(
          children: [
            FormButtonRow(
              label: state.testing
                  ? l10n.settingsTesting
                  : l10n.settingsTestConnection,
              busy: state.testing,
              onPressed: enabled ? () => unawaited(controller.test()) : null,
            ),
            FormButtonRow(
              label: l10n.settingsSave,
              busy: state.saving,
              onPressed: enabled ? () => unawaited(_save(context, ref)) : null,
            ),
          ],
        ),
        // Under the card, where iOS puts a section's note.
        if (result != null)
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              spacing.lg,
              spacing.xs,
              spacing.lg,
              0,
            ),
            child: Semantics(
              liveRegion: true,
              child: _TestResult(result: result),
            ),
          ),
        if (error != null) ...[
          SizedBox(height: spacing.sm),
          ErrorText(failureText(context, error)),
        ],
      ],
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final saved = await ref
        .read(settingsControllerProvider.notifier)
        .saveAndConnect();
    if (saved && context.mounted) leavePage(context);
  }
}

/// Outcome of the last test: a status dot and a sentence.
class _TestResult extends StatelessWidget {
  const _TestResult({required this.result});

  final TestResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final failure = result.failure;
    final reason = failure == null ? '' : failureText(context, failure);
    final detail = result.detail ?? '';
    return SettingsStatus(
      kind: result.ok ? StatusKind.ok : StatusKind.warn,
      label: result.ok
          ? l10n.settingsTestOk(result.version ?? '')
          : !result.httpOk
          ? l10n.settingsTestHttpFail(reason)
          : detail.isEmpty
          ? l10n.settingsTestWsFail(reason)
          : l10n.settingsTestWsFailDetail(reason, detail),
    );
  }
}
