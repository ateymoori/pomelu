import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/theme/app_theme.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';

/// [child] as the app shows it: the app's theme ([dark] picks the dark one)
/// and strings under a `ProviderScope`, in a `Scaffold`.
///
/// - [overrides] go to a new `ProviderScope`; a [container] is used as it is
///   instead (`UncontrolledProviderScope`), for a test that reads it after.
/// - [width] and [height] box the child; with either, or an [alignment], it
///   sits in an `Align` (top left by default) rather than filling the body.
/// - [textScale] and [direction] apply to the whole app, routes and sheets
///   included.
/// - [scaffold] false puts [child] straight on the route, for a screen that
///   brings its own `Scaffold`.
Widget appHost(
  Widget child, {
  double? width,
  double? height,
  AlignmentGeometry? alignment,
  double textScale = 1,
  bool dark = false,
  TextDirection? direction,
  List<Override> overrides = const [],
  ProviderContainer? container,
  bool scaffold = true,
}) {
  var home = child;
  if (width != null || height != null || alignment != null) {
    home = Align(
      alignment: alignment ?? Alignment.topLeft,
      child: SizedBox(width: width, height: height, child: home),
    );
  }
  if (scaffold) home = Scaffold(body: home);
  final app = MaterialApp(
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: textScale == 1 && direction == null
        ? null
        : (context, routes) {
            Widget scaled = MediaQuery.withClampedTextScaling(
              minScaleFactor: textScale,
              maxScaleFactor: textScale,
              child: routes!,
            );
            if (direction != null) {
              scaled = Directionality(textDirection: direction, child: scaled);
            }
            return scaled;
          },
    home: home,
  );
  return container == null
      ? ProviderScope(overrides: overrides, child: app)
      : UncontrolledProviderScope(container: container, child: app);
}

/// Pumps [appHost] around [child]; see there for the options.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  double? width,
  double? height,
  AlignmentGeometry? alignment,
  double textScale = 1,
  bool dark = false,
  TextDirection? direction,
  List<Override> overrides = const [],
  ProviderContainer? container,
  bool scaffold = true,
}) => tester.pumpWidget(
  appHost(
    child,
    width: width,
    height: height,
    alignment: alignment,
    textScale: textScale,
    dark: dark,
    direction: direction,
    overrides: overrides,
    container: container,
    scaffold: scaffold,
  ),
);
