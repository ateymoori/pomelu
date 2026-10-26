import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'gateway_status.freezed.dart';
part 'gateway_status.g.dart';

/// What the app reads of `GET /api/status`.
@freezed
abstract class GatewayStatus with _$GatewayStatus {
  const factory GatewayStatus({
    @LooseString() @Default('') String version,
    @JsonKey(name: 'auth_required')
    @LooseBool()
    @Default(false)
    bool authRequired,
    @JsonKey(name: 'auth_providers')
    @LooseStringList()
    List<String>? authProviders,
  }) = _GatewayStatus;

  factory GatewayStatus.fromJson(Map<String, dynamic> json) =>
      _$GatewayStatusFromJson(json);
}
