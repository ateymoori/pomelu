import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/theme/app_theme.dart';
import 'package:hermes/core/ui/ui.dart';
import 'package:hermes/features/sidebar/presentation/widgets/avatar.dart';
import 'package:hermes/hermes/models/local_attachment.dart';

import '../support/app_host.dart';

Widget wrap(Widget child) => appHost(child, dark: true);

void main() {
  testWidgets('every reusable widget builds', (tester) async {
    await tester.pumpWidget(
      wrap(
        ListView(
          children: [
            const ListTile(
              title: Text('Session'),
              subtitle: Text('2 min ago'),
              leading: HermesAvatar(name: 'Atlas', busy: true),
              trailing: StatusDot(kind: StatusKind.busy, label: 'Live'),
              selected: true,
            ),
            const StatusDot(kind: StatusKind.ok),
            const StatusDot(kind: StatusKind.warn, label: 'Reconnecting'),
            const StatusDot(kind: StatusKind.off),
            const FileBadge(name: 'report.pdf', kind: AttachmentKind.file),
            const FileBadge(name: 'notes.markdown', kind: AttachmentKind.file),
            const FileBadge(name: '', kind: AttachmentKind.audio),
            const ShimmerLine(),
            const ShimmerLine(width: 80, height: 20),
            const SizedBox(
              height: 300,
              child: EmptyState(
                icon: CupertinoIcons.chat_bubble_2,
                title: 'No chats yet',
                message: 'Start one from a bot in the menu.',
                action: OutlinedButton(
                  onPressed: null,
                  child: Text('New chat'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Builder(
                builder: (context) => FilledButton.icon(
                  style: context.destructiveButtonStyle,
                  onPressed: () {},
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                ),
              ),
            ),
            const TextButton(onPressed: null, child: Text('Ghost')),
            const FilledButton(onPressed: null, child: Text('Primary')),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: 'Gateway URL'),
            ),
            const HermesAvatar(name: ''),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 1,
                  label: Text('1'),
                  icon: Icon(Icons.circle),
                ),
              ],
              selected: const {1},
              showSelectedIcon: false,
              onSelectionChanged: (_) {},
            ),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a sheet rises from the bottom on a phone and floats '
      'centred on a tablet; Escape closes either', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    for (final (window, centred) in const [
      (Size(390, 844), false), // phone
      (Size(844, 390), false), // phone on its side
      (Size(1024, 1366), true), // iPad 13" upright
      (Size(1280, 800), true), // Android tablet on its side
    ]) {
      tester.view.physicalSize = window;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => AppSheet.show<void>(
                  context,
                  title: 'Share to',
                  builder: (_) => const Text('body'),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Share to'), findsOneWidget);
      final sheet = tester.getRect(find.byType(AppSheet));
      final card = tester.getRect(
        find
            .descendant(
              of: find.byType(AppSheet),
              matching: find.byType(AppGlass),
            )
            .first,
      );
      if (centred) {
        expect(
          card.center.dy,
          closeTo(window.height / 2, 1),
          reason: '$window',
        );
      } else {
        expect(sheet.bottom, window.height, reason: '$window');
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Share to'), findsNothing, reason: '$window');
      expect(tester.takeException(), isNull);
    }
  });
}
