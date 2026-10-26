import 'package:geolocator/geolocator.dart';

import '../utils/app_logger.dart';

/// Opens this app's page in the system settings, where a refused permission
/// (location, microphone, notifications on iOS) is given again. False when
/// it could not.
Future<bool> openAppSettings() async {
  try {
    return await Geolocator.openAppSettings();
  } on Object catch (e) {
    log.w('app settings did not open', error: e);
    return false;
  }
}
