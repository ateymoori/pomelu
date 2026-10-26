import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/models/todo_plan.dart';

/// The agent's plan for the running turn, docked above the composer: one
/// line with how far it is and the step it works on, which opens to every
/// step.
class PlanCard extends StatefulWidget {
  const PlanCard({required this.plan, super.key});

  final TodoPlan plan;

  @override
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final spacing = context.spacing;
    final theme = Theme.of(context).textTheme;
    final plan = widget.plan;
    final current = plan.current;

    return AppGlass(
      floating: true,
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DisclosureRow(
            open: _open,
            onToggle: () => setState(() => _open = !_open),
            minHeight: spacing.minTouch,
            children: [
              Icon(
                CupertinoIcons.list_bullet,
                size: spacing.lg,
                color: colors.accent,
              ),
              SizedBox(width: spacing.sm),
              Text(
                l10n.chatPlanProgress(plan.done, plan.total),
                style: theme.labelLarge?.copyWith(color: colors.textPrimary),
              ),
              if (!_open && current != null) ...[
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    current.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ] else
                const Spacer(),
            ],
          ),
          if (_open)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (final t in plan.items) _Step(item: t)],
              ),
            ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.item});

  final TodoItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final spacing = context.spacing;
    final theme = Theme.of(context).textTheme;
    final closed = !item.status.isOpen;
    final (IconData icon, Color color, String state) = switch (item.status) {
      TodoStatus.completed => (
        CupertinoIcons.checkmark_circle_fill,
        colors.accent,
        l10n.chatPlanDone,
      ),
      TodoStatus.inProgress => (
        CupertinoIcons.circle_lefthalf_fill,
        colors.accent,
        l10n.chatPlanWorking,
      ),
      TodoStatus.cancelled => (
        CupertinoIcons.xmark_circle,
        colors.textTertiary,
        l10n.chatPlanCancelled,
      ),
      TodoStatus.pending => (
        CupertinoIcons.circle,
        colors.textTertiary,
        l10n.chatPlanToDo,
      ),
    };
    return Semantics(
      container: true,
      label: '$state: ${item.content}',
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: item.parent == null ? 0 : spacing.xl,
            top: spacing.xs,
            bottom: spacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: spacing.lg, color: color),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  item.content,
                  style: theme.bodySmall?.copyWith(
                    color: closed ? colors.textTertiary : colors.textPrimary,
                    fontWeight: item.status == TodoStatus.inProgress
                        ? FontWeight.w600
                        : null,
                    decoration: closed ? TextDecoration.lineThrough : null,
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
