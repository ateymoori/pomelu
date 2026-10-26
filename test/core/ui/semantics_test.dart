import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/ui/ui.dart';

import '../../support/app_host.dart';

Widget _host(Widget child) => appHost(child, alignment: Alignment.center);

/// Asserts [label] is an enabled button a screen reader can tap.
void _tapsAsButton(WidgetTester tester, String label, int Function() taps) {
  final node = tester.getSemantics(find.bySemanticsLabel(label));
  expect(node, isSemantics(label: label, isButton: true, hasTapAction: true));
  final before = taps();
  tester.semantics.performAction(
    find.semantics.byLabel(label),
    SemanticsAction.tap,
  );
  expect(taps(), before + 1);
}

void main() {
  testWidgets('icon buttons and the remove badge are labelled buttons', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(
      _host(
        Column(
          children: [
            AppIconButton(
              icon: Icons.add,
              tooltip: 'Add',
              onPressed: () => taps++,
            ),
            AppIconButton(
              tooltip: 'Context ring',
              onPressed: () => taps++,
              child: const SizedBox.square(dimension: 24),
            ),
            const AppIconButton(icon: Icons.remove, tooltip: 'Off'),
            SizedBox.square(
              dimension: 96,
              child: Stack(
                children: [
                  RemoveBadge(label: 'Remove', onPressed: () => taps++),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    _tapsAsButton(tester, 'Add', () => taps);
    _tapsAsButton(tester, 'Context ring', () => taps);
    _tapsAsButton(tester, 'Remove', () => taps);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Off')),
      isSemantics(
        label: 'Off',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        hasTapAction: false,
      ),
    );
    handle.dispose();
  });

  testWidgets('spinner, heading and a failed load announce themselves', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            AppSpinner(),
            SectionLabel('Web search'),
            Expanded(
              child: EmptyState(
                icon: CupertinoIcons.wifi_slash,
                title: 'Could not load',
                message: 'No route to host',
                liveRegion: true,
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Web search')),
      isSemantics(label: 'Web search', isHeader: true),
    );
    final failure = tester.getSemantics(
      find.bySemanticsLabel(RegExp('Could not load')),
    );
    expect(failure, isSemantics(isLiveRegion: true));
    expect(failure.label, contains('No route to host'));
    handle.dispose();
  });

  testWidgets('an empty state scrolls, without overflow, in 200 dp at 2x', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const EmptyState(
        icon: CupertinoIcons.wifi_slash,
        title: 'Could not load bots and chats',
        message: 'The gateway did not answer. Check the connection.',
        action: OutlinedButton(onPressed: null, child: Text('Retry')),
      ),
      width: 360,
      height: 200,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);

    final retry = find.text('Retry');
    await tester.scrollUntilVisible(retry, 80);
    expect(retry, findsOneWidget);
  });

  testWidgets('a text entry sheet pops with the edited text; close drops '
      'it', (tester) async {
    String? popped;
    await pumpApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => popped = await AppSheet.show<String>(
            context,
            builder: (_) => const TextEntrySheet(
              title: 'Rename',
              initial: 'Old',
              submitLabel: 'Done',
            ),
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'New title');
    await tester.tap(find.byTooltip('Done'));
    await tester.pumpAndSettle();
    expect(popped, 'New title');

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Thrown away');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(popped, isNull);
  });
}
