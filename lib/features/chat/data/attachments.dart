import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/app_logger.dart';
import '../../../hermes/api/hermes_api.dart';
import '../../../hermes/hermes_constants.dart';
import '../../../hermes/hermes_failure.dart';
import '../../../hermes/models/local_attachment.dart';
import '../domain/new_id.dart';

/// What the composer's `+` adds: files, or a place on the map.
enum AttachSource { photo, camera, video, file, location }

/// Why a file was left out of a turn.
enum AttachRefusal { tooMany, tooLarge, batchTooLarge }

typedef Refused = ({LocalAttachment file, AttachRefusal reason});

/// Files of a turn: picking them, the gateway's limits, and the upload.
abstract final class Attachments {
  /// Last path segment, with either separator.
  static String basename(String path) =>
      path.split(RegExp(r'[/\\]')).where((s) => s.isNotEmpty).lastOrNull ??
      path;

  static Future<LocalAttachment?> fromPath(
    String path, {
    String? name,
    String? mimeHint,
    Duration? duration,
    AttachmentKind? kind,
  }) async {
    final file = File(path);
    if (path.isEmpty || !file.existsSync()) return null;
    final mime = LocalAttachment.mimeForPath(path, hint: mimeHint);
    return LocalAttachment(
      id: newId(),
      path: path,
      name: name == null || name.isEmpty ? basename(path) : name,
      mimeType: mime,
      sizeBytes: await file.length(),
      kind: kind ?? LocalAttachment.kindForMime(mime),
      duration: duration,
    );
  }

  /// Runs the picker of [source]; empty when it was dismissed. Throws what
  /// the picker throws (no camera, a refused permission).
  static Future<List<LocalAttachment>> pick(AttachSource source) async {
    final picker = ImagePicker();
    final List<({String path, String name, String? mime})>
    files = switch (source) {
      AttachSource.photo => [
        for (final f in await picker.pickMultiImage())
          (path: f.path, name: f.name, mime: f.mimeType),
      ],
      AttachSource.camera => [
        if (await picker.pickImage(source: ImageSource.camera) case final f?)
          (path: f.path, name: f.name, mime: f.mimeType),
      ],
      AttachSource.video => [
        if (await picker.pickVideo(source: ImageSource.gallery) case final f?)
          (path: f.path, name: f.name, mime: f.mimeType),
      ],
      AttachSource.file => [
        for (final f in await FilePicker.pickFiles())
          if (f.path != null) (path: f.path!, name: f.name, mime: null),
      ],
      AttachSource.location => const [],
    };
    return [
      for (final f in files)
        ?await fromPath(f.path, name: f.name, mimeHint: f.mime),
    ];
  }

  static int limitFor(LocalAttachment a) => switch (a.kind) {
    AttachmentKind.image => HermesLimits.maxImageBytes,
    AttachmentKind.audio => HermesLimits.maxAudioBytes,
    AttachmentKind.video || AttachmentKind.file => HermesLimits.maxFileBytes,
  };

  static bool _overBatch(Iterable<LocalAttachment> files) =>
      files.fold<int>(0, (sum, a) => sum + a.sizeBytes) >
      HermesLimits.maxTotalAttachmentBytes;

  /// [picked] added to [have] while they fit. A full turn takes no more; a
  /// file over its own limit is only skipped. Picked and shared files alike.
  static ({List<LocalAttachment> accepted, List<Refused> refused}) admit(
    List<LocalAttachment> have,
    List<LocalAttachment> picked,
  ) {
    final next = [...have];
    final refused = <Refused>[];
    for (final a in picked) {
      if (next.length >= HermesLimits.maxAttachmentsPerMessage) {
        refused.add((file: a, reason: AttachRefusal.tooMany));
        break;
      }
      if (a.sizeBytes > limitFor(a)) {
        refused.add((file: a, reason: AttachRefusal.tooLarge));
        continue;
      }
      // Each file rides in one base64 frame: the total is a real limit.
      if (_overBatch([...next, a])) {
        refused.add((file: a, reason: AttachRefusal.batchTooLarge));
        break;
      }
      next.add(a);
    }
    return (accepted: List.unmodifiable(next), refused: refused);
  }

  /// Deletes the copies the pickers or the share sheet made in the temp
  /// folder. A file anywhere else is the user's and is never touched.
  static Future<void> discardCopies(Iterable<LocalAttachment> files) async {
    if (files.isEmpty) return;
    try {
      final root = '${(await getTemporaryDirectory()).path}/';
      for (final a in files) {
        if (a.path.startsWith(root)) await File(a.path).delete();
      }
    } on Object catch (e) {
      log.d('copies not deleted: $e');
    }
  }

  /// Uploads [files] to [runtimeId]. Returns the `@file:` references for the
  /// prompt; pictures go in as vision inputs and need none.
  static Future<List<String>> stage(
    HermesApi api,
    String runtimeId,
    List<LocalAttachment> files, {
    void Function(int done, String name)? onProgress,
  }) async {
    if (_overBatch(files)) {
      throw const ServerFailure(
        'attachments exceed the per-turn total',
        httpStatus: HermesHttpStatus.payloadTooLarge,
      );
    }
    final refs = <String>[];
    for (final (i, a) in files.indexed) {
      onProgress?.call(i, a.name);
      final bytes = await read(a);
      if (a.isImage) {
        await api.attachImageBytes(
          runtimeId: runtimeId,
          bytes: bytes,
          filename: a.name,
        );
      } else {
        final r = await api.attachFile(
          runtimeId: runtimeId,
          bytes: bytes,
          name: a.name,
          mimeType: a.mimeType,
        );
        if (r.refText.isNotEmpty) refs.add(r.refText);
      }
    }
    return refs;
  }

  /// The bytes of [a], its size checked on disk first. A file that is gone
  /// is a [ProtocolFailure]: a reconnect cannot bring it back.
  static Future<Uint8List> read(LocalAttachment a) async {
    final file = File(a.path);
    try {
      if (await file.length() > limitFor(a)) {
        throw ServerFailure(
          'attachment over its size limit: ${a.name}',
          rpcCode: a.isImage ? HermesProtocol.errImageTooLarge : null,
          httpStatus: a.isImage ? null : HermesHttpStatus.payloadTooLarge,
        );
      }
      return await file.readAsBytes();
    } on FileSystemException {
      throw ProtocolFailure('attachment file is gone: ${a.name}');
    }
  }
}
