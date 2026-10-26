import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';

/// The frame of every agent request: a title, content that scrolls, and the
/// actions. It takes the height its parent allows, so a long question never
/// pushes Send off the screen.
class RequestCard extends StatelessWidget {
  const RequestCard({
    required this.title,
    required this.body,
    super.key,
    this.actions = const [],
  });

  final String title;
  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return AppGlass(
      floating: true,
      padding: EdgeInsets.all(spacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A new request is announced, not only shown.
          Semantics(
            header: true,
            liveRegion: true,
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
          SizedBox(height: spacing.sm),
          Flexible(child: SingleChildScrollView(child: body)),
          if (actions.isNotEmpty) ...[
            SizedBox(height: spacing.md),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}

/// One answer at a time: [busy] while it is on its way; one that did not go
/// out (the socket is down) re-enables the card.
mixin RequestAnswerGate<T extends StatefulWidget> on State<T> {
  bool _busy = false;

  bool get busy => _busy;

  void answerOnce(bool Function() send) {
    if (_busy) return;
    setState(() => _busy = true);
    if (!send() && mounted) setState(() => _busy = false);
  }
}
