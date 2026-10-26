import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/hermes_constants.dart';
import '../../../../hermes/models/model_options.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/model_catalog.dart';
import 'model_picker.dart';

/// Human label for a gateway reasoning effort level. Empty means the
/// profile default.
String _effortLabel(AppLocalizations l10n, String effort) => switch (effort) {
  '' => l10n.composerEffortAuto,
  'none' => l10n.composerEffortNone,
  'minimal' => l10n.composerEffortMinimal,
  'low' => l10n.composerEffortLow,
  'medium' => l10n.composerEffortMedium,
  'high' => l10n.composerEffortHigh,
  'xhigh' => l10n.composerEffortXhigh,
  'max' => l10n.composerEffortMax,
  'ultra' => l10n.composerEffortUltra,
  _ => effort,
};

/// Slider stops; the first is the bot's default ("Auto"), so a session that
/// never chose an effort is not shown on a level nobody asked for.
const List<String> _composerEffortStops = [
  '',
  ...HermesProtocol.reasoningEfforts,
];

/// The model and effort sheet. A model pick closes it; the effort is a live
/// control, applied each time the slider settles.
Future<void> showComposerSettings(
  BuildContext context, {
  required Future<ModelOptions> Function() load,
  required String currentModel,
  required String currentEffort,
  required void Function(String model, String provider) onModel,
  required ValueChanged<String> onEffort,
}) => AppSheet.show<void>(
  context,
  title: context.l10n.settingsTitle,
  height: SheetHeight.capped,
  builder: (context) => _ComposerSettingsSheet(
    load: load,
    currentModel: currentModel,
    currentEffort: currentEffort,
    onModel: onModel,
    onEffort: onEffort,
  ),
);

class _ComposerSettingsSheet extends StatefulWidget {
  const _ComposerSettingsSheet({
    required this.load,
    required this.currentModel,
    required this.currentEffort,
    required this.onModel,
    required this.onEffort,
  });

  /// The catalogue; a failure is said in the sheet.
  final Future<ModelOptions> Function() load;
  final String currentModel;

  /// Empty for the bot's default.
  final String currentEffort;
  final void Function(String model, String provider) onModel;
  final ValueChanged<String> onEffort;

  @override
  State<_ComposerSettingsSheet> createState() => _ComposerSettingsSheetState();
}

class _ComposerSettingsSheetState extends State<_ComposerSettingsSheet> {
  late int _effort = _indexOf(widget.currentEffort);

  static int _indexOf(String effort) {
    final i = _composerEffortStops.indexOf(effort);
    return i < 0 ? 0 : i;
  }

  void _slide(double value) {
    final next = value.round().clamp(0, _composerEffortStops.length - 1);
    if (next == _effort) return;
    setState(() => _effort = next);
  }

  void _settle(double value) =>
      widget.onEffort(_composerEffortStops[value.round()]);

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    // The whole sheet scrolls: with large text or a landscape screen the
    // effort control is simply the first thing in the list, and the model
    // rows below it are built lazily.
    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        SliverToBoxAdapter(child: _effortSection(context)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              spacing.lg,
              spacing.sm,
              spacing.lg,
              spacing.sm,
            ),
            child: Divider(height: 0, color: context.colors.divider),
          ),
        ),
        SliverToBoxAdapter(child: _modelHeader(context)),
        ModelCatalogView(
          load: widget.load,
          current: widget.currentModel,
          onPick: (model, provider) {
            Navigator.of(context).pop();
            widget.onModel(model, provider);
          },
        ),
        SliverToBoxAdapter(child: SizedBox(height: spacing.sm)),
      ],
    );
  }

  Widget _modelHeader(BuildContext context) {
    final spacing = context.spacing;
    final theme = Theme.of(context).textTheme;
    final current = modelDisplayName(widget.currentModel);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        spacing.xl,
        spacing.xs,
        spacing.xl,
        spacing.xs,
      ),
      child: Row(
        children: [
          Text(context.l10n.composerModel, style: theme.labelMedium),
          SizedBox(width: spacing.md),
          Expanded(
            child: Text(
              current,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.titleSmall?.copyWith(
                color: context.colors.accentText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _effortSection(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final label = _effortLabel(context.l10n, _composerEffortStops[_effort]);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        spacing.xl,
        spacing.xs,
        spacing.xl,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.composerPickEffort,
                  style: theme.labelMedium,
                ),
              ),
              SizedBox(width: spacing.sm),
              Text(
                label,
                style: theme.titleSmall?.copyWith(color: colors.accentText),
              ),
            ],
          ),
          // Full-bleed inside the section: the Material slider already pads
          // itself by half a thumb on each side. One control for a screen
          // reader: a name, the effort in words, and the slider's own
          // increase and decrease.
          MergeSemantics(
            child: Semantics(
              label: context.l10n.composerEffort,
              child: Slider.adaptive(
                value: _effort.toDouble(),
                max: (_composerEffortStops.length - 1).toDouble(),
                divisions: _composerEffortStops.length - 1,
                label: label,
                semanticFormatterCallback: (value) => _effortLabel(
                  context.l10n,
                  _composerEffortStops[value.round()],
                ),
                onChanged: _slide,
                onChangeEnd: _settle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
