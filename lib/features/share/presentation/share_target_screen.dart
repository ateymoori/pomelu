import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/navigation/leave_page.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../core/utils/bidi_text.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../chat/domain/chat_target.dart';
import '../../connection/presentation/connection_providers.dart';
import '../../sidebar/presentation/widgets/bot_roster.dart';
import '../domain/incoming_share.dart';
import 'incoming_share_provider.dart';
import 'widgets/share_preview_strip.dart';

/// The bot picker for a share.
class ShareTargetScreen extends ConsumerWidget {
  const ShareTargetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final share = ref.watch(pendingShareProvider);
    final config = ref.watch(gatewayConfigProvider);
    final count = (share?.files.length ?? 0) + (_hasText(share) ? 1 : 0);

    final Widget body;
    if (share == null || share.isEmpty) {
      body = EmptyState(
        icon: CupertinoIcons.tray,
        title: l10n.shareEmpty,
        message: l10n.shareEmptyBody,
        action: OutlinedButton(
          onPressed: () => _close(context, ref),
          child: Text(l10n.actionClose),
        ),
      );
    } else if (config == null) {
      body = EmptyState(
        icon: CupertinoIcons.wifi_slash,
        title: l10n.connStateNotConfigured,
        message: l10n.shareNoGateway,
        action: FilledButton.icon(
          onPressed: () => context.push<void>(Routes.settings),
          icon: const Icon(CupertinoIcons.gear),
          label: Text(l10n.actionOpenSettings),
        ),
      );
    } else {
      body = _Picker(share: share);
    }

    // However the picker is left, the share is dropped, or the shell would
    // open it again. After the frame: the route can go mid-build.
    final pending = ref.read(pendingShareProvider.notifier);
    final shownId = share?.id;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop || shownId == null) return;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => pending.dismiss(shownId),
        );
      },
      child: Scaffold(
        appBar: readingAppBar(
          context,
          title: l10n.shareTitle,
          subtitle: count > 0 ? l10n.shareItems(count) : null,
          onClose: () => _close(context, ref),
        ),
        body: SafeArea(
          child: ReadingColumn(
            // One notice per share: a newer share starts its own.
            child: _SkippedNotice(
              key: ValueKey(shownId),
              count: share?.skipped ?? 0,
              child: body,
            ),
          ),
        ),
      ),
    );
  }

  static bool _hasText(IncomingShare? share) =>
      share != null && share.text.trim().isNotEmpty;

  static void _close(BuildContext context, WidgetRef ref) {
    ref.read(pendingShareProvider.notifier).consume();
    leavePage(context);
  }
}

/// Says once that the phone left [count] files out (over the caps).
class _SkippedNotice extends StatefulWidget {
  const _SkippedNotice({required this.count, required this.child, super.key});

  final int count;
  final Widget child;

  @override
  State<_SkippedNotice> createState() => _SkippedNoticeState();
}

class _SkippedNoticeState extends State<_SkippedNotice> {
  @override
  void initState() {
    super.initState();
    if (widget.count <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppSnacks.of(context).show(context.l10n.shareSkipped(widget.count));
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The payload over the bots to send it to.
class _Picker extends ConsumerWidget {
  const _Picker({required this.share});

  final IncomingShare share;

  void _pick(BuildContext context, WidgetRef ref, String profile) => context.go(
    ref
        .read(pendingShareProvider.notifier)
        .routeTo(ChatTarget.bot(profile), share),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final text = share.text.trim();

    return BotRoster(
      activity: false,
      padding: EdgeInsets.only(bottom: spacing.xxl),
      onPick: (profile) => _pick(context, ref, profile),
      header: [
        SliverPadding(
          padding: EdgeInsets.only(top: spacing.sm),
          sliver: SliverList.list(
            children: [
              if (share.files.isNotEmpty) ...[
                SharePreviewStrip(files: share.files),
                SizedBox(height: spacing.md),
              ],
              if (text.isNotEmpty) ...[
                AppSurface(
                  padding: EdgeInsets.all(spacing.md),
                  child: withTextDirection(
                    text: text,
                    child: Text(
                      text,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                SizedBox(height: spacing.md),
              ],
              SectionLabel(
                l10n.navBots,
                padding: EdgeInsetsDirectional.only(
                  start: spacing.md,
                  bottom: spacing.sm,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
