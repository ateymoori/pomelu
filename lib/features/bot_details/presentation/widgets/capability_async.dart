import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/failure_text.dart';
import '../../../../core/utils/l10n_ext.dart';

/// A tab's [value]: placeholder rows while it loads, the failure (with Retry,
/// [onRetry], where it can help), else [data].
class CapabilityAsync<T> extends StatelessWidget {
  const CapabilityAsync({
    required this.value,
    required this.onRetry,
    required this.data,
    super.key,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T value) data;

  @override
  Widget build(BuildContext context) => value.when(
    loading: () => const _Loading(),
    error: (error, _) => _Failure(error: error, onRetry: onRetry),
    data: data,
  );
}

/// Placeholder rows while a list loads, said once as "Loading".
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final inset = AppSheet.inset(context);
    return Semantics(
      label: context.l10n.spinnerLoading,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: inset, vertical: spacing.md),
        children: [
          for (var i = 0; i < spacing.skeletonRows; i++)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.lg),
              child: SkeletonRow(
                title: true,
                titleGap: spacing.sm,
                lineHeight: spacing.md,
              ),
            ),
        ],
      ),
    );
  }
}

/// A failed load, announced, with Retry unless Retry cannot help (a gateway
/// without the route).
class _Failure extends StatelessWidget {
  const _Failure({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      icon: CupertinoIcons.wifi_slash,
      title: l10n.botDetailsLoadFailed,
      message: failureText(context, error),
      liveRegion: true,
      action: failureIsRetryable(error)
          ? OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(CupertinoIcons.arrow_clockwise),
              label: Text(l10n.actionRetry),
            )
          : null,
    );
  }
}
