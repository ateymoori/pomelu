import 'dart:typed_data';

import 'app_logger.dart';

/// Bytes behind a `data:` URL, or null when it is not parseable.
Uint8List? decodeDataUrl(String? dataUrl) {
  if (dataUrl == null || dataUrl.isEmpty) return null;
  try {
    return UriData.parse(dataUrl).contentAsBytes();
  } on FormatException catch (e) {
    log.w('bad data url', error: e);
    return null;
  }
}
