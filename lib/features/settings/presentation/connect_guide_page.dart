import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../chat/presentation/widgets/markdown_body.dart';

/// How to run a gateway the app can reach, and how to connect to it. Plain
/// Markdown, so the commands get the code block's copy action.
class ConnectGuidePage extends StatelessWidget {
  const ConnectGuidePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBodyBehindAppBar: true,
    appBar: readingAppBar(
      context,
      title: context.l10n.connectGuideTitle,
      onClose: () => Navigator.of(context).maybePop(),
    ),
    body: const _Body(),
  );
}

/// The guide; under the Scaffold, so the top inset includes the glass bar.
class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          // Under the glass bar: start below it, scroll on beneath it.
          top: MediaQuery.paddingOf(context).top + spacing.sm,
          bottom: spacing.xxl,
        ),
        child: ReadingColumn(
          child: MarkdownBody(context.l10n.connectGuideBody),
        ),
      ),
    );
  }
}
