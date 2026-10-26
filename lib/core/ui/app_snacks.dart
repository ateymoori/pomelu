import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

/// Height of a layer floating over the bottom of a screen (in a chat: the
/// open request, slash palette and composer), so a snack bar can sit above
/// it instead of covering it.
///
/// Read with [BottomLayerInset.of], which does not subscribe: a snack bar is
/// built once, when it is shown.
class BottomLayerInset extends InheritedWidget {
  const BottomLayerInset({
    required this.height,
    required super.child,
    super.key,
  });

  /// Height of the layer, including the gesture-bar inset under it.
  final double height;

  /// The layer's height at [context]; zero outside one.
  static double of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<BottomLayerInset>()?.height ?? 0;

  @override
  bool updateShouldNotify(BottomLayerInset oldWidget) =>
      height != oldWidget.height;
}

/// Shows snack bars, above a [BottomLayerInset] when there is one.
///
/// Built from the widget's context *before* any `await` (the messenger and
/// the margin are read once), so a late snack bar needs no mounted context.
class AppSnacks {
  const AppSnacks._(this._messenger, this._margin, this._duration);

  /// Captures the messenger and the clearance above the bottom layer at
  /// [context].
  factory AppSnacks.of(BuildContext context) {
    final inset = BottomLayerInset.of(context);
    final spacing = context.spacing;
    return AppSnacks._(
      ScaffoldMessenger.maybeOf(context),
      inset <= 0
          ? null
          : EdgeInsets.fromLTRB(
              spacing.gutter,
              0,
              spacing.gutter,
              inset + spacing.sm,
            ),
      context.motion.snackBar,
    );
  }

  final ScaffoldMessengerState? _messenger;
  final EdgeInsets? _margin;
  final Duration _duration;

  /// Shows [message], with an optional [action], for [duration] (the
  /// default when null). Returns the bar, whose `closed` says how it went;
  /// null with no messenger to show it.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? show(
    String message, {
    SnackBarAction? action,
    Duration? duration,
  }) {
    final margin = _margin;
    return _messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: duration ?? _duration,
        // A margin only takes effect on a floating snack bar, and the
        // constructor insists the behavior says so.
        behavior: margin == null ? null : SnackBarBehavior.floating,
        margin: margin,
      ),
    );
  }

  /// Puts [text] on the clipboard, then says [done].
  Future<void> copy(String text, String done) async {
    await Clipboard.setData(ClipboardData(text: text));
    show(done);
  }
}
