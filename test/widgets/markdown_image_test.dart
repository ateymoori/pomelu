import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/theme/app_theme.dart';
import 'package:hermes/core/theme/tokens.dart';
import 'package:hermes/features/chat/presentation/widgets/markdown_image.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';

import '../support/app_host.dart';

Widget wrap(Widget child) => appHost(child);

/// A provider that always fails immediately.
///
/// The real widget uses `CachedNetworkImageProvider`, whose cache manager
/// never resolves under the test binding — neither a frame nor an error ever
/// arrives — so the error branch has to be driven by an injected provider.
class _FailingImage extends ImageProvider<_FailingImage> {
  const _FailingImage();

  @override
  Future<_FailingImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_FailingImage>(this);

  @override
  ImageStreamCompleter loadImage(_FailingImage key, ImageDecoderCallback _) =>
      OneFrameImageStreamCompleter(
        Future<ImageInfo>.error(Exception('no network in tests')),
      );
}

/// Fails like [_FailingImage] and counts how often it was really loaded.
class _CountingFailingImage extends ImageProvider<_CountingFailingImage> {
  int loads = 0;

  @override
  Future<_CountingFailingImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_CountingFailingImage>(this);

  @override
  ImageStreamCompleter loadImage(
    _CountingFailingImage key,
    ImageDecoderCallback _,
  ) {
    loads++;
    return OneFrameImageStreamCompleter(
      Future<ImageInfo>.error(Exception('no network in tests')),
    );
  }
}

void main() {
  group('MarkdownImage', () {
    testWidgets('retry really loads the picture again', (tester) async {
      final image = _CountingFailingImage();
      await tester.pumpWidget(
        wrap(
          MarkdownImage(
            url: 'https://example.com/pics/flaky.png',
            providerOverride: image,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(image.loads, 1);

      final l10n = AppLocalizations.of(
        tester.element(find.byType(MarkdownImage)),
      );
      await tester.tap(find.text(l10n.actionRetry));
      await tester.pumpAndSettle();

      expect(image.loads, 2, reason: 'the cached failure was evicted');
    });

    testWidgets('failed load degrades to a compact labelled chip', (
      tester,
    ) async {
      // `flutter test` answers every image request with 400, so the error
      // branch is what renders here.
      await tester.pumpWidget(
        wrap(
          const MarkdownImage(
            url: 'https://example.com/pics/missing.png',
            alt: 'A plot of the results',
            providerOverride: _FailingImage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('A plot of the results'), findsOneWidget);
      expect(find.textContaining('example.com'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.photo), findsOneWidget);

      // Compact, not a screenful: the chip must stay well under the old
      // full-width placeholder.
      final box = tester.getSize(find.byType(MarkdownImage));
      expect(box.height, lessThan(100));

      // Retry is reachable and meets the touch-target token.
      final retry = find.text(
        AppLocalizations.of(tester.element(find.byType(MarkdownImage)))
            .actionRetry,
      );
      expect(retry, findsOneWidget);
      final minTouch = AppTheme.light()
          .extension<HermesTokens>()!
          .spacing
          .minTouch;
      final button = tester.getSize(
        find.ancestor(of: retry, matching: find.byType(InkWell)),
      );
      expect(button.height, greaterThanOrEqualTo(minTouch));
      expect(button.width, greaterThanOrEqualTo(minTouch));
      await tester.tap(retry);
      await tester.pumpAndSettle();
    });

    testWidgets('falls back to the file name when there is no alt text', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const MarkdownImage(
            url: 'https://example.com/pics/chart.png',
            providerOverride: _FailingImage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('chart.png'), findsOneWidget);
    });
  });
}
