import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../utils/l10n_ext.dart';
import 'app_surface.dart';
import 'remove_badge.dart';
import 'tap_ink.dart';

/// Decode headroom over the tile's edge, so the cropped axis of a wide
/// picture stays sharp.
const double _decodeHeadroom = 3;

/// One square, cover-cropped picture tile with a hairline edge. The picture
/// is decoded at tile size, never at the camera's: a 12 MP picture would
/// cost about 48 MB. [onTap] adds ink, [onRemove] a remove badge.
class MediaTile extends StatelessWidget {
  const MediaTile({
    required this.image,
    required this.label,
    super.key,
    this.onTap,
    this.onRemove,
    this.errorBuilder,
  });

  final ImageProvider<Object> image;

  /// The picture's name, for a screen reader.
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  /// Stands in for a picture that cannot be decoded; a broken-picture mark
  /// by default.
  final WidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final radius = BorderRadius.circular(context.radii.md);
    final picture = Image(
      image: ResizeImage.resizeIfNeeded(
        (spacing.mediaTile *
                MediaQuery.devicePixelRatioOf(context) *
                _decodeHeadroom)
            .round(),
        null,
        image,
      ),
      fit: BoxFit.cover,
      errorBuilder: (context, _, _) =>
          errorBuilder?.call(context) ??
          Icon(CupertinoIcons.photo, color: context.colors.textTertiary),
    );
    final tap = onTap;
    final tile = Semantics(
      image: true,
      button: tap != null,
      label: label,
      child: AppSurface(
        color: Colors.transparent,
        borderRadius: radius,
        clip: true,
        child: SizedBox.square(
          dimension: spacing.mediaTile,
          child: tap == null ? picture : TapInk(onTap: tap, child: picture),
        ),
      ),
    );
    final remove = onRemove;
    if (remove == null) return tile;
    return Stack(
      children: [
        tile,
        RemoveBadge(label: context.l10n.attachRemove, onPressed: remove),
      ],
    );
  }
}
