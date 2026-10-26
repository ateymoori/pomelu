import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../data/location.dart';

/// The point under the pin and what is known of its address.
typedef LocationSpot = ({LatLng point, String? address, bool resolving});

/// The pin. Its tip, not its middle, is on the map's center.
class LocationPin extends StatelessWidget {
  const LocationPin({super.key});

  @override
  Widget build(BuildContext context) {
    final size = context.spacing.xxl;
    return Padding(
      padding: EdgeInsets.only(bottom: size),
      child: Icon(
        CupertinoIcons.location_solid,
        size: size,
        color: context.colors.accent,
      ),
    );
  }
}

/// The bar next to the map: the pin's address and coordinates, and Share.
///
/// Under the map on a portrait screen, beside it on a landscape one; its body
/// scrolls if the text is too large for the room it has.
class LocationSpotBar extends StatelessWidget {
  const LocationSpotBar({
    required this.spot,
    required this.off,
    required this.onShare,
    super.key,
    this.onSettings,
  });

  /// The pin's point and address.
  final LocationSpot spot;

  /// The phone's location is denied, off, or failed.
  final bool off;

  /// Puts the place in the message. Works on the coordinates alone while the
  /// address is not there (none was found, or the lookup failed or timed out).
  final VoidCallback onShare;

  /// Opens the system settings; set when the location permission was
  /// refused, so the user has a way to give it back.
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final spacing = context.spacing;
    final theme = Theme.of(context).textTheme;
    final (:lat, :lng) = coordinatesOf(spot.point);
    final address = spot.address;
    final addressStyle = theme.titleMedium?.copyWith(
      color: address == null ? colors.textSecondary : null,
    );
    final lineHeight = MediaQuery.textScalerOf(context)
        .scale((addressStyle?.fontSize ?? 0) * (addressStyle?.height ?? 1));

    return AppGlass.bar(
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: lineHeight * AppConfig.locationAddressLines,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: spot.resolving
                      ? Semantics(
                          label: l10n.locationResolving,
                          child: const ShimmerLine(),
                        )
                      : Text(
                          address ?? l10n.locationNoAddress,
                          key: const Key('location-address'),
                          style: addressStyle,
                          maxLines: AppConfig.locationAddressLines,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),
              SizedBox(height: spacing.xxs),
              Text(
                '$lat, $lng',
                key: const Key('location-coordinates'),
                textDirection: TextDirection.ltr,
                style: theme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontFeatures: context.textScale.tabularFigures,
                ),
              ),
              if (off) ...[
                SizedBox(height: spacing.xs),
                Text(
                  l10n.locationOff,
                  style: theme.bodySmall?.copyWith(color: colors.warning),
                ),
                if (onSettings != null)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      key: const Key('location-settings'),
                      onPressed: onSettings,
                      child: Text(l10n.actionOpenSettings),
                    ),
                  ),
              ],
              SizedBox(height: spacing.md),
              FilledButton(
                key: const Key('location-share'),
                onPressed: spot.resolving ? null : onShare,
                child: Text(l10n.locationShare),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Says the map could not load (offline, say): the map may be blank, but the
/// pin and its coordinates still work.
class MapTilesNotice extends StatelessWidget {
  const MapTilesNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: AppGlass.capsule(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.xs,
        ),
        child: Text(
          context.l10n.locationTilesFailed,
          key: const Key('location-tiles-failed'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
