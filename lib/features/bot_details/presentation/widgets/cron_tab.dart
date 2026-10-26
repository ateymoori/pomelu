import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/failure_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/models/bot_cron_job.dart';
import '../../domain/cron_job_activity.dart';
import '../bot_details_providers.dart';
import 'capability_async.dart';
import 'capability_tabs.dart';
import 'cron_details.dart';

/// The bot's jobs: pause or start, run now, delete.
class CronTab extends ConsumerWidget {
  const CronTab({required this.profile, super.key});

  final String profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = botCronJobsProvider(profile);
    return CapabilityAsync(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      data: (jobs) => CronView(profile: profile, jobs: jobs),
    );
  }
}

class CronView extends StatelessWidget {
  const CronView({required this.profile, required this.jobs, super.key});

  final String profile;
  final List<BotCronJob> jobs;

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      final l10n = context.l10n;
      return EmptyState(
        icon: CupertinoIcons.clock,
        title: l10n.botCronEmptyTitle,
        message: l10n.botCronEmptyBody,
      );
    }
    return SheetCardList(
      children: [
        for (final job in jobs)
          FormSection(
            children: [
              CronJobTile(key: ValueKey(job.id), profile: profile, job: job),
            ],
          ),
      ],
    );
  }
}

/// One job: its name with run, delete and the switch, then when it runs and
/// how the last run went.
class CronJobTile extends ConsumerWidget {
  const CronJobTile({required this.profile, required this.job, super.key});

  final String profile;
  final BotCronJob job;

  Future<void> _delete(BuildContext context, CronJobActions actions) async {
    final l10n = context.l10n;
    final go = await showConfirmDialog(
      context,
      title: l10n.botCronDeleteTitle,
      body: l10n.botCronDeleteBody(job.title),
      confirmLabel: l10n.botCronDelete,
    );
    if (go) await actions.remove();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final provider = cronJobActionsProvider(profile, job.id);
    final activity = ref.watch(provider);
    final actions = ref.read(provider.notifier);
    final idle = activity.idle;
    final failure = activity.failure;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        spacing.lg,
        spacing.xs,
        spacing.sm,
        spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  container: true,
                  header: true,
                  child: Text(
                    job.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.labelLarge,
                  ),
                ),
              ),
              // Labels name the job, so rows are told apart when read out.
              AppIconButton.plain(
                tooltip: l10n.botCronRunNowNamed(job.title),
                onPressed: idle ? actions.runNow : null,
                icon: CupertinoIcons.play_fill,
                busy: activity.doing == CronAction.run,
              ),
              AppIconButton.plain(
                tooltip: l10n.botCronDeleteNamed(job.title),
                color: colors.danger,
                onPressed: idle ? () => _delete(context, actions) : null,
                icon: CupertinoIcons.trash,
              ),
              Semantics(
                label: job.title,
                child: Switch.adaptive(
                  value: !job.isPaused && !job.isCompleted,
                  onChanged: idle && !job.isCompleted
                      ? (on) => actions.setPaused(paused: !on)
                      : null,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(end: spacing.md),
            child: CronJobDetails(job: job),
          ),
          if (failure != null)
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: spacing.xs,
                end: spacing.md,
              ),
              child: ErrorText(failureText(context, failure)),
            ),
        ],
      ),
    );
  }
}
