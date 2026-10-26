import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'compress_result.freezed.dart';
part 'compress_result.g.dart';

/// Answer of `session.compress`: what the compaction did to the live
/// session, in the words the gateway uses for its own clients.
@freezed
abstract class CompressResult with _$CompressResult {
  const CompressResult._();

  const factory CompressResult({
    @LooseString() @Default('') String status,
    CompressSummary? summary,

    @JsonKey(name: 'lock_held') @LooseBool() @Default(false) bool lockHeld,

    @LooseString() @Default('') String message,
  }) = _CompressResult;

  factory CompressResult.fromJson(Map<String, dynamic> json) =>
      _$CompressResultFromJson(json);

  String get text {
    final s = summary;
    final lines = s == null
        ? [message]
        : [s.headline, s.tokenLine, s.note, message];
    return lines.where((l) => l.trim().isNotEmpty).join('\n');
  }
}

/// The gateway's summary lines of a compaction.
@freezed
abstract class CompressSummary with _$CompressSummary {
  const factory CompressSummary({
    @LooseString() @Default('') String headline,
    @JsonKey(name: 'token_line') @LooseString() @Default('') String tokenLine,
    @LooseString() @Default('') String note,
  }) = _CompressSummary;

  factory CompressSummary.fromJson(Map<String, dynamic> json) =>
      _$CompressSummaryFromJson(json);
}
