import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_device.freezed.dart';
part 'push_device.g.dart';

/// A phone as the Pomelu Hermes plugin keeps it: where Apple (`ios`) or
/// Google (`android`) delivers its pushes, and the phone's own key the
/// plugin seals each message with (32 bytes, base64).
@freezed
abstract class PushDevice with _$PushDevice {
  const factory PushDevice({
    required String platform,
    required String token,
    required String key,

    /// APNs development: a debug build.
    @Default(false) bool sandbox,
  }) = _PushDevice;

  factory PushDevice.fromJson(Map<String, dynamic> json) =>
      _$PushDeviceFromJson(json);
}
