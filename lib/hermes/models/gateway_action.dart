import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'gateway_action.freezed.dart';
part 'gateway_action.g.dart';

/// Answer of `POST /api/gateway/restart` and `POST /api/hermes/update`: the
/// background action started, or why it was refused ([ok] false).
@freezed
abstract class GatewayAction with _$GatewayAction {
  const GatewayAction._();

  const factory GatewayAction({
    @LooseBool() @Default(false) bool ok,
    @LooseString() @Default('') String name,

    @LooseString() @Default('') String error,

    @LooseString() @Default('') String message,

    @JsonKey(name: 'update_command')
    @LooseString()
    @Default('')
    String updateCommand,
  }) = _GatewayAction;

  factory GatewayAction.fromJson(Map<String, dynamic> json) =>
      _$GatewayActionFromJson(json);

  String get refusal => message.isNotEmpty ? message : error;
}

/// One poll of `GET /api/actions/{name}/status`: the log tail so far and
/// whether the process still runs.
@freezed
abstract class ActionStatus with _$ActionStatus {
  const ActionStatus._();

  const factory ActionStatus({
    @LooseString() @Default('') String name,
    @LooseBool() @Default(false) bool running,

    /// Null while running, and when nothing of that name ever ran. For an
    /// update the gateway derives it from the durable update receipt when
    /// its own process table was lost to the restart the update did.
    @JsonKey(name: 'exit_code') @LooseIntOrNull() int? exitCode,
    @LooseStringList() List<String>? lines,
  }) = _ActionStatus;

  factory ActionStatus.fromJson(Map<String, dynamic> json) =>
      _$ActionStatusFromJson(json);

  bool get finished => !running && exitCode != null;

  bool get succeeded => exitCode == 0;

  /// The log tail of this run as one text. The gateway appends every run
  /// to one file, so the tail is cut at the last start marker of [name].
  String get log {
    final all = lines ?? const <String>[];
    final marker = '=== $name started';
    final start = all.lastIndexWhere((l) => l.startsWith(marker));
    return all.skip(start < 0 ? 0 : start + 1).join('\n').trim();
  }
}

/// Answer of `GET /api/hermes/update/check`.
@freezed
abstract class UpdateCheck with _$UpdateCheck {
  const UpdateCheck._();

  const factory UpdateCheck({
    @JsonKey(name: 'current_version')
    @LooseString()
    @Default('')
    String currentVersion,

    @LooseIntOrNull() int? behind,
    @JsonKey(name: 'update_available')
    @LooseBool()
    @Default(false)
    bool updateAvailable,

    @JsonKey(name: 'can_apply') @LooseBool() @Default(false) bool canApply,
    @JsonKey(name: 'update_command')
    @LooseString()
    @Default('')
    String updateCommand,

    @LooseString() @Default('') String message,
  }) = _UpdateCheck;

  factory UpdateCheck.fromJson(Map<String, dynamic> json) =>
      _$UpdateCheckFromJson(json);

  bool get unknown => behind == null;
}
