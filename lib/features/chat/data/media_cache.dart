import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/stable_hash.dart';
import '../../../hermes/api/hermes_api.dart';
import '../../../hermes/client/hermes_client.dart';
import '../domain/new_id.dart';

/// Writes a picture to the device gallery: a file, or bytes.
typedef GallerySink = Future<void> Function({
  String? path,
  Uint8List? bytes,
  String? name,
});

/// Gateway media on the phone: downloaded into a cache folder, opened,
/// shared, saved to a folder, and saved to the gallery.
///
/// A file is named by its name plus a stable hash of its source, so two
/// `report.pdf` never collide and a file cached last time is found again. A
/// download writes under a name of its own and is renamed when whole.
abstract final class MediaCache {
  static Future<Directory> _dir() async {
    final dir = Directory(
      '${(await getTemporaryDirectory()).path}/hermes_media',
    );
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  /// Start-up clean-up of files older than [AppConfig.mediaCacheMaxAge].
  static Future<void> pruneStale() async {
    try {
      final cutoff = DateTime.now().subtract(AppConfig.mediaCacheMaxAge);
      await for (final f in (await _dir()).list()) {
        if (f is File && f.lastModifiedSync().isBefore(cutoff)) {
          await f.delete();
        }
      }
    } on Object catch (e) {
      log.w('media cache clean-up failed', error: e);
    }
  }

  /// Collision-free, filesystem-safe name for [uri].
  @visibleForTesting
  static String cacheName(Uri uri, String fileName) {
    final safe = fileName.replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
    final stem = safe.isEmpty ? 'file' : safe;
    final hash = stableHash(uri.toString()).toRadixString(16);
    final dot = stem.lastIndexOf('.');
    return dot > 0
        ? '${stem.substring(0, dot)}-$hash${stem.substring(dot)}'
        : '$stem-$hash';
  }

  static final Map<String, Future<File>> _inflight = {};

  /// The gateway file [path], downloaded unless already cached.
  static Future<File> fetch(
    HermesClient client,
    HermesApi api,
    String path,
    String fileName,
  ) async {
    final uri = api.mediaDownloadUrl(path);
    final file = File('${(await _dir()).path}/${cacheName(uri, fileName)}');
    return _inflight[file.path] ??= () async {
      try {
        if (file.existsSync() && await file.length() > 0) return file;
        final temp = File('${file.path}.${newId()}');
        try {
          await client.http.download(uri, temp.path);
          return await temp.rename(file.path);
        } on Object {
          // Whatever a failed transfer left is not a file.
          for (final f in [temp, File('${temp.path}.part')]) {
            if (f.existsSync()) await f.delete();
          }
          rethrow;
        }
      } finally {
        unawaited(_inflight.remove(file.path));
      }
    }();
  }

  /// MIME types to open [name] as, best first: its own, then plain text for
  /// a text format few apps claim (Markdown, JSON, YAML, code), then any
  /// app. Empty for an Android package: only an installer the user starts
  /// may open one.
  static List<String> openTypes(String name) {
    final type = lookupMimeType(name) ?? 'application/octet-stream';
    if (type == _apkType) return const [];
    final text =
        type.startsWith('text/') ||
        const ['json', 'xml', 'yaml', 'javascript'].any(type.contains);
    return [type, if (text && type != _plainText) _plainText, _anyType];
  }

  static const _apkType = 'application/vnd.android.package-archive';
  static const _plainText = 'text/plain';
  static const _anyType = '*/*';

  /// Opens [file] in the phone's default app for its type; false when no
  /// app takes it.
  static Future<bool> open(File file) async {
    for (final type in openTypes(file.path)) {
      final result = await OpenFilex.open(file.path, type: type);
      if (result.type == ResultType.done) return true;
      if (result.type != ResultType.noAppToOpen) return false;
    }
    return false;
  }

  /// Lets the user save a copy of [file] as [name] in a folder they pick
  /// (Files on iOS, the system picker on Android); false when they cancel.
  static Future<bool> saveAs(File file, String name) async =>
      await FilePicker.saveFile(
        fileName: name,
        bytes: await file.readAsBytes(),
        mimeType: lookupMimeType(name) ?? 'application/octet-stream',
      ) !=
      null;

  static Future<void> shareFile(File file) =>
      SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));

  static Future<void> shareText(String text) async {
    if (text.trim().isEmpty) return;
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// A picture that came inline is only in memory; the sheet takes files.
  static Future<void> shareBytes(List<int> bytes, String fileName) async {
    final dir = await _dir();
    final name = cacheName(Uri(scheme: 'data', path: newId()), fileName);
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    await shareFile(file);
  }

  /// The real gallery. The album needs a permission on Android 10 the app
  /// does not hold; without it the picture lands in the main folder.
  static Future<void> gallery({
    String? path,
    Uint8List? bytes,
    String? name,
  }) async {
    final album = await Gal.hasAccess(toAlbum: true)
        ? AppConfig.galleryAlbum
        : null;
    if (path != null) return Gal.putImage(path, album: album);
    if (bytes != null) {
      return Gal.putImageBytes(
        bytes,
        album: album,
        name: name ?? 'hermes-${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  /// Bytes behind a plain web URL, for saving a Markdown picture.
  static Future<Uint8List> download(String url, {Dio? http}) async {
    final dio =
        http ??
        Dio(
          BaseOptions(
            connectTimeout: AppConfig.mediaSaveConnectTimeout,
            receiveTimeout: AppConfig.mediaSaveReceiveTimeout,
          ),
        );
    try {
      final r = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = r.data;
      if (data == null || data.isEmpty) throw StateError('empty: $url');
      return Uint8List.fromList(data);
    } finally {
      if (http == null) dio.close();
    }
  }
}
