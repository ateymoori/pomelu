import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/storage/key_value_store.dart';
import 'package:hermes/core/storage/secret_store.dart';
import 'package:hermes/core/theme/tokens.dart';
import 'package:hermes/core/ui/ui.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/features/share/data/share_intake_service.dart';
import 'package:hermes/features/share/domain/incoming_share.dart';
import 'package:hermes/features/share/presentation/incoming_share_provider.dart';
import 'package:hermes/features/share/presentation/share_target_screen.dart';
import 'package:hermes/features/share/presentation/widgets/share_preview_strip.dart';
import 'package:hermes/features/sidebar/presentation/sidebar_providers.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/local_attachment.dart';
import 'package:hermes/hermes/models/profile.dart';

import '../../support/app_host.dart';
import '../../support/memory_stores.dart';

/// Hands the screen the share it shows.
class _Intake extends Fake implements ShareIntakeService {
  _Intake(this.share);

  final IncomingShare share;

  @override
  Stream<IncomingShare> get shares => const Stream.empty();

  @override
  Future<IncomingShare?> initial() async => share;

  @override
  Future<void> dispose() async {}
}

/// A roster that answers with the next outcome of [results] on each build.
class _Roster extends Profiles {
  _Roster(this.results);

  final List<Completer<List<HermesProfile>>> results;

  // A test fake counts builds for the test to read.
  // ignore: riverpod_lint/avoid_public_notifier_properties
  int builds = 0;

  @override
  Future<List<HermesProfile>> build() => results[builds++].future;
}

const _text = IncomingShare(id: 's', text: 'a link worth sending');
const _plain = HermesProfile(name: 'atlas', isDefault: true);
const _described = HermesProfile(name: 'nova', description: 'Writes things');

void main() {
  Future<_Roster> pump(
    WidgetTester tester, {
    required List<Completer<List<HermesProfile>>> results,
    Size size = const Size(360, 800),
    double textScale = 1,
    bool configured = true,
    IncomingShare share = _text,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = size;
    addTearDown(tester.view.reset);
    final roster = _Roster(results);

    await pumpApp(
      tester,
      const ShareTargetScreen(),
      scaffold: false,
      textScale: textScale,
      overrides: [
        keyValueStoreProvider.overrideWithValue(
          MemoryKeyValueStore({
            if (configured) PreferenceKeys.gatewayUrl: 'http://gw.test:9119',
          }),
        ),
        secretStoreProvider.overrideWithValue(MemorySecretStore()),
        shareIntakeServiceProvider.overrideWithValue(_Intake(share)),
        profilesProvider.overrideWith(() => roster),
        profileAvatarProvider.overrideWith((ref, name) => null),
      ],
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    return roster;
  }

  Completer<List<HermesProfile>> done(List<HermesProfile> bots) =>
      Completer<List<HermesProfile>>()..complete(bots);

  group('files the phone left out', () {
    testWidgets('are told once, with how many', (tester) async {
      await pump(
        tester,
        results: [
          done(const [_plain]),
        ],
        share: const IncomingShare(id: 's', text: 'words', skipped: 3),
      );

      expect(
        find.text('3 files were left out because they are over the limit'),
        findsOneWidget,
      );
      expect(find.text('words'), findsOneWidget, reason: 'the rest is sent');
    });
  });

  group('the roster', () {
    testWidgets('loading shows skeleton rows and no bots', (tester) async {
      await pump(tester, results: [Completer<List<HermesProfile>>()]);

      expect(find.byType(ShimmerLine), findsWidgets);
      expect(find.byType(ListTile), findsNothing);
      expect(find.text('Bots'), findsOneWidget);
      expect(find.text('a link worth sending'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a failure says so and Retry loads it again', (tester) async {
      final failing = Completer<List<HermesProfile>>();
      final second = Completer<List<HermesProfile>>();
      final roster = await pump(tester, results: [failing, second]);
      failing.completeError(const NetworkFailure('refused'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Could not load bots'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(roster.builds, 2, reason: 'asked the gateway again');

      second.complete(const [_plain, _described]);
      await tester.pump();
      await tester.pump();
      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('Could not load bots'), findsNothing);
    });

    testWidgets('an empty roster says so, with Retry', (tester) async {
      await pump(tester, results: [done(const [])]);
      await tester.pump();

      expect(find.text('No bots found on this gateway'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('the bots are rows, all of one height', (tester) async {
      await pump(
        tester,
        results: [
          done(const [_plain, _described]),
        ],
      );
      await tester.pump();

      final rows = find.byType(ListTile);
      expect(rows, findsNWidgets(2));
      expect(
        tester.getSize(rows.at(0)).height,
        tester.getSize(rows.at(1)).height,
        reason: 'with or without a description',
      );
      expect(find.text('Writes things'), findsOneWidget);
    });

    testWidgets('no gateway set up points to Settings', (tester) async {
      await pump(tester, results: [done(const [])], configured: false);

      expect(find.text('Open settings'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });
  });

  group('the bar', () {
    testWidgets('on a wide screen its content sits in the same column as the '
        'list, not at the screen edge', (tester) async {
      await pump(
        tester,
        results: [
          done(const [_plain, _described]),
        ],
        size: const Size(1000, 800),
      );
      await tester.pump();

      final close = tester.getTopLeft(find.byType(AppCloseButton));
      final row = tester.getTopLeft(find.byType(ListTile).first);
      final column = const Spacing().readingWidth;
      expect(close.dx, closeTo((1000 - column) / 2, 0.5));
      expect(row.dx, closeTo(close.dx, 0.5));
    });
  });

  group('the preview strip', () {
    testWidgets('a picture is a square tile of the media-tile size with a '
        'hairline edge', (tester) async {
      final dir = Directory.systemTemp.createTempSync('share_strip');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/pic.png')..writeAsBytesSync(_png);

      await pumpApp(
        tester,
        SharePreviewStrip(
          files: [
            LocalAttachment(
              id: '1',
              path: file.path,
              name: 'pic.png',
              mimeType: 'image/png',
              sizeBytes: _png.length,
              kind: AttachmentKind.image,
            ),
          ],
        ),
      );

      final tile = find.byType(Image);
      expect(tile, findsOneWidget);
      final size = tester.getSize(tile);
      expect(size.width, const Spacing().mediaTile);
      expect(size.height, const Spacing().mediaTile);
      final image = tester.widget<Image>(tile);
      expect(image.fit, BoxFit.cover);
      final decoration = tester
          .widgetList<DecoratedBox>(
            find.ancestor(of: tile, matching: find.byType(DecoratedBox)),
          )
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((d) => d.border != null);
      expect(decoration.border, isNotNull);
    });

    testWidgets('a file is a pill whose name is capped, not tied to the menu '
        'width', (tester) async {
      await pumpApp(
        tester,
        SharePreviewStrip(
          files: [
            LocalAttachment(
              id: '1',
              path:
                  '/nowhere/'
                          'a-very-long-file-name-' *
                      6 +
                  '.pdf',
              name: 'a-very-long-file-name-' * 6 + '.pdf',
              mimeType: 'application/pdf',
              sizeBytes: 2048,
            ),
          ],
        ),
      );

      final label = find.textContaining('a-very-long-file-name-');
      expect(label, findsOneWidget);
      expect(
        tester.getSize(label).width,
        lessThanOrEqualTo(const Spacing().attachmentLabelMaxWidth),
      );
      expect(find.text('2.0 KB'), findsOneWidget);
    });
  });
}

/// A 1x1 PNG.
const List<int> _png = [
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
  0x0d, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0xf8, 0xcf, 0xc0, 0xf0,
  0x1f, 0x00, 0x05, 0x00, 0x01, 0xff, 0x89, 0x99, 0x3d, 0x1d, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
];
