import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/ui/ui.dart';

import '../../support/app_host.dart';

void main() {
  Finder blurOf(Finder of) => find.descendant(
    of: of,
    matching: find.byType(BackdropFilter),
  );

  testWidgets('a button on a glass bar is a bare glyph: never glass on glass', (
    tester,
  ) async {
    await tester.pumpWidget(
      appHost(
        AppGlass.bar(
          child: AppIconButton(
            icon: Icons.search,
            tooltip: 'Find',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(blurOf(find.byType(AppGlass)), findsOneWidget, reason: 'the bar');
  });

  testWidgets('Reduce Transparency and Increase Contrast make glass solid', (
    tester,
  ) async {
    const pane = AppGlass(child: Text('pane'));
    await tester.pumpWidget(appHost(const GlassScope(solid: true, child: pane)));
    expect(find.byType(BackdropFilter), findsNothing);

    await tester.pumpWidget(
      appHost(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(highContrast: true),
            child: pane,
          ),
        ),
      ),
    );
    expect(find.byType(BackdropFilter), findsNothing);

    await tester.pumpWidget(appHost(pane));
    expect(find.byType(BackdropFilter), findsOneWidget, reason: 'glass');
  });
}
