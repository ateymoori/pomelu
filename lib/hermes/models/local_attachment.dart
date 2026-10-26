import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mime/mime.dart';

import 'json_converters.dart';

part 'local_attachment.freezed.dart';
part 'local_attachment.g.dart';

/// How an attachment is sent and shown.
enum AttachmentKind {
  /// Sent with `image.attach_bytes`; the model sees it.
  image,

  /// A video file.
  video,

  /// A sound file or a voice note.
  audio,

  /// Anything else.
  file,
}

/// A file on this device that the user wants to send. Its JSON is how the
/// app stores a draft or a queued turn, never sent to the gateway.
@freezed
abstract class LocalAttachment with _$LocalAttachment {
  const LocalAttachment._();

  const factory LocalAttachment({
    @LooseString() required String id,
    @LooseString() required String path,
    @LooseString() required String name,
    @JsonKey(name: 'mime_type') @LooseString() required String mimeType,
    @JsonKey(name: 'size_bytes') @LooseInt() required int sizeBytes,
    @JsonKey(unknownEnumValue: AttachmentKind.file)
    @Default(AttachmentKind.file)
    AttachmentKind kind,
    @JsonKey(name: 'duration_ms', includeIfNull: false)
    @DurationMillis()
    Duration? duration,
    @JsonKey(name: 'thumbnail_path', includeIfNull: false)
    String? thumbnailPath,
  }) = _LocalAttachment;

  factory LocalAttachment.fromJson(Map<String, dynamic> json) =>
      _$LocalAttachmentFromJson(json);

  /// The kind a file of [mime] is sent as.
  static AttachmentKind kindForMime(String mime) {
    if (mime.startsWith('image/')) return AttachmentKind.image;
    if (mime.startsWith('video/')) return AttachmentKind.video;
    if (mime.startsWith('audio/')) return AttachmentKind.audio;
    return AttachmentKind.file;
  }

  /// The MIME type of [path]: [hint] when it names one, else a guess from
  /// the extension.
  static String mimeForPath(String path, {String? hint}) =>
      (hint != null && hint.isNotEmpty && hint != '*/*')
      ? hint
      : (lookupMimeType(path) ?? 'application/octet-stream');

  bool get isImage => kind == AttachmentKind.image;

  bool get isAudio => kind == AttachmentKind.audio;
}
