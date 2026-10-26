import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/theme/tokens.dart';
import 'package:hermes/features/sidebar/domain/bot_group.dart';
import 'package:hermes/features/sidebar/presentation/sidebar_panel.dart';
import 'package:hermes/features/sidebar/presentation/sidebar_state.dart';
import 'package:hermes/features/sidebar/presentation/widgets/sidebar_rail.dart';
import 'package:hermes/hermes/hermes_failure.dart';

import 'sidebar_layout_harness.dart';

void main() {
  group('SidebarRail', () {
    testWidgets('an avatar is a labelled button with a tap action', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(app((_) => const SidebarRail(selected: open)));
      await tester.pump();

      final node = tester.getSemantics(find.bySemanticsLabel('atlas'));
      expect(
        node,
        isSemantics(
          label: 'atlas',
          isButton: true,
          isSelected: true,
          hasTapAction: true,
        ),
      );
      // The other bot is a button too, and is not selected.
      expect(
        tester.getSemantics(find.bySemanticsLabel('hermes')),
        isSemantics(
          label: 'hermes',
          isButton: true,
          isSelected: false,
          hasTapAction: true,
        ),
      );

      // A screen reader's double tap opens the chat.
      tester.semantics.performAction(
        find.semantics.byLabel(node.label),
        SemanticsAction.tap,
      );
      await tester.pumpAndSettle();
      expect(find.text('chat'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a failed load: one button that retries', (tester) async {
      await tester.pumpWidget(
        app(
          (_) => const SidebarRail(),
          groups: const AsyncError<List<BotGroup>>(
            NetworkFailure('away'),
            StackTrace.empty,
          ),
        ),
      );
      await tester.pump();

      final before = rosterBuilds(tester);
      await tester.tap(find.byTooltip('Could not load bots. Retry'));
      await tester.pump();
      expect(rosterBuilds(tester), before + 1);
    });

    testWidgets('no gateway: one button that opens settings', (tester) async {
      await tester.pumpWidget(
        app((_) => const SidebarRail(), configured: false),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('No gateway'));
      await tester.pumpAndSettle();
      expect(find.text('settings'), findsOneWidget);
    });

    testWidgets('an empty roster says so and retries', (tester) async {
      await tester.pumpWidget(
        app((_) => const SidebarRail(), groups: const AsyncData([])),
      );
      await tester.pump();

      final before = rosterBuilds(tester);
      await tester.tap(find.byTooltip('No bots found on this gateway'));
      await tester.pump();
      expect(rosterBuilds(tester), before + 1);
    });
  });

  group('the expand button', () {
    testWidgets('is there in a tall window and opens the full menu', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(840, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app((_) => const SidebarRail(selected: open)));
      await tester.pump();

      expect(find.byTooltip('Expand menu'), findsOneWidget);
      await tester.tap(find.byTooltip('Expand menu'));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SidebarRail)),
      );
      expect(container.read(sidebarCollapsedProvider), isFalse);
    });

    testWidgets('is left out under the rail height: it would do nothing', (
      tester,
    ) async {
      final railMaxHeight = const Spacing().railMaxHeight;
      tester.view.physicalSize = Size(840, railMaxHeight - 1);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app((_) => const SidebarRail(selected: open)));
      await tester.pump();

      expect(find.byTooltip('Expand menu'), findsNothing);
      // The rest of the rail is still there.
      expect(find.byTooltip('Settings'), findsOneWidget);
      expect(find.bySemanticsLabel('atlas'), findsWidgets);
    });
  });

  group('large text', () {
    testWidgets('the menu fits a 280 dp pane at 2x text', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        app(
          (_) => const SizedBox(
            width: 280,
            child: SidebarPanel(selected: open, collapsible: true),
          ),
          textScale: 2,
        ),
      );
      await tester.pump();

      // A Flutter overflow is reported as an exception.
      expect(tester.takeException(), isNull);
      expect(find.text('atlas'), findsOneWidget);
    });

    testWidgets('the rail fits a short window', (tester) async {
      tester.view.physicalSize = const Size(840, 300);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        app((_) => const SidebarRail(selected: open), textScale: 2),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
