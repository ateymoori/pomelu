import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../hermes/models/local_attachment.dart';

part 'incoming_share.freezed.dart';

/// What the share sheet or a link hands the app, waiting for a bot (unless
/// the link, or the bot picked in the share sheet, names one).
@freezed
abstract class IncomingShare with _$IncomingShare {
  const IncomingShare._();

  const factory IncomingShare({
    required String id,
    @Default(<LocalAttachment>[]) List<LocalAttachment> files,
    @Default('') String text,
    String? profile,

    /// Files the phone left out of the share (over the size or count caps).
    @Default(0) int skipped,
  }) = _IncomingShare;

  bool get isEmpty => files.isEmpty && text.trim().isEmpty;

  /// Something the user must be told even when nothing is left to send.
  bool get hasNotice => skipped > 0;
  bool get hasTarget => profile != null && profile!.isNotEmpty;
}
