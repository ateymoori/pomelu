import 'dart:async';

import 'package:flutter_map_location_marker/flutter_map_location_marker.dart'
    as lm;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/app_config.dart';

/// Where the map opens before the phone's location is known.
const LatLng worldCenter = LatLng(
  AppConfig.mapWorldLatitude,
  AppConfig.mapWorldLongitude,
);

/// The numbers of [point] as a message carries them, to
/// [AppConfig.coordinateDigits] places.
({String lat, String lng}) coordinatesOf(LatLng point) => (
  lat: point.latitude.toStringAsFixed(AppConfig.coordinateDigits),
  lng: point.longitude.toStringAsFixed(AppConfig.coordinateDigits),
);

/// Turns a point into a one-line address; null when there is none.
typedef AddressLookup = Future<String?> Function(LatLng point);

/// The phone's own geocoder: free, no key, in the phone's language.
Future<String?> lookupAddress(LatLng point) async {
  final marks = await Geocoding().placemarkFromCoordinates(
    point.latitude,
    point.longitude,
  );
  return marks.isEmpty ? null : formatPlacemark(marks.first);
}

/// A one-line address from what the geocoder knows. Nothing is glued by one
/// country's rule: a full address line (Android puts one in `street`) wins,
/// else the known parts are joined with ", ".
String? formatPlacemark(Placemark p) {
  String clean(String? s) => (s ?? '').trim();
  final street = clean(p.street);
  if (street.contains(',')) return street;
  final place = street.isNotEmpty ? street : clean(p.name);
  final city = clean(p.locality).isNotEmpty
      ? clean(p.locality)
      : clean(p.subAdministrativeArea);
  final parts = <String>{
    if (place.isNotEmpty)
      place
    else ...[
      clean(p.thoroughfare),
      clean(p.subThoroughfare),
    ],
    clean(p.postalCode),
    city,
    clean(p.country),
  }..remove('');
  return parts.isEmpty ? null : parts.join(', ');
}

/// The phone's positions, from one location request.
///
/// The marker package asks for the current position and opens a stream at
/// once; on Android each is a request, so the system can ask twice. This
/// starts the stream only, after the last known fix. Errors follow the
/// marker package, so its layer shows them.
Stream<Position?> phonePositions() {
  StreamSubscription<Position>? positions;
  late final StreamController<Position?> out;
  void fail(Object error) {
    if (!out.isClosed) out.addError(error);
  }

  Future<void> start() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        // The stream still opens, so the system can offer to switch it on.
        fail(const lm.ServiceDisabledException());
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        fail(const lm.PermissionRequestingException());
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return fail(const lm.PermissionDeniedException());
      }
      final last = await Geolocator.getLastKnownPosition();
      if (out.isClosed) return;
      if (last != null) out.add(last);
      positions = Geolocator.getPositionStream().listen(out.add, onError: fail);
    } on Exception catch (e) {
      fail(e);
    }
  }

  out = StreamController<Position?>(
    onListen: () => unawaited(start()),
    onCancel: () async {
      await positions?.cancel();
      await out.close();
    },
  );
  return out.stream;
}
