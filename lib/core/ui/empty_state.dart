import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'app_surface.dart';

/// Centered placeholder for an empty list or an unconfigured screen, with an
/// optional [icon] over it; it scrolls when it does not fit. Set [liveRegion] on a failure, so it is
/// announced when it appears.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.message,
    super.key,
    this.icon,
    this.action,
    this.liveRegion = false,
  });

  final IconData? icon;
  final String title;
  final String message;
  final Widget? action;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.hasBoundedHeight ? constraints.maxHeight : 0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: spacing.emptyStateWidth),
              child: Padding(
                padding: EdgeInsets.all(spacing.xl),
                child: Semantics(
                  liveRegion: liveRegion,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        ExcludeSemantics(
                          child: AppSurface(
                            borderRadius: BorderRadius.circular(
                              context.radii.pill,
                            ),
                            padding: EdgeInsets.all(spacing.lg),
                            child: Icon(
                              icon,
                              size: spacing.xl,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing.lg),
                      ],
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium,
                      ),
                      SizedBox(height: spacing.sm),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall,
                      ),
                      if (action != null) ...[
                        SizedBox(height: spacing.xl),
                        action!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
