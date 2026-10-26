import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../hermes/api/hermes_api.dart';
import '../../../../hermes/client/hermes_client.dart';
import '../../data/media_cache.dart';
import 'media_strip.dart';

/// Where the picture of [item] is: a file on the phone, bytes in memory, or
/// a web address. A gateway picture is fetched to a file first. Throws when
/// there is none.
Future<({String? path, Uint8List? bytes, String? url})> _sourceOf(
  MediaItem item,
  HermesClient? client,
  HermesApi? api,
) async {
  if (item.localPath case final path?) {
    return (path: path, bytes: null, url: null);
  }
  if (item.provider case MemoryImage(:final bytes)) {
    return (path: null, bytes: bytes, url: null);
  }
  if (item.sourceUrl case final url?) {
    return (path: null, bytes: null, url: url);
  }
  final remote = item.remotePath;
  if (client == null || api == null || remote == null) {
    throw StateError('no source for ${item.fileName}');
  }
  final file = await MediaCache.fetch(client, api, remote, item.fileName);
  return (path: file.path, bytes: null, url: null);
}

/// Copies [item] into the gallery through [sink], from wherever it lives.
/// Throws when the picture cannot be reached: a silent failure would leave
/// the user believing it is on their phone.
Future<void> saveToGallery(
  MediaItem item, {
  HermesClient? client,
  HermesApi? api,
  GallerySink sink = MediaCache.gallery,
  Dio? http,
}) async {
  final name = item.fileName;
  final source = await _sourceOf(item, client, api);
  if (source.path case final path?) return sink(path: path, name: name);
  if (source.bytes case final bytes?) return sink(bytes: bytes, name: name);
  await sink(
    bytes: await MediaCache.download(source.url!, http: http),
    name: name,
  );
}

/// Hands [item] to the share sheet: its file, or a web picture's address.
Future<void> sharePicture(
  MediaItem item, {
  HermesClient? client,
  HermesApi? api,
}) async {
  final source = await _sourceOf(item, client, api);
  if (source.path case final path?) return MediaCache.shareFile(File(path));
  if (source.bytes case final bytes?) {
    return MediaCache.shareBytes(bytes, item.fileName);
  }
  await MediaCache.shareText(source.url!);
}
