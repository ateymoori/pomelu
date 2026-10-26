import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../chat/domain/model_catalog.dart';
import '../../../sidebar/presentation/sidebar_providers.dart';
import '../../../sidebar/presentation/widgets/avatar.dart';
import 'capability_tabs.dart';
import 'cron_tab.dart';
import 'edit_bot_page.dart';
import 'soul_tab.dart';

/// The details of bot [profile]: its name and picture, skills, tools,
/// instructions and jobs.
Future<void> showBotDetails(BuildContext context, String profile) =>
    AppSheet.show<void>(
      context,
      height: SheetHeight.tall,
      builder: (context) => BotDetailsSheet(profile: profile),
    );

enum _Tab { skills, tools, instructions, cron }

/// All from the gateway's own dashboard routes.
class BotDetailsSheet extends StatefulWidget {
  const BotDetailsSheet({required this.profile, super.key});

  final String profile;

  @override
  State<BotDetailsSheet> createState() => _BotDetailsSheetState();
}

class _BotDetailsSheetState extends State<BotDetailsSheet> {
  _Tab _tab = _Tab.skills;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    return Column(
      children: [
        _Header(profile: widget.profile),
        SizedBox(height: spacing.md),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.lg),
          child: SizedBox(
            width: double.infinity,
            child: AppSegmented<_Tab>(
              selected: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
              segments: {
                _Tab.skills: l10n.botDetailsSkills,
                _Tab.tools: l10n.botDetailsTools,
                _Tab.instructions: l10n.botDetailsInstructions,
                _Tab.cron: l10n.botDetailsCron,
              },
            ),
          ),
        ),
        Expanded(
          // Only the open tab is built, so only its list loads.
          child: switch (_tab) {
            _Tab.skills => SkillsTab(profile: widget.profile),
            _Tab.tools => ToolsTab(profile: widget.profile),
            _Tab.instructions => SoulTab(profile: widget.profile),
            _Tab.cron => CronTab(profile: widget.profile),
          },
        ),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.profile});

  final String profile;

  /// Opens the edit page; a deleted bot closes the sheet and its chat.
  Future<void> _edit(BuildContext context) async {
    final result = await Navigator.of(context).push<BotEditResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EditBotPage(profile: profile),
      ),
    );
    if (result != BotEditResult.deleted || !context.mounted) return;
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.go(Routes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.spacing;
    final theme = Theme.of(context).textTheme;
    final title = ref.watch(botTitleProvider(profile));
    final model =
        ref.watch(
          profilesProvider.select(
            (bots) =>
                bots.value?.where((b) => b.name == profile).firstOrNull?.model,
          ),
        ) ??
        '';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.lg),
      child: Row(
        children: [
          BotAvatar(name: profile, title: title),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.titleMedium,
                  ),
                ),
                if (model.isNotEmpty)
                  Text(
                    modelDisplayName(model),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          AppIconButton(
            icon: CupertinoIcons.pencil,
            tooltip: context.l10n.botEdit,
            onPressed: () => unawaited(_edit(context)),
          ),
        ],
      ),
    );
  }
}
