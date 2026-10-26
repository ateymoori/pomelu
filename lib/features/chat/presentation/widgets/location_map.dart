import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../data/location.dart';

/// The picker's map: OpenStreetMap tiles, darkened in the dark theme, the
/// phone's dot from [positions], and the tiles' attribution.
class LocationMap extends StatelessWidget {
  const LocationMap({
    super.key,
    required this.controller,
    required this.positions,
    required this.onReady,
    required this.onMoved,
    required this.onTileError,
    this.tileProvider,
  });

  final MapController controller;
  final Stream<LocationMarkerPosition?> positions;
  final VoidCallback onReady;
  final PositionCallback onMoved;
  final ErrorTileCallBack onTileError;

  /// Where tiles come from; null uses the network.
  final TileProvider? tileProvider;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final surfaces = context.surfaces;
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: worldCenter,
        initialZoom: AppConfig.mapWorldZoom,
        maxZoom: AppConfig.mapMaxZoom,
        backgroundColor: surfaces.surface,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onMapReady: onReady,
        onPositionChanged: onMoved,
      ),
      children: [
        TileLayer(
          urlTemplate: AppConfig.mapTiles,
          userAgentPackageName: AppConfig.mapUserAgentPackage,
          tileProvider: tileProvider,
          errorTileCallback: onTileError,
          tileBuilder: Theme.of(context).brightness == Brightness.dark
              ? darkModeTileBuilder
              : null,
        ),
        CurrentLocationLayer(
          positionStream: positions,
          style: LocationMarkerStyle(
            marker: DefaultLocationMarker(color: colors.accent),
            accuracyCircleColor: colors.accentSoft,
            headingSectorColor: colors.accent,
          ),
        ),
        RichAttributionWidget(
          alignment: AttributionAlignment.bottomLeft,
          showFlutterMapAttribution: false,
          popupBackgroundColor: surfaces.surfaceElevated,
          attributions: [
            TextSourceAttribution(
              AppConfig.mapAttribution,
              onTap: () => unawaited(
                launchUrl(
                  Uri.parse(AppConfig.mapAttributionUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
