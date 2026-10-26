import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/failure_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../sidebar_providers.dart';
import 'bot_row.dart';

/// The gateway's bots under [header] (slivers that scroll with them):
/// skeleton rows while they load, a failure or an empty roster with Retry,
/// else a [BotRow] each. The side menu and the share picker both show it.
class BotRoster extends ConsumerWidget {
  const BotRoster({
    required this.onPick,
    super.key,
    this.header = const [],
    this.selected,
    this.activity = true,
    this.padding = EdgeInsets.zero,
    this.onRefresh,
  });

  /// With the profile of the tapped row.
  final ValueChanged<String> onPick;
  final List<Widget> header;

  /// The profile whose row is selected.
  final String? selected;

  /// Rows say what each bot is doing ([BotRow.activity]).
  final bool activity;

  /// Around the rows and their skeleton.
  final EdgeInsetsGeometry padding;

  /// Pull to refresh the rows; null for none.
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    // From scratch: a roster that never connected waits for it again.
    final retry = OutlinedButton.icon(
      onPressed: () => ref.invalidate(profilesProvider),
      icon: const Icon(CupertinoIcons.arrow_clockwise),
      label: Text(l10n.actionRetry),
    );
    final groups = ref.watch(sidebarGroupsProvider);
    final rows = groups.value ?? const [];
    final refresh = onRefresh;
    final scroll = CustomScrollView(
      physics: refresh == null ? null : const AlwaysScrollableScrollPhysics(),
      slivers: [
        ...header,
        groups.when(
          loading: () => SliverPadding(
            padding: padding,
            sliver: SliverToBoxAdapter(
              child: Semantics(
                label: l10n.spinnerLoading,
                child: Column(
                  children: [
                    for (var i = 0; i < spacing.skeletonRows; i++)
                      Padding(
                        padding: EdgeInsets.all(spacing.md),
                        child: SkeletonRow(
                          avatar: true,
                          title: true,
                          lineHeight: spacing.md,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          error: (error, _) => SliverFillRemaining(
            child: EmptyState(
              icon: CupertinoIcons.wifi_slash,
              title: l10n.sidebarLoadFailed,
              message: failureText(context, error),
              action: retry,
              liveRegion: true,
            ),
          ),
          data: (list) => list.isEmpty
              ? SliverFillRemaining(
                  child: EmptyState(
                    icon: CupertinoIcons.person_2,
                    title: l10n.sidebarNoBots,
                    message: l10n.sidebarNoBotsBody,
                    action: retry,
                  ),
                )
              : SliverPadding(
                  padding: padding,
                  sliver: SliverList.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => SizedBox(height: spacing.xxs),
                    itemBuilder: (context, i) => BotRow(
                      group: list[i],
                      selected: selected == list[i].name,
                      activity: activity,
                      onTap: () => onPick(list[i].name),
                    ),
                  ),
                ),
        ),
      ],
    );
    if (refresh == null || rows.isEmpty) return scroll;
    return RefreshIndicator(
      onRefresh: refresh,
      color: context.colors.accent,
      backgroundColor: context.surfaces.surfaceElevated,
      child: scroll,
    );
  }
}
