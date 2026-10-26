import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';

/// The live find query, published to the rows: they are cached, so a query
/// passed down would rebuild them all; this rebuilds only what paints hits.
class MessageSearchScope extends InheritedWidget {
  const MessageSearchScope({
    required this.query,
    required super.child,
    super.key,
    this.activeMessageId,
  });

  /// Empty when no search runs.
  final String query;

  /// The message of the hit the user is parked on.
  final String? activeMessageId;

  bool get isActive => query.trim().length >= AppConfig.minSearchLength;

  /// The active query, or null.
  static String? queryOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<MessageSearchScope>();
    return scope != null && scope.isActive ? scope.query.trim() : null;
  }

  @override
  bool updateShouldNotify(MessageSearchScope oldWidget) =>
      query != oldWidget.query || activeMessageId != oldWidget.activeMessageId;
}

/// Requests from the header to open the find bar, which lives in the
/// transcript with the scroller it needs. A counter: a tap while the bar is
/// open is a fresh request that focuses the field again.
class MessageSearchRequests extends ValueNotifier<int> {
  MessageSearchRequests() : super(0);

  void open() => value++;
}

/// Hands [MessageSearchRequests] down to the header and the transcript.
class MessageSearchLauncher extends InheritedWidget {
  const MessageSearchLauncher({
    required this.requests,
    required super.child,
    super.key,
  });

  final MessageSearchRequests requests;

  /// Null outside a chat. Does not subscribe to the notifier.
  static MessageSearchRequests? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<MessageSearchLauncher>()
      ?.requests;

  @override
  bool updateShouldNotify(MessageSearchLauncher oldWidget) =>
      requests != oldWidget.requests;
}

/// Non-overlapping, case-insensitive hits of [query] in [text]; `indexOf`,
/// since a regex of user input would need escaping on every keystroke.
int countMatches(String text, String query) {
  if (query.isEmpty) return 0;
  final haystack = text.toLowerCase();
  final needle = query.toLowerCase();
  var count = 0;
  for (
    var at = haystack.indexOf(needle);
    at >= 0;
    at = haystack.indexOf(needle, at + needle.length)
  ) {
    count++;
  }
  return count;
}

/// The find bar: a field, a hit counter, and the two jump arrows.
class MessageSearchBar extends StatelessWidget {
  const MessageSearchBar({
    required this.controller,
    required this.matchCount,
    required this.activeMatch,
    required this.onNext,
    required this.onPrevious,
    required this.onClose,
    super.key,
    this.focusNode,
  });

  /// Owned by the transcript, so the query outlives this bar.
  final FocusNode? focusNode;
  final TextEditingController controller;
  final int matchCount;

  /// 1-based; 0 when there is no hit.
  final int activeMatch;

  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final l10n = context.l10n;
    final hasMatches = matchCount > 0;
    final status = hasMatches
        ? l10n.chatSearchProgress(activeMatch, matchCount)
        : l10n.chatSearchNoMatches;

    final field = Expanded(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onNext(),
        decoration: InputDecoration(hintText: l10n.chatSearchHint),
      ),
    );
    final counter = Text(
      status,
      style: (Theme.of(context).textTheme.labelMedium ?? const TextStyle())
          .copyWith(
            color: hasMatches ? colors.textSecondary : colors.textTertiary,
          ),
    );
    final previous = AppIconButton(
      icon: CupertinoIcons.chevron_up,
      tooltip: l10n.chatSearchPrevious,
      onPressed: hasMatches ? onPrevious : null,
    );
    final next = AppIconButton(
      icon: CupertinoIcons.chevron_down,
      tooltip: l10n.chatSearchNext,
      onPressed: hasMatches ? onNext : null,
    );
    final close = AppIconButton(
      icon: CupertinoIcons.xmark,
      tooltip: l10n.chatSearchClose,
      onPressed: onClose,
    );

    return AppGlass(
      floating: true,
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          // One row while the field keeps a usable width; on a phone or with
          // large text, the counter and arrows go on a second row.
          final fieldMin = spacing.minTouch * 4;
          final counterRoom = MediaQuery.textScalerOf(context)
              .scale(spacing.xxl * 2);
          final oneRow =
              box.maxWidth >=
              fieldMin + counterRoom + spacing.minTouch * 3 + spacing.sm;
          if (oneRow) {
            return Row(
              children: [
                field,
                SizedBox(width: spacing.sm),
                counter,
                previous,
                next,
                close,
              ],
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [field, close]),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(start: spacing.sm),
                      child: counter,
                    ),
                  ),
                  previous,
                  next,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
