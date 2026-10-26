import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'attach_result.freezed.dart';
part 'attach_result.g.dart';

/// Result of `image.attach_bytes`.
@freezed
abstract class ImageAttachResult with _$ImageAttachResult {
  const factory ImageAttachResult({
    @LooseBool() @Default(false) bool attached,
    @LooseString() @Default('') String path,
    @LooseString() @Default('') String name,
    @LooseString() @Default('') String text,
    @LooseInt() @Default(0) int count,
    @LooseInt() @Default(0) int bytes,
    int? width,
    int? height,
  }) = _ImageAttachResult;

  factory ImageAttachResult.fromJson(Map<String, dynamic> json) =>
      _$ImageAttachResultFromJson(json);
}

/// Result of `file.attach`. Put [refText] into the prompt text.
@freezed
abstract class FileAttachResult with _$FileAttachResult {
  const factory FileAttachResult({
    @LooseString() @Default('') String name,
    @LooseString() @Default('') String path,
    @JsonKey(name: 'ref_text') @LooseString() @Default('') String refText,
  }) = _FileAttachResult;

  factory FileAttachResult.fromJson(Map<String, dynamic> json) =>
      _$FileAttachResultFromJson(json);
}
