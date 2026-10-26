import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/theme/tokens.dart';
import 'package:hermes/core/ui/ui.dart';
import 'package:hermes/features/sidebar/domain/bot_group.dart';
import 'package:hermes/features/sidebar/presentation/sidebar_panel.dart';
import 'package:hermes/features/sidebar/presentation/widgets/avatar.dart';
import 'package:hermes/hermes/hermes_failure.dart';

import 'sidebar_layout_harness.dart';

void main() {
  group('SidebarPanel', () {
    testWidgets('the selected row has an accent bar and a semibold name', (
      tester,
    ) async {
      await tester.pumpWidget(app((_) => const SidebarPanel(selected: open)));
      await tester.pump();

      final tokens = HermesTokens.light();
      final bars = find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == tokens.colors.accent &&
            (w.decoration as BoxDecoration).shape != BoxShape.circle,
      );
      expect(bars, findsOneWidget, reason: 'only the open bot has a bar');
      expect(tester.getSize(bars).width, tokens.spacing.selectedBar);

      final selectedName = tester.widget<Text>(find.text('atlas'));
      final otherName = tester.widget<Text>(find.text('hermes'));
      expect(selectedName.style?.fontWeight, FontWeight.w600);
      expect(otherName.style?.fontWeight, isNot(FontWeight.w600));
    });

    testWidgets('the skeleton lines up with the real rows', (tester) async {
      await tester.pumpWidget(
        app((_) => const SidebarPanel(), groups: const AsyncLoading()),
      );
      await tester.pump();
      final skeletonAvatar = tester.getTopLeft(find.byType(ShimmerLine).first);
      final skeletonText = tester.getTopLeft(find.byType(ShimmerLine).at(1));

      await tester.pumpWidget(app((_) => const SidebarPanel()));
      await tester.pump();
      final avatar = tester.getTopLeft(find.byType(HermesAvatar).first);
      final title = tester.getTopLeft(find.text('atlas'));

      expect(skeletonAvatar.dx, avatar.dx, reason: 'same avatar column');
      expect(skeletonText.dx, title.dx, reason: 'same text column');
    });

    testWidgets('header mark, rows and footer share the avatar column', (
      tester,
    ) async {
      await tester.pumpWidget(app((_) => const SidebarPanel()));
      await tester.pump();

      final avatar = tester.getCenter(find.byType(HermesAvatar).first);
      final mark = tester.getCenter(find.byType(Image).first);
      final settings = tester.getCenter(find.byIcon(CupertinoIcons.gear));
      final refresh = tester.getCenter(find.byIcon(CupertinoIcons.arrow_clockwise));

      expect(mark.dx, closeTo(avatar.dx, 0.5));
      expect(settings.dx, closeTo(avatar.dx, 0.5));
      // The collapse-side button of the footer mirrors it at the far edge.
      final width = tester.getSize(find.byType(SidebarPanel)).width;
      expect(width - refresh.dx, closeTo(avatar.dx + 1, 1.5));
    });

    testWidgets('a failed load is announced and retried like elsewhere', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        app(
          (_) => const SidebarPanel(),
          groups: const AsyncError<List<BotGroup>>(
            NetworkFailure('away'),
            StackTrace.empty,
          ),
        ),
      );
      await tester.pump();

      final node = tester.getSemantics(
        find.bySemanticsLabel(RegExp('Could not load bots')),
      );
      expect(node, isSemantics(isLiveRegion: true));

      final before = rosterBuilds(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Retry'));
      await tester.pump();
      expect(rosterBuilds(tester), before + 1, reason: 'started afresh');
      handle.dispose();
    });
  });
}
