part of 'message_list.dart';

class _Row extends StatelessWidget {
  const _Row({required this.child, super.key, this.anchor, this.messageId});

  final Widget child;
  final GlobalKey? anchor;
  final String? messageId;

  @override
  Widget build(BuildContext context) {
    final scope = messageId == null
        ? null
        : context.dependOnInheritedWidgetOfExactType<MessageSearchScope>();
    final active =
        scope != null && scope.isActive && scope.activeMessageId == messageId;
    final body = SizedBox(key: anchor, width: double.infinity, child: child);
    return ReadingColumn(
      gutter: false,
      child: active
          ? AppSurface(
              color: context.colors.accentSoft,
              border: false,
              child: body,
            )
          : body,
    );
  }
}

class _ActivityLine extends StatelessWidget {
  const _ActivityLine({required this.state});

  final ChatState state;

  @override
  Widget build(BuildContext context) {
    final label = [
      state.thinkingLabel,
      state.statusLine,
    ].firstWhere((l) => l.isNotEmpty, orElse: () => context.l10n.chatThinking);
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing.turnGap),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Semantics(
          liveRegion: true,
          container: true,
          child: StatusDot(kind: StatusKind.busy, label: label),
        ),
      ),
    );
  }
}

class _JumpPill extends StatelessWidget {
  const _JumpPill({
    required this.atBottom,
    required this.unseen,
    required this.onPressed,
  });

  final ValueNotifier<bool> atBottom;
  final ValueNotifier<int> unseen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([atBottom, unseen]),
    builder: (context, _) {
      final hidden = atBottom.value;
      final count = unseen.value;
      return IgnorePointer(
        ignoring: hidden,
        child: AnimatedOpacity(
          opacity: hidden ? 0 : 1,
          duration: context.reduceMotion ? Duration.zero : context.motion.fast,
          child: count > 0
              ? FilledButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(CupertinoIcons.arrow_down),
                  label: Text(context.l10n.chatNewMessages(count)),
                )
              : AppIconButton(
                  icon: CupertinoIcons.arrow_down,
                  tooltip: context.l10n.chatScrollToBottom,
                  onPressed: onPressed,
                ),
        ),
      );
    },
  );
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.padding});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return ListView(
      reverse: true,
      padding: padding,
      children: [
        for (var i = 0; i < spacing.skeletonRows; i++)
          _Row(
            child: Padding(
              padding: EdgeInsets.only(bottom: spacing.turnGap),
              // A short line over a long one.
              child: SkeletonRow(
                title: true,
                titleGap: spacing.sm,
                lineHeight: spacing.lg,
              ),
            ),
          ),
      ],
    );
  }
}

class _OpenFailed extends StatelessWidget {
  const _OpenFailed({required this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      icon: CupertinoIcons.wifi_slash,
      title: l10n.chatOpenFailedTitle,
      message: l10n.chatOpenFailedBody,
      liveRegion: true,
      action: onRetry == null
          ? null
          : FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(CupertinoIcons.arrow_clockwise),
              label: Text(l10n.actionRetry),
            ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.botName});

  final String botName;

  @override
  Widget build(BuildContext context) => EmptyState(
    title: context.l10n.chatEmptyTitle(botName),
    message: context.l10n.chatEmptyBody,
  );
}
