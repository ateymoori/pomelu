import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/failure_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/events/event_payloads.dart';
import '../../../../hermes/models/context_breakdown.dart';
import '../../domain/context_labels.dart';
import 'context_compact_bar.dart';
import 'context_meter.dart';
import 'context_usage_parts.dart';

/// Opens what fills the context window of [usage]'s session.
Future<void> showContextUsageSheet(
  BuildContext context, {
  required SessionUsage usage,
  Future<void> Function()? onCompact,
}) => AppSheet.show<void>(
  context,
  title: context.l10n.contextMeterTitle,
  height: SheetHeight.capped,
  builder: (_) => _ContextUsageSheet(usage: usage, onCompact: onCompact),
);

/// The context window of one session, in three parts: how full it is (the
/// provider's count where there is one), what fills it (each part of the
/// prompt and each context file, from `session.context_breakdown`), and the
/// conversation's token totals. Ends with a confirmed compaction.
class _ContextUsageSheet extends ConsumerWidget {
  const _ContextUsageSheet({required this.usage, this.onCompact});

  /// The reading the ring showed; live ticks replace it while open.
  final SessionUsage usage;

  /// Runs `session.compress`. Null hides the action.
  final Future<void> Function()? onCompact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = this.usage.sessionId;
    final usage = ref.watch(contextUsageProvider(id)).value ?? this.usage;
    final breakdown = ref.watch(contextBreakdownProvider(id));
    final spacing = context.spacing;
    final n = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: spacing.xl),
            children: [
              ..._summary(context, n, usage, breakdown.value),
              ..._parts(context, ref, n, breakdown),
              ..._totals(context, n, usage),
            ],
          ),
        ),
        ContextCompactBar(onCompact: onCompact),
      ],
    );
  }

  List<Widget> _summary(
    BuildContext context,
    NumberFormat n,
    SessionUsage usage,
    ContextBreakdown? b,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;
    final spacing = context.spacing;
    final known = b != null && !b.isEmpty;
    // The breakdown's figure is newer: it counts what came after the last
    // provider reading.
    final max = known ? b.contextMax : usage.contextMax;
    final used = known ? b.contextUsed : usage.contextUsed;
    if (max == null || max <= 0 || used == null) {
      return [Text(l10n.contextMeterUnknown, style: theme.bodyMedium)];
    }
    final percent = (used / max * 100).round();
    final source = known
        ? switch (b.contextSource) {
            ContextSource.provider => l10n.contextSourceProvider,
            ContextSource.providerPlusEstimate =>
              l10n.contextSourcePlusEstimate,
            _ => l10n.contextSourceEstimate,
          }
        : null;
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.contextPercent(percent),
            style: theme.headlineMedium?.copyWith(
              fontFeatures: context.textScale.tabularFigures,
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: spacing.xxs),
              child: Text(
                l10n.contextUsedOf(n.format(used), n.format(max)),
                style: theme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  fontFeatures: context.textScale.tabularFigures,
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: spacing.sm),
      ContextBar(
        key: const Key('context-usage-bar'),
        used: used,
        max: max,
        parts: [
          if (known)
            for (final (i, c) in b.categories.indexed)
              (contextPartColor(context, c.id, i), c.tokens),
        ],
      ),
      SizedBox(height: spacing.xs),
      Text(
        l10n.contextLeft(n.format(max - used < 0 ? 0 : max - used)),
        style: theme.bodySmall?.copyWith(
          color: colors.textSecondary,
          fontFeatures: context.textScale.tabularFigures,
        ),
      ),
      if (source != null)
        Text(
          source,
          style: theme.bodySmall?.copyWith(color: colors.textTertiary),
        ),
    ];
  }

  List<Widget> _parts(
    BuildContext context,
    WidgetRef ref,
    NumberFormat n,
    AsyncValue<ContextBreakdown?> breakdown,
  ) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final colors = context.colors;
    final title = SectionLabel(l10n.contextPartsTitle);
    final b = breakdown.value;
    if (breakdown.hasError) {
      return [
        title,
        ContextRow(
          key: const Key('context-usage-breakdown-error'),
          label: l10n.contextBreakdownFailed(
            failureText(context, breakdown.error!),
          ),
          value: '',
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: () =>
                ref.invalidate(contextBreakdownProvider(usage.sessionId)),
            child: Text(l10n.contextRetry),
          ),
        ),
      ];
    }
    if (b == null || b.isEmpty) {
      if (!breakdown.isLoading) return const [];
      return [
        title,
        for (var i = 0; i < spacing.skeletonRows; i++)
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.sm),
            child: const ShimmerLine(),
          ),
      ];
    }
    final max = b.contextMax;
    return [
      title,
      for (final (i, c) in b.categories.indexed)
        ContextRow(
          leading: StatusDot.legend(contextPartColor(context, c.id, i)),
          label: contextPartLabel(l10n, c),
          value: l10n.contextPartRow(
            n.format(c.tokens),
            contextShare(l10n, c.tokens, max),
          ),
        ),
      ContextRow(
        leading: StatusDot.legend(colors.track),
        label: l10n.contextFree,
        value: l10n.contextPartRow(
          n.format(b.remaining),
          contextShare(l10n, b.remaining, max),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: spacing.xs),
        child: Text(
          l10n.contextPartsNote,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: colors.textTertiary),
        ),
      ),
      if (b.contextFiles.isNotEmpty) ...[
        SectionLabel(l10n.contextFilesTitle),
        for (final f in b.contextFiles)
          ContextRow(
            leading: contextFileMark(context, f),
            label: f.label,
            note: contextFileNote(l10n, f),
            noteColor: switch (f.status) {
              'flagged' || 'truncated' => colors.warning,
              'blocked' || 'unreadable' => colors.danger,
              _ => null,
            },
            value: f.loaded ? n.format(f.tokens) : '',
          ),
      ],
    ];
  }

  List<Widget> _totals(BuildContext context, NumberFormat n, SessionUsage u) {
    final l10n = context.l10n;
    final cache = u.cacheHitPct;
    return [
      SectionLabel(l10n.contextTotalsTitle),
      ContextRow(label: l10n.contextMeterInput, value: n.format(u.input)),
      ContextRow(label: l10n.contextMeterOutput, value: n.format(u.output)),
      if (u.reasoning > 0)
        ContextRow(label: l10n.contextReasoning, value: n.format(u.reasoning)),
      if (cache != null)
        ContextRow(
          label: l10n.contextCacheHits,
          value: l10n.contextPercent(cache),
        ),
      if (u.calls > 0)
        ContextRow(label: l10n.contextCalls, value: n.format(u.calls)),
      if (u.compressions > 0)
        ContextRow(
          label: l10n.contextCompactions,
          value: n.format(u.compressions),
        ),
      SizedBox(height: context.spacing.md),
    ];
  }
}
