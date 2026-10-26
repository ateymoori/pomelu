part of 'chat_view.dart';

class _Banner extends ConsumerWidget {
  const _Banner({required this.target});

  final ChatTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatControllerProvider(target);
    final (:error, :stale) = ref.watch(
      provider.select((s) => (error: s.error, stale: s.historyStale)),
    );
    if (error == null) return const SizedBox.shrink();
    final controller = ref.read(provider.notifier);
    final colors = context.colors;
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: AppGlass(
        floating: true,
        padding: EdgeInsetsDirectional.only(start: spacing.md, end: spacing.xs),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              size: spacing.lg,
              color: colors.danger,
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: spacing.sm),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    failureText(context, error),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colors.textPrimary),
                  ),
                ),
              ),
            ),
            if (stale)
              TextButton(
                onPressed: () => unawaited(controller.reopen()),
                child: Text(context.l10n.actionRetry),
              ),
            AppIconButton(
              icon: CupertinoIcons.xmark,
              tooltip: context.l10n.chatDismiss,
              onPressed: controller.clearError,
            ),
          ],
        ),
      ),
    );
  }
}

/// The agent's plan, only while its turn runs.
class _Plan extends ConsumerWidget {
  const _Plan({required this.target});

  final ChatTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(
      chatControllerProvider(target).select((s) => s.running ? s.plan : null),
    );
    if (plan == null) return const SizedBox.shrink();
    return ReadingColumn(
      padding: EdgeInsets.only(bottom: context.spacing.sm),
      child: PlanCard(plan: plan),
    );
  }
}

class _Question extends ConsumerWidget {
  const _Question({required this.target, required this.pane});

  final ChatTarget target;
  final BoxConstraints pane;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatControllerProvider(target);
    final runtimeId = ref.watch(provider.select((s) => s.runtimeId));
    final pending = ref.watch(pendingRequestProvider(runtimeId)).value;
    if (pending == null) return const SizedBox.shrink();
    final controller = ref.read(provider.notifier);
    final spacing = context.spacing;
    return ReadingColumn(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: math.max(
            pane.maxHeight * spacing.requestMaxFraction,
            spacing.requestMinHeight,
          ),
        ),
        child: PendingRequestCard(
          request: pending,
          onClarify: (answers) => controller.answerClarify(pending.id, answers),
          onSkip: () => controller.cancelClarify(pending.id),
          onApproval: (choice) => controller.answerApproval(pending.id, choice),
          onInput: (value) => controller.answerInput(pending.id, value),
        ),
      ),
    );
  }
}
