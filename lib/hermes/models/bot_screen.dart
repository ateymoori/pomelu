import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../hermes_constants.dart';
import 'json_converters.dart';

part 'bot_screen.freezed.dart';
part 'bot_screen.g.dart';

/// Who drives a bot's screen: the agent, or one human viewer.
@JsonEnum(alwaysCreate: true)
enum ScreenHolder { agent, human }

/// Control of a Bot Screen (`display.lease`). The holder's viewer id never
/// leaves the gateway; [viewerHash] lets a viewer know itself
/// ([screenViewerHash]). [epoch] grows on every change.
@freezed
abstract class ScreenLease with _$ScreenLease {
  const ScreenLease._();

  const factory ScreenLease({
    // An unknown holder is the agent's: a viewer never acts on it.
    @JsonKey(unknownEnumValue: ScreenHolder.agent)
    @Default(ScreenHolder.agent)
    ScreenHolder holder,
    @JsonKey(name: 'viewer_hash') @LooseStringOrNull() String? viewerHash,
    @LooseInt() @Default(0) int epoch,
  }) = _ScreenLease;

  factory ScreenLease.fromJson(Map<String, dynamic> json) =>
      _$ScreenLeaseFromJson(json);

  bool get humanHolds => holder == ScreenHolder.human;

  /// Whether the viewer of [hash] holds control.
  bool heldBy(String? hash) => humanHolds && hash != null && viewerHash == hash;
}

/// A bot's screen (`display.status`): a headless desktop on the gateway's
/// host that the agent drives with its computer and browser tools.
@freezed
abstract class ScreenStatus with _$ScreenStatus {
  const ScreenStatus._();

  const factory ScreenStatus({
    /// False off a Linux host.
    @LooseBool() @Default(false) bool supported,

    /// False until the desktop packages are on the host.
    @LooseBool() @Default(false) bool installed,
    @LooseBool() @Default(false) bool running,

    /// Why a start would be refused now (host memory), when it would.
    @LooseStringOrNull() String? blocker,
    @Default(ScreenLease()) ScreenLease lease,

    /// The bot's home on the host; matches the events that are its own.
    @JsonKey(name: 'profile_key') @LooseString() @Default('') String profileKey,
  }) = _ScreenStatus;

  factory ScreenStatus.fromJson(Map<String, dynamic> json) =>
      _$ScreenStatusFromJson(json);

  /// Whether the bot has a screen to open.
  bool get available => supported && installed;
}

/// A way in to a running screen (`display.observe`): the stream's address
/// with its single-use ticket (30 s), and this socket's viewer id.
typedef ScreenAttach = ({ScreenStatus status, String viewerId, Uri stream});

/// The [ScreenLease.viewerHash] of [viewerId].
String screenViewerHash(String viewerId) => sha256
    .convert(utf8.encode(viewerId))
    .toString()
    .substring(0, HermesProtocol.viewerHashChars);
