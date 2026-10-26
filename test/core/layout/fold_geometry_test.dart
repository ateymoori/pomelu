import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/layout/fold_geometry.dart';
import 'package:hermes/core/theme/tokens.dart';

/// Galaxy Z Fold 6, inner screen: 2160 x 1856 px at 2.625 dpr.
const Size foldUnfoldedPx = Size(2160, 1856);
const double foldDpr = 2.625;
final Size foldUnfoldedDp = foldUnfoldedPx / foldDpr;

/// Galaxy Z Fold 6, cover screen: 968 x 2376 px at 2.8125 dpr.
const Size foldFoldedPx = Size(968, 2376);
const double foldedDpr = 2.8125;
final Size foldFoldedDp = foldFoldedPx / foldedDpr;

MediaQueryData _query(Size size, List<DisplayFeature> features) =>
    MediaQueryData(size: size, displayFeatures: features);

FoldGeometry? _fold(MediaQueryData query) =>
    FoldGeometry.resolve(size: query.size, features: query.displayFeatures);

/// A seamless vertical fold down the middle of [size].
DisplayFeature _verticalFold(Size size, {double width = 0}) => DisplayFeature(
  bounds: Rect.fromLTRB(
    (size.width - width) / 2,
    0,
    (size.width + width) / 2,
    size.height,
  ),
  type: width > 0 ? DisplayFeatureType.hinge : DisplayFeatureType.fold,
  state: DisplayFeatureState.postureFlat,
);

void main() {
  const spacing = Spacing();

  group('FoldGeometry', () {
    test('Fold 6 unfolded reports a centred vertical fold', () {
      final geometry = _fold(
        _query(foldUnfoldedDp, [_verticalFold(foldUnfoldedDp)]),
      );

      expect(geometry, isNotNull);
      expect(geometry!.leftWidth, closeTo(foldUnfoldedDp.width / 2, 0.01));
      expect(geometry.rightWidth, closeTo(foldUnfoldedDp.width / 2, 0.01));
      expect(geometry.hingeWidth, 0);
      expect(geometry.occludes, isFalse);
      // Unfolded is wide enough for the two-pane shell.
      expect(
        foldUnfoldedDp.width,
        greaterThanOrEqualTo(spacing.sidebarWidth + spacing.chatPaneMin),
      );
    });

    test('ignores cutouts, horizontal folds and partial features', () {
      final size = foldUnfoldedDp;
      final ignored = [
        // Camera cutout.
        const DisplayFeature(
          bounds: Rect.fromLTWH(200, 0, 20, 20),
          type: DisplayFeatureType.cutout,
          state: DisplayFeatureState.unknown,
        ),
        // Horizontal fold (flip-style).
        DisplayFeature(
          bounds: Rect.fromLTRB(
            0,
            size.height / 2,
            size.width,
            size.height / 2,
          ),
          type: DisplayFeatureType.fold,
          state: DisplayFeatureState.postureFlat,
        ),
        // Vertical but does not reach the bottom edge.
        DisplayFeature(
          bounds: Rect.fromLTRB(100, 0, 100, size.height / 3),
          type: DisplayFeatureType.fold,
          state: DisplayFeatureState.postureHalfOpened,
        ),
      ];

      expect(_fold(_query(size, ignored)), isNull);
    });
  });

  group('PaneSplit', () {
    PaneSplit resolve(FoldGeometry? fold, {bool collapsed = false}) =>
        PaneSplit.resolve(
          fold: fold,
          preferredLeading: spacing.sidebarWidth,
          railWidth: spacing.railWidth,
          maxLeading: spacing.sidebarPaneMax,
          minTrailing: spacing.chatPaneMin,
          collapsed: collapsed,
        );

    test('Fold 6 unfolded (seamless fold) keeps the token sidebar width', () {
      final fold = _fold(
        _query(foldUnfoldedDp, [_verticalFold(foldUnfoldedDp)]),
      );
      final split = resolve(fold);

      expect(split.snappedToFold, isFalse);
      expect(split.leadingWidth, spacing.sidebarWidth);
      expect(split.hingeGap, 0);
    });

    test('an occluding hinge becomes dead space between the panes', () {
      final fold = _fold(
        _query(foldUnfoldedDp, [_verticalFold(foldUnfoldedDp, width: 24)]),
      );
      final split = resolve(fold);

      expect(split.snappedToFold, isTrue);
      expect(split.hingeGap, 24);
      expect(split.leadingWidth, fold!.leftWidth);
      // Both panes stay inside their limits.
      expect(split.leadingWidth, lessThanOrEqualTo(spacing.sidebarPaneMax));
      expect(
        foldUnfoldedDp.width - split.leadingWidth - split.hingeGap,
        greaterThanOrEqualTo(spacing.chatPaneMin),
      );
    });

    test('a fold that would starve the chat pane is ignored', () {
      // 1400 dp wide: the left pane (700) is wider than sidebarPaneMax.
      const wide = Size(1400, 900);
      final fold = _fold(_query(wide, [_verticalFold(wide)]));
      expect(resolve(fold).snappedToFold, isFalse);
      expect(resolve(fold).leadingWidth, spacing.sidebarWidth);

      // 700 dp wide: the right pane (350) is under chatPaneMin.
      const narrow = Size(700, 900);
      final tightFold = _fold(_query(narrow, [_verticalFold(narrow)]));
      expect(resolve(tightFold).snappedToFold, isFalse);
    });

    test('an occluding hinge overrides a collapsed sidebar', () {
      final fold = _fold(
        _query(foldUnfoldedDp, [_verticalFold(foldUnfoldedDp, width: 24)]),
      );
      final split = resolve(fold, collapsed: true);

      expect(split.useRail, isFalse);
      expect(split.leadingWidth, fold!.leftWidth);
      expect(split.hingeGap, 24);
    });
  });

  group('FoldGeometry.of', () {
    testWidgets('reads the fold from the window', (tester) async {
      FoldGeometry? seen;
      await tester.pumpWidget(
        MediaQuery(
          data: _query(foldUnfoldedDp, [
            _verticalFold(foldUnfoldedDp, width: 24),
          ]),
          child: Builder(
            builder: (context) {
              seen = FoldGeometry.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(seen?.hingeWidth, 24);
      expect(seen?.occludes, isTrue);
    });

    testWidgets('does not rebuild its reader on keyboard frames', (
      tester,
    ) async {
      // A full `MediaQuery.of` would depend on the insets too, and the shell
      // would rebuild on every frame of the keyboard animation. The engine
      // hands a new feature list over with each metrics change (as `host`
      // does), so the scope compares the fold by value.
      _Reader.builds = 0;
      Widget host(double keyboard) => MediaQuery(
        data: MediaQueryData(
          size: foldUnfoldedDp,
          viewInsets: EdgeInsets.only(bottom: keyboard),
          displayFeatures: [_verticalFold(foldUnfoldedDp, width: 24)],
        ),
        child: const FoldScope(child: _Reader()),
      );

      await tester.pumpWidget(host(0));
      expect(_Reader.builds, 1);
      await tester.pumpWidget(host(120));
      await tester.pumpWidget(host(300));
      expect(_Reader.builds, 1);
    });
  });
}

/// A `const` reader, so only an inherited-widget dependency can rebuild it.
class _Reader extends StatelessWidget {
  const _Reader();

  static int builds = 0;

  @override
  Widget build(BuildContext context) {
    builds++;
    FoldGeometry.of(context);
    return const SizedBox.shrink();
  }
}
