import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/models/bot_skill.dart';
import '../../../../hermes/models/bot_toolset.dart';
import '../../domain/bot_capabilities.dart';
import '../bot_details_providers.dart';
import 'capability_async.dart';

class SkillsTab extends ConsumerWidget {
  const SkillsTab({required this.profile, super.key});

  final String profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = botSkillsProvider(profile);
    return CapabilityAsync(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      data: (skills) => SkillsView(skills: skills),
    );
  }
}

class SkillsView extends StatelessWidget {
  const SkillsView({required this.skills, super.key});

  final List<BotSkill> skills;

  @override
  Widget build(BuildContext context) {
    final groups = BotCapabilities.groupSkills(skills);
    if (groups.isEmpty) {
      final l10n = context.l10n;
      return EmptyState(
        icon: CupertinoIcons.sparkles,
        title: l10n.botDetailsNoSkills,
        message: l10n.botDetailsNoSkillsBody,
      );
    }
    final l10n = context.l10n;
    return SheetCardList(
      children: [
        for (final group in groups)
          FormSection(
            header: group.category.isEmpty
                ? l10n.botDetailsOther
                : BotCapabilities.prettyCategory(group.category),
            children: [
              for (final skill in group.skills)
                FormRow(
                  title: skill.name,
                  subtitle: skill.description.isEmpty
                      ? null
                      : skill.description,
                ),
            ],
          ),
      ],
    );
  }
}

class ToolsTab extends ConsumerWidget {
  const ToolsTab({required this.profile, super.key});

  final String profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = botToolsetsProvider(profile);
    return CapabilityAsync(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      data: (toolsets) => ToolsView(toolsets: toolsets),
    );
  }
}

class ToolsView extends StatelessWidget {
  const ToolsView({required this.toolsets, super.key});

  final List<BotToolset> toolsets;

  @override
  Widget build(BuildContext context) {
    final shown = BotCapabilities.enabledToolsets(toolsets);
    if (shown.isEmpty) {
      final l10n = context.l10n;
      return EmptyState(
        icon: CupertinoIcons.wrench,
        title: l10n.botDetailsNoTools,
        message: l10n.botDetailsNoToolsBody,
      );
    }
    final mono = context.textScale.mono();
    return SheetCardList(
      children: [
        for (final toolset in shown)
          FormSection(
            header: toolset.title,
            children: toolset.toolNames.isEmpty
                ? [FormRow(title: toolset.description)]
                : [
                    for (final name in toolset.toolNames)
                      FormRow(title: name, titleStyle: mono),
                  ],
          ),
      ],
    );
  }
}

/// The cards of a tall sheet's tab, as an iOS grouped list: inset from the
/// sheet's edges, a gap between cards.
class SheetCardList extends StatelessWidget {
  const SheetCardList({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        spacing.lg,
        spacing.md,
        spacing.lg,
        spacing.xl,
      ),
      itemCount: children.length,
      separatorBuilder: (_, _) => SizedBox(height: spacing.lg),
      itemBuilder: (_, i) => children[i],
    );
  }
}
