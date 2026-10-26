import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/events/event_payloads.dart';
import '../../../../hermes/models/context_breakdown.dart';
import '../../../connection/presentation/connection_providers.dart';
import '../../domain/chat_target.dart';
import '../chat_controller.dart';
import 'context_usage_sheet.dart';

part 'context_meter.g.dart';

/// What the meter reads off a `session.usage` reading. The gateway omits the
/// window figures it cannot compute, so nothing here is guessed.
extension ContextWindow on SessionUsage {
  /// Window occupancy, 0..1, or null when unknown.
  double? get fraction {
    final pct = contextPct;
    if (pct != null) return (pct / 100).clamp(0.0, 1.0);
    final used = contextUsed;
    final max = contextMax;
    if (used == null || max == null || max <= 0) return null;
    return (used / max).clamp(0.0, 1.0);
  }
}

/// Live usage of one session, straight off the socket: a tick repaints the
/// meter alone, never the transcript. Null until the first tick.
@riverpod
Stream<SessionUsage?> contextUsage(Ref ref, String runtimeId) {
  final client = ref.watch(hermesClientProvider);
  if (client == null || runtimeId.isEmpty) return Stream.value(null);
  return client.events
      .where((e) => e.sessionId == runtimeId)
      .map(SessionUsage.fromEvent)
      .where((u) => u != null);
}

/// The window share of a session whose usage carries none: the gateway
/// reports occupancy only once its agent has made a call in this process
/// (not after a resume or a restart), but its breakdown estimates it from
/// the transcript, with no model call. Null when it cannot tell either (no
/// live agent, a model of unknown window).
@riverpod
Future<double?> contextEstimate(Ref ref, String runtimeId) async {
  final api = ref.watch(hermesApiProvider);
  if (api == null || runtimeId.isEmpty) return null;
  final breakdown = await api.contextBreakdown(runtimeId);
  return breakdown.isEmpty ? null : breakdown.fraction;
}

/// What fills the window, asked each time the usage sheet opens.
@riverpod
Future<ContextBreakdown?> contextBreakdown(Ref ref, String runtimeId) async {
  final api = ref.watch(hermesApiProvider);
  if (api == null || runtimeId.isEmpty) return null;
  return api.contextBreakdown(runtimeId);
}

/// The context meter of the chat header, once the gateway reported usage:
/// the share of the window used, as a percent on a round glass button, in
/// the warning and danger colors as the window fills. Usage without the
/// window share takes the breakdown's estimate; with neither the button
/// shows a gauge.
class ContextMeterAction extends ConsumerWidget {
  const ContextMeterAction({required this.target, super.key});

  final ChatTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chat = chatControllerProvider(target);
    final runtimeId = ref.watch(chat.select((s) => s.runtimeId));
    final opening = ref.watch(chat.select((s) => s.openingUsage));
    final usage = ref.watch(contextUsageProvider(runtimeId)).value ?? opening;
    if (runtimeId.isEmpty || usage == null || usage.isEmpty) {
      return const SizedBox.shrink();
    }
    final colors = context.colors;
    final spacing = context.spacing;
    final fraction =
        usage.fraction ?? ref.watch(contextEstimateProvider(runtimeId)).value;
    final api = ref.watch(hermesApiProvider);
    // The gap to the next button rides on this one: absent, so is the gap.
    return Padding(
      padding: EdgeInsetsDirectional.only(end: spacing.iconGap),
      child: AppIconButton(
        tooltip: fraction == null
            ? context.l10n.contextMeterUnknown
            : context.l10n.contextMeterUsed((fraction * 100).round()),
        onPressed: () => showContextUsageSheet(
          context,
          usage: usage,
          onCompact: api == null ? null : () => api.compress(runtimeId),
        ),
        child: SizedBox.square(
          key: const Key('context-meter'),
          dimension: spacing.xl,
          child: fraction == null
              ? Icon(CupertinoIcons.gauge, color: colors.textSecondary)
              // The tooltip is what is read; the figure only shrinks to fit.
              : FittedBox(
                  child: Text(
                    context.l10n.contextPercent((fraction * 100).round()),
                    maxLines: 1,
                    textScaler: TextScaler.noScaling,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: context.textScale.tabularFigures,
                      color: switch (fraction) {
                        final v when v >= AppConfig.contextDangerAt =>
                          colors.danger,
                        final v when v >= AppConfig.contextWarnAt =>
                          colors.warning,
                        _ => colors.textPrimary,
                      },
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
