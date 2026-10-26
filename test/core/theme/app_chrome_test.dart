import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/theme/app_chrome.dart';
import 'package:hermes/core/theme/app_theme.dart';
import 'package:hermes/core/theme/tokens.dart';

Widget _app(ThemeMode mode, {Widget? home}) => MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: mode,
  builder: (context, child) => AppChrome(child: child!),
  home: home ?? const Scaffold(body: SizedBox.expand()),
);

void main() {
  testWidgets('system bar icons follow the app theme, not the phone', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    Brightness? icons() => tester
        .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
          find.descendant(
            of: find.byType(AppChrome),
            matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
          ),
        )
        .value
        .statusBarIconBrightness;

    await tester.pumpWidget(_app(ThemeMode.dark));
    expect(icons(), Brightness.light);

    await tester.pumpWidget(_app(ThemeMode.light));
    await tester.pumpAndSettle();
    expect(icons(), Brightness.dark);
  });

  for (final (window, expected) in [
    (840.0, HermesTokens.light().spacing.snackBarMaxWidth),
    (360.0, 360 - HermesTokens.light().spacing.gutter * 2),
  ]) {
    testWidgets('a snack bar at $window dp is $expected wide', (tester) async {
      tester.view.physicalSize = Size(window, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          ThemeMode.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Hi'))),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      final bar = find.descendant(
        of: find.byType(SnackBar),
        matching: find.byType(Material),
      );
      expect(tester.getSize(bar.first).width, expected);
    });
  }
}
