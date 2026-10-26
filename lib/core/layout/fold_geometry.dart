import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:flutter/widgets.dart';

/// How close to an edge a display feature still counts as spanning it.
const double _spanTolerance = 1;

/// A vertical fold or hinge that splits the window into a left and a right
/// pane (`MediaQuery.displayFeatures`). A Galaxy Z Fold reports a seamless
/// fold of zero width; a hinged device a `hinge` that hides pixels.
@immutable
class FoldGeometry {
  const FoldGeometry({
    required this.leftWidth,
    required this.rightWidth,
    required this.hingeWidth,
    required this.occludes,
  });

  final double leftWidth;
  final double rightWidth;

  /// 0 for a seamless fold.
  final double hingeWidth;

  /// The feature hides the pixels it covers: paint nothing under it.
  final bool occludes;

  /// The fold of [context], or null (phone, folded Fold, horizontal fold).
  /// Under a [FoldScope] the caller rebuilds only when the fold changes, not
  /// on every inset frame (the keyboard sliding up).
  static FoldGeometry? of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FoldInherited>();
    if (scope != null) return scope.fold;
    return resolve(
      size: MediaQuery.sizeOf(context),
      features: MediaQuery.displayFeaturesOf(context),
    );
  }

  /// The fold in [features] for a window of [size], or null.
  static FoldGeometry? resolve({
    required Size size,
    required List<DisplayFeature> features,
  }) {
    if (size.isEmpty) return null;
    for (final feature in features) {
      if (feature.type == DisplayFeatureType.cutout) continue;
      final bounds = feature.bounds;
      // A vertical band over the full height of the window.
      if (bounds.width >= bounds.height) continue;
      if (bounds.top > _spanTolerance) continue;
      if (bounds.bottom < size.height - _spanTolerance) continue;
      final left = bounds.left.clamp(0.0, size.width);
      final right = (size.width - bounds.right).clamp(0.0, size.width);
      if (left <= 0 || right <= 0) continue;
      return FoldGeometry(
        leftWidth: left,
        rightWidth: right,
        hingeWidth: bounds.width.clamp(0.0, size.width),
        occludes: feature.type == DisplayFeatureType.hinge || bounds.width > 0,
      );
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is FoldGeometry &&
      other.leftWidth == leftWidth &&
      other.rightWidth == rightWidth &&
      other.hingeWidth == hingeWidth &&
      other.occludes == occludes;

  @override
  int get hashCode => Object.hash(leftWidth, rightWidth, hingeWidth, occludes);
}

/// Provides the window's [FoldGeometry] below and wakes its readers only when
/// the fold changes. Install once, above the navigator.
class FoldScope extends StatelessWidget {
  const FoldScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => _FoldInherited(
    fold: FoldGeometry.resolve(
      size: MediaQuery.sizeOf(context),
      features: MediaQuery.displayFeaturesOf(context),
    ),
    child: child,
  );
}

class _FoldInherited extends InheritedWidget {
  const _FoldInherited({required this.fold, required super.child});

  final FoldGeometry? fold;

  @override
  bool updateShouldNotify(_FoldInherited oldWidget) => oldWidget.fold != fold;
}

/// Widths of the two-pane shell.
@immutable
class PaneSplit {
  const PaneSplit({
    required this.leadingWidth,
    required this.hingeGap,
    required this.snappedToFold,
    required this.useRail,
  });

  /// Width of the sidebar (or rail).
  final double leadingWidth;

  /// Dead space between the panes, over an occluding hinge.
  final double hingeGap;
  final bool snappedToFold;
  final bool useRail;

  /// The boundary snaps onto an occluding hinge when that leaves a sidebar
  /// between [railWidth] and [maxLeading] and a chat of at least
  /// [minTrailing]; else the sidebar keeps [preferredLeading], or is a rail
  /// when [collapsed]. A seamless fold is no reason to give the sidebar half
  /// the screen; a hinge wins over [collapsed], or the chat would sit under
  /// it.
  static PaneSplit resolve({
    required FoldGeometry? fold,
    required double preferredLeading,
    required double railWidth,
    required double maxLeading,
    required double minTrailing,
    bool collapsed = false,
  }) {
    final canSnap =
        fold != null &&
        fold.occludes &&
        fold.leftWidth >= railWidth &&
        fold.leftWidth <= maxLeading &&
        fold.rightWidth >= minTrailing;
    if (!canSnap) {
      return PaneSplit(
        leadingWidth: collapsed ? railWidth : preferredLeading,
        hingeGap: 0,
        snappedToFold: false,
        useRail: collapsed,
      );
    }
    return PaneSplit(
      leadingWidth: fold.leftWidth,
      hingeGap: fold.hingeWidth,
      snappedToFold: true,
      useRail: false,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PaneSplit &&
      other.leadingWidth == leadingWidth &&
      other.hingeGap == hingeGap &&
      other.snappedToFold == snappedToFold &&
      other.useRail == useRail;

  @override
  int get hashCode =>
      Object.hash(leadingWidth, hingeGap, snappedToFold, useRail);
}
