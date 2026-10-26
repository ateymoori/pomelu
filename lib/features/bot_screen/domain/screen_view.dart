import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../hermes/hermes_failure.dart';
import '../../../hermes/models/bot_screen.dart';

part 'screen_view.freezed.dart';

/// Who drives a bot's screen, as one viewer sees it.
enum ScreenControl { bot, you, otherViewer }

extension ScreenControlOf on ScreenLease {
  /// Who drives, for the viewer of [viewerHash].
  ScreenControl controlFor(String? viewerHash) => !humanHolds
      ? ScreenControl.bot
      : heldBy(viewerHash)
      ? ScreenControl.you
      : ScreenControl.otherViewer;
}

/// The live stream of an open Screen page: none, coming up, showing, or
/// lost after its tries ran out.
enum ScreenStream { idle, attaching, live, ended }

/// What the Screen page waits on; its controls wait meanwhile.
enum ScreenTask { start, takeOver, handBack }

/// Drag and drop on the desktop: off, waiting for the tap on what to pick
/// up, or holding it until the tap where it drops.
enum ScreenDrag { off, pick, drop }

/// Something the Screen page says once.
enum ScreenNotice {
  /// Another viewer took control from this one: it watches again.
  controlTaken,
}

/// An open Screen page: its stream and viewer, the action in flight, and
/// the failure of the last one. Status and control are the gateway's
/// ([ScreenStatus]).
@freezed
abstract class ScreenView with _$ScreenView {
  const ScreenView._();

  const factory ScreenView({
    @Default(ScreenStream.idle) ScreenStream stream,

    /// This page's viewer, as a lease names its holder.
    String? viewerHash,
    ScreenTask? task,
    HermesFailure? failure,

    /// The view is closer than the whole desktop.
    @Default(false) bool zoomed,
    @Default(ScreenDrag.off) ScreenDrag drag,
    ScreenNotice? notice,
  }) = _ScreenView;

  /// A call of the page is in flight; its buttons wait.
  bool get busy => task != null;
}
