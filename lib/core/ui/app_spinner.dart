import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/tokens.dart';

/// The one busy ring. With reduced motion it is a still three-quarter ring.
/// Announced as "Loading", or [semanticsLabel].
class AppSpinner extends StatelessWidget {
  const AppSpinner({super.key, this.size, this.color, this.semanticsLabel})
    : _inheritColor = false;

  /// Sized to a button's icon slot and in its foreground: the `icon` of a
  /// working `*Button.icon`, so the label never shifts.
  const AppSpinner.icon({super.key, this.semanticsLabel})
    : size = null,
      color = null,
      _inheritColor = true;

  /// Defaults to `spacing.lg`.
  final double? size;

  /// Defaults to `colors.accent`.
  final Color? color;
  final String? semanticsLabel;
  final bool _inheritColor;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size ?? context.spacing.lg,
    child: CircularProgressIndicator(
      value: context.reduceMotion ? context.motion.spinnerStillSweep : null,
      strokeWidth: context.surfaces.borderWidth * 2,
      color: _inheritColor
          ? IconTheme.of(context).color
          : color ?? context.colors.accent,
      // Nullable lookup: a bare test with no strings still builds.
      semanticsLabel:
          semanticsLabel ??
          Localizations.of<AppLocalizations>(
            context,
            AppLocalizations,
          )?.spinnerLoading,
    ),
  );
}
