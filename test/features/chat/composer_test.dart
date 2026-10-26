import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/share/presentation/composer_seeds_provider.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/models/local_attachment.dart';

import '../../support/memory_stores.dart';
import '../../support/scripted_api.dart';
import 'chat_harness.dart';

void main() {
  testWidgets('a half-written message survives the composer going away', (
    tester,
  ) async {
    final kv = MemoryKeyValueStore();
    var rig = bootChat(kv: kv);
    await pumpChat(tester, rig);
    await tester.enterText(find.byType(TextField), 'half a thought');
    await tester.pumpWidget(const SizedBox());
    rig = bootChat(kv: kv);
    await pumpChat(tester, rig);
    expect(find.text('half a thought'), findsOneWidget);
  });

  testWidgets('leaving the app lets go of the field, so the keyboard does '
      'not come back on return', (tester) async {
    await pumpChat(tester, bootChat());
    await tester.tap(find.byType(TextField));
    await tester.pump();
    bool focused() =>
        tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus;
    expect(focused(), isTrue);
    [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ].forEach(tester.binding.handleAppLifecycleStateChanged);
    await tester.pump();
    expect(focused(), isFalse);
  });

  testWidgets(
    'a share lands in the composer, and an oversize file is refused',
    (tester) async {
      final rig = bootChat();
      await pumpChat(tester, rig);
      final picture = (await tester.runAsync(tempImage))!;
      rig.container
          .read(composerSeedsProvider.notifier)
          .put(
            rig.target.key,
            ComposerSeed(
              text: 'look at this',
              attachments: [
                picture,
                const LocalAttachment(
                  id: 'big',
                  path: '/tmp/big.mov',
                  name: 'big.mov',
                  mimeType: 'video/quicktime',
                  sizeBytes: HermesLimits.maxFileBytes + 1,
                  kind: AttachmentKind.video,
                ),
              ],
            ),
          );
      await tester.pumpAndSettle();
      expect(find.text('look at this'), findsOneWidget);
      expect(find.textContaining('big.mov is larger than'), findsOneWidget);
      expect(find.bySemanticsLabel('pic.png'), findsOneWidget);
    },
  );

  testWidgets('the palette shows while a command name is typed, not after', (
    tester,
  ) async {
    await pumpChat(tester, bootChat());
    await tester.enterText(find.byType(TextField), '/');
    await tester.pump();
    for (final c in ['/new', '/restart', '/update', '/compact']) {
      expect(find.text(c), findsOneWidget);
    }
    await tester.enterText(find.byType(TextField), '/clear the cache');
    await tester.pump();
    expect(find.text('/new'), findsNothing);
  });

  testWidgets('offline, the composer still takes a turn and says it waits', (
    tester,
  ) async {
    final rig = bootChat();
    await pumpChat(tester, rig);
    rig.client.goOffline();
    await tester.pumpAndSettle();
    expect(find.textContaining('Offline'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'later');
    await tester.pump();
    await tester.tap(find.byIcon(CupertinoIcons.arrow_up));
    await tester.pumpAndSettle();
    expect(find.text('1 message waiting to send'), findsOneWidget);
    expect(rig.api.prompts, isEmpty);
  });
}
