import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/bot_group.dart';
import 'avatar.dart';

/// One bot: avatar, name, and "Working…" or its last message (else its
/// description or model) with the time. The selected row has three cues:
/// the tint, an accent bar and a semibold name. With [activity] off (the
/// share picker) it says only who the bot is, so every row is one height.
class BotRow extends StatelessWidget {
  const BotRow({
    required this.group,
    super.key,
    this.selected = false,
    this.activity = true,
    this.onTap,
  });

  final BotGroup group;
  final bool selected;
  final bool activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final theme = Theme.of(context).textTheme;
    final profile = group.profile;
    final preview = activity
        ? plainPreview(profile.canonicalSession?.preview ?? '')
        : '';
    final fallback = profile.description.trim().isNotEmpty
        ? profile.description.trim()
        : profile.model;
    final time = activity
        ? relativeTime(l10n, profile.lastActivity, DateTime.now())
        : '';
    final working = activity && group.working;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          ListTile(
            selected: selected,
            onTap: onTap,
            // The title names the bot; the avatar stays quiet.
            leading: ExcludeSemantics(
              child: BotAvatar(
                name: group.name,
                title: group.title,
                busy: working,
              ),
            ),
            title: ContentLine(
              group.title,
              style: selected ? theme.labelLarge : null,
            ),
            subtitle: working
                ? StatusDot(kind: StatusKind.busy, label: l10n.sidebarRunning)
                : ContentLine(preview.isNotEmpty ? preview : fallback),
            trailing: time.isEmpty
                ? null
                : Padding(
                    padding: EdgeInsetsDirectional.only(start: spacing.xs),
                    child: Text(time, style: theme.labelSmall),
                  ),
          ),
          if (selected)
            PositionedDirectional(
              start: 0,
              top: spacing.sm,
              bottom: spacing.sm,
              width: spacing.selectedBar,
              child: ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colors.accent,
                    borderRadius: BorderRadius.circular(context.radii.pill),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `now`, `5m`, `3h`, `Yesterday`, then a day in the locale of [l10n].
String relativeTime(AppLocalizations l10n, DateTime? time, DateTime now) {
  if (time == null) return '';
  final local = time.toLocal();
  final delta = now.difference(local);
  if (delta.inMinutes < 1) return l10n.timeNow;
  if (delta.inMinutes < Duration.minutesPerHour) {
    return l10n.timeMinutes(delta.inMinutes);
  }
  if (delta.inHours < Duration.hoursPerDay) {
    return l10n.timeHours(delta.inHours);
  }
  if (Format.calendarDays(local, now) == 1) return l10n.timeYesterday;
  return DateFormat.MMMd(l10n.localeName).format(local);
}

final RegExp _markdownMarks = RegExp(r'[*_`#>~]+|\[(.*?)\]\(.*?\)');

/// One plain line for a preview: Markdown marks dropped, spaces collapsed.
String plainPreview(String text) => text
    .replaceAllMapped(_markdownMarks, (m) => m.group(1) ?? '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
