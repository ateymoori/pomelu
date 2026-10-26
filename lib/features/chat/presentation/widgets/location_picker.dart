import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/platform/app_settings.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../data/location.dart';
import 'location_map.dart';
import 'location_spot_bar.dart';

/// Opens the map. Returns the message text for the place the user chose:
/// its address, latitude and longitude. Null when closed.
Future<String?> pickLocation(BuildContext context) => Navigator.of(context)
    .push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const LocationPicker(),
      ),
    );

/// A full-screen map with a fixed pin at its center. The map opens on the
/// phone's location; the user moves the map until the pin is on the place.
class LocationPicker extends StatefulWidget {
  const LocationPicker({
    super.key,
    this.lookup = lookupAddress,
    this.positions,
    this.tileProvider,
    this.openSettings = openAppSettings,
  });

  /// Finds the address of the pin's point.
  final AddressLookup lookup;

  /// The phone's location; null uses the GPS. Tests give their own.
  final Stream<LocationMarkerPosition?>? positions;

  /// Where tiles come from; null uses the network.
  final TileProvider? tileProvider;

  /// Opens the app's system settings, where a refused location permission is
  /// given again.
  final Future<bool> Function() openSettings;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final MapController _map = MapController();
  final ValueNotifier<LocationSpot> _spot = ValueNotifier((
    point: worldCenter,
    address: null,
    resolving: false,
  ));

  late final Stream<LocationMarkerPosition?> _positions =
      (widget.positions ??
              const LocationMarkerDataStreamFactory()
                  .fromGeolocatorPositionStream(stream: phonePositions()))
          .asBroadcastStream(onCancel: (sub) => unawaited(sub.cancel()));
  StreamSubscription<LocationMarkerPosition?>? _fixes;
  Timer? _debounce;
  int _lookups = 0;
  bool _ready = false;
  bool _moved = false;

  LatLng? _me;

  bool _off = false;

  bool _denied = false;

  bool _tilesFailed = false;

  @override
  void initState() {
    super.initState();
    _fixes = _positions.listen(_onFix, onError: _onFixError);
  }

  @override
  void dispose() {
    unawaited(_fixes?.cancel());
    _debounce?.cancel();
    _spot.dispose();
    _map.dispose();
    super.dispose();
  }

  void _onFix(LocationMarkerPosition? p) {
    if (p == null || !mounted) return;
    final first = _me == null;
    setState(() {
      _me = p.latLng;
      _off = false;
    });
    // The first fix brings the map to the phone, unless the user already
    // went somewhere.
    if (first && !_moved) _goToMe();
  }

  void _onFixError(Object e) {
    // Sent while the permission dialog is up; the answer comes next.
    if (e is PermissionRequestingException) return;
    log.d('location unavailable: $e');
    if (!mounted) return;
    setState(() {
      _off = true;
      _denied = e is PermissionDeniedException;
    });
  }

  void _onTileError(TileImage tile, Object error, StackTrace? stackTrace) {
    log.d('map tile failed: $error');
    if (!_tilesFailed && mounted) setState(() => _tilesFailed = true);
  }

  void _goToMe() {
    final me = _me;
    if (me == null || !_ready) return;
    final zoom = _map.camera.zoom;
    _map.move(
      me,
      zoom < AppConfig.mapPlaceZoom ? AppConfig.mapPlaceZoom : zoom,
    );
  }

  void _onMoved(MapCamera camera, bool hasGesture) {
    if (hasGesture) _moved = true;
    _spot.value = (point: camera.center, address: null, resolving: true);
    _debounce?.cancel();
    _debounce = Timer(AppConfig.addressLookupDebounce, _resolve);
  }

  Future<void> _resolve() async {
    final id = ++_lookups;
    final point = _spot.value.point;
    String? address;
    try {
      address = await widget
          .lookup(point)
          .timeout(AppConfig.addressLookupTimeout);
    } on Object catch (e) {
      log.d('no address for $point: $e');
    }
    // A newer move started a newer lookup; this answer is stale.
    if (!mounted || id != _lookups) return;
    _spot.value = (point: point, address: address, resolving: false);
  }

  void _share() {
    final l10n = context.l10n;
    final spot = _spot.value;
    final (:lat, :lng) = coordinatesOf(spot.point);
    final address = spot.address;
    Navigator.of(context).pop(
      address == null
          ? l10n.locationMessageNoAddress(lat, lng)
          : l10n.locationMessage(address, lat, lng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final map = LocationMap(
      controller: _map,
      positions: _positions,
      tileProvider: widget.tileProvider,
      onReady: () {
        _ready = true;
        _goToMe();
      },
      onMoved: _onMoved,
      onTileError: _onTileError,
    );

    return Scaffold(
      appBar: readingAppBar(
        context,
        title: l10n.locationTitle,
        onClose: () => Navigator.of(context).pop(),
      ),
      // One `Flex` whichever way it points, so turning the phone keeps the
      // map (and where it is looking) instead of building a new one: the bar
      // goes under the map on a tall screen and beside it on a wide one.
      body: LayoutBuilder(
        builder: (context, box) {
          final wide = box.maxWidth > box.maxHeight;
          return Flex(
            direction: wide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    map,
                    const IgnorePointer(child: Center(child: LocationPin())),
                    if (_tilesFailed)
                      PositionedDirectional(
                        top: spacing.gutter,
                        start: spacing.gutter,
                        end: spacing.gutter,
                        child: const MapTilesNotice(),
                      ),
                    PositionedDirectional(
                      end: spacing.gutter,
                      bottom: spacing.gutter,
                      child: AppIconButton(
                        key: const Key('location-mine'),
                        icon: CupertinoIcons.location_fill,
                        tooltip: l10n.locationMine,
                        onPressed: _me == null ? null : _goToMe,
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                // Beside the map a side pane wide; under it never more than
                // a share of the height, so the map keeps its room and the
                // bar scrolls instead.
                constraints: wide
                    ? BoxConstraints.tightFor(width: spacing.sidebarWidth)
                    : BoxConstraints(
                        maxHeight: box.maxHeight * spacing.sheetMaxFraction,
                      ),
                child: ValueListenableBuilder<LocationSpot>(
                  valueListenable: _spot,
                  builder: (context, spot, _) => LocationSpotBar(
                    spot: spot,
                    off: _off,
                    onShare: _share,
                    onSettings: _denied
                        ? () => unawaited(widget.openSettings())
                        : null,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
