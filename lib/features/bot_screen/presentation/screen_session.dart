import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/app_logger.dart';
import '../../../hermes/api/hermes_api.dart';
import '../../../hermes/client/connection_state.dart';
import '../../../hermes/hermes_constants.dart';
import '../../../hermes/hermes_failure.dart';
import '../../../hermes/models/bot_screen.dart';
import '../../connection/presentation/connection_providers.dart';
import '../domain/remote_input.dart';
import '../domain/screen_view.dart';
import 'bot_screen_providers.dart';
import 'screen_surface.dart';

part 'screen_session.g.dart';

/// An open Screen page of bot [profile]: its viewer, its stream, Take over
/// and Hand back.
///
/// Control the page holds goes back to the bot when the page closes. While
/// the app is away it is kept [AppConfig.screenAwayHandBack] (a password
/// copied from another app), then handed back. A viewer id belongs to the
/// socket that minted it, so after a reconnect the page watches under a new
/// one, and takes again the control it held under the old.
@riverpod
class ScreenSession extends _$ScreenSession {
  ScreenSurface? _surface;
  HermesApi? _api;
  ScreenStatus? _status;
  String? _viewerId;

  /// The viewer this page last held control as, kept across a reconnect.
  String? _heldHash;
  int _attachRun = 0;
  int _tries = 0;
  DateTime? _liveSince;
  DateTime? _hiddenAt;
  bool _socketLost = false;

  /// What the web view was last told: input off or on.
  bool _viewOnly = true;
  Timer? _retry;
  Timer? _away;

  @override
  ScreenView build(String profile) {
    _api = ref.watch(hermesApiProvider);
    _status = ref.read(botScreenProvider(profile)).value;
    ref.listen(botScreenProvider(profile), (_, next) {
      if (next.value case final status?) _onStatus(status);
    });
    ref.listen(connectionStateProvider, (_, next) {
      if (next.value case final s?) _onConnection(s);
    });
    final lifecycle = AppLifecycleListener(
      onHide: _onHide,
      onShow: () => unawaited(_onShow()),
    );
    ref.onDispose(() {
      lifecycle.dispose();
      _retry?.cancel();
      _away?.cancel();
      _leave();
    });
    return const ScreenView();
  }

  bool get _holding =>
      (_status?.lease ?? const ScreenLease()).controlFor(state.viewerHash) ==
      ScreenControl.you;

  BotScreen get _screen => ref.read(botScreenProvider(profile).notifier);

  /// The page's web view is up ([surface]), or gone (null).
  void bind(ScreenSurface? surface) {
    _surface = surface;
    if (surface != null && _status?.running == true) unawaited(_attach());
  }

  /// Starts the screen; the stream follows.
  Future<void> start() => _run(ScreenTask.start, (_) => _screen.start());

  /// Control to this page. The page asks first when another viewer has it.
  Future<void> takeOver() => _run(ScreenTask.takeOver, (api) async {
    final viewer = _viewerId;
    if (viewer == null) return;
    _screen.acceptLease(await api.takeOverScreen(profile, viewer));
  });

  /// Control back to the bot: this page's, or (the page asked first)
  /// another viewer's or a lost one's.
  Future<void> handBack() => _run(ScreenTask.handBack, _release);

  /// Opens the stream again after it was lost.
  void reconnect() {
    _tries = 0;
    unawaited(_attach());
  }

  /// What the keyboard typed; dropped unless this page has control.
  void type(int backspaces, String text, Set<ScreenModifier> modifiers) {
    if (_holding) unawaited(_surface?.type(backspaces, text, modifiers));
  }

  /// A key of the key row or a hardware keyboard; dropped unless this
  /// page has control.
  void press(ScreenKey key, Set<ScreenModifier> modifiers) {
    if (_holding) unawaited(_surface?.press(key, modifiers));
  }

  /// The phone's clipboard [text] to the desktop: onto its clipboard, and
  /// typed where its cursor is when it is short enough
  /// ([AppConfig.screenPasteMaxChars]); else false, and it waits there for
  /// the desktop's own Paste.
  bool paste(String text) {
    if (!_holding) return false;
    final lines = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    unawaited(_surface?.setClipboard(lines));
    if (lines.length > AppConfig.screenPasteMaxChars) return false;
    unawaited(_surface?.type(0, lines, const {}));
    return true;
  }

  /// Back to the whole desktop (Whole screen).
  void fit() => unawaited(_surface?.fit());

  /// The desktop filling a tall window again (Fill screen).
  void fill() => unawaited(_surface?.fill());

  /// Drag on, or off again before the drop.
  void toggleDrag() {
    if (!_holding && state.drag == ScreenDrag.off) return;
    unawaited(_surface?.drag(on: state.drag == ScreenDrag.off));
  }

  /// From the web view: the stream shows.
  void onStreamOpen() {
    _liveSince = DateTime.now();
    state = state.copyWith(stream: ScreenStream.live, notice: null);
  }

  /// From the web view: the stream closed with [code].
  void onStreamClosed(int code) {
    final since = _liveSince;
    if (since != null &&
        DateTime.now().difference(since) >= AppConfig.screenStableAfter) {
      _tries = 0;
    }
    _liveSince = null;
    if (code == HermesProtocol.screenStopped) {
      state = state.copyWith(stream: ScreenStream.idle);
      unawaited(_screen.refresh());
      return;
    }
    if (code == HermesProtocol.screenControlTaken) {
      state = state.copyWith(notice: ScreenNotice.controlTaken);
    }
    _scheduleAttach();
  }

  /// From the web view: the desktop is zoomed in, or whole; [canFill] when
  /// it is whole in a window it could fill.
  void onZoom({required bool zoomed, required bool canFill}) =>
      state = state.copyWith(zoomed: zoomed, canFill: canFill);

  /// From the web view: where Drag is.
  void onDrag(ScreenDrag drag) => state = state.copyWith(drag: drag);

  // ------------------------------------------------------------ the stream

  Future<void> _attach() async {
    final surface = _surface;
    final api = _api;
    if (surface == null || api == null || _hiddenAt != null) return;
    final run = ++_attachRun;
    _retry?.cancel();
    state = state.copyWith(stream: ScreenStream.attaching, failure: null);
    // noVNC drops its canvas with the stream: a still covers the wait.
    unawaited(_showPoster(api, surface));
    try {
      final attach = await api.observeScreen(profile, viewerId: _viewerId);
      if (!_current(run)) return;
      final hash = screenViewerHash(attach.viewerId);
      _viewerId = attach.viewerId;
      state = state.copyWith(viewerHash: hash);
      _screen.accept(attach.status);
      var lease = attach.status.lease;
      // Control held under a viewer of a socket that is gone.
      final held = _heldHash;
      if (held != null && held != hash && lease.heldBy(held)) {
        try {
          lease = await api.takeOverScreen(profile, attach.viewerId);
          if (!_current(run)) return;
          _screen.acceptLease(lease);
        } on HermesFailure catch (e) {
          // Watching still works; the control stays where it is.
          log.w('taking the screen of $profile again failed', error: e);
          _heldHash = null;
        }
      }
      _viewOnly = !lease.heldBy(hash);
      await surface.attach(attach.stream, viewOnly: _viewOnly);
    } on HermesFailure catch (e) {
      if (!_current(run)) return;
      log.w('opening the screen of $profile failed', error: e);
      state = state.copyWith(stream: ScreenStream.ended, failure: e);
    }
  }

  bool _current(int run) => ref.mounted && run == _attachRun;

  Future<void> _showPoster(HermesApi api, ScreenSurface surface) async {
    try {
      final still = await api.screenThumbnail(profile);
      if (ref.mounted && state.stream != ScreenStream.live) {
        await surface.poster(still);
      }
    } on HermesFailure catch (e) {
      log.d('no still of the screen of $profile', error: e);
    }
  }

  void _scheduleAttach() {
    if (_tries >= AppConfig.screenReattachAttempts) {
      state = state.copyWith(stream: ScreenStream.ended);
      return;
    }
    final wait = AppConfig.screenReattachDelay * _tries++;
    state = state.copyWith(stream: ScreenStream.attaching);
    _retry?.cancel();
    _retry = Timer(wait, () => unawaited(_attach()));
  }

  /// Lets go of the stream (the screen stopped, the app went away).
  void _drop({required bool handBack}) {
    _attachRun++;
    _retry?.cancel();
    unawaited(_surface?.detach(handBack: handBack));
    state = state.copyWith(stream: ScreenStream.idle);
  }

  // ------------------------------------------------------------ changes

  void _onStatus(ScreenStatus status) {
    _status = status;
    final hash = state.viewerHash;
    final lease = status.lease;
    if (lease.heldBy(hash)) {
      _heldHash = hash;
    } else if (lease.viewerHash != _heldHash) {
      _heldHash = null;
    }
    if (!status.running) {
      if (state.stream != ScreenStream.idle) _drop(handBack: true);
      return;
    }
    if (state.stream == ScreenStream.idle) unawaited(_attach());
    final viewOnly = !lease.heldBy(hash);
    if (viewOnly != _viewOnly) {
      _viewOnly = viewOnly;
      unawaited(_surface?.setViewOnly(viewOnly: viewOnly));
    }
  }

  /// A new socket mints new viewer ids: the stream comes back under one.
  void _onConnection(HermesConnectionState s) {
    if (s is! Connected) {
      _socketLost = true;
      return;
    }
    if (!_socketLost) return;
    _socketLost = false;
    if (state.stream != ScreenStream.idle) {
      _tries = 0;
      unawaited(_attach());
    }
  }

  void _onHide() {
    if (_hiddenAt != null) return;
    _hiddenAt = DateTime.now();
    final holding = _holding;
    _drop(handBack: !holding);
    if (holding) {
      _away = Timer(AppConfig.screenAwayHandBack, () => unawaited(_awayOver()));
    }
  }

  Future<void> _onShow() async {
    final since = _hiddenAt;
    if (since == null) return;
    _hiddenAt = null;
    _away?.cancel();
    // iOS runs no timer while the app is suspended.
    final overdue =
        DateTime.now().difference(since) >= AppConfig.screenAwayHandBack;
    if (overdue) await _awayOver();
    if (ref.mounted && _status?.running == true) await _attach();
  }

  // ------------------------------------------------------------ control

  Future<void> _run(
    ScreenTask task,
    Future<void> Function(HermesApi api) act,
  ) async {
    final api = _api;
    if (state.busy || api == null) return;
    state = state.copyWith(task: task, failure: null);
    try {
      await act(api);
      if (ref.mounted) state = state.copyWith(task: null);
    } on HermesFailure catch (e) {
      log.w('screen ${task.name} of $profile failed', error: e);
      if (ref.mounted) state = state.copyWith(task: null, failure: e);
    }
  }

  Future<void> _release(HermesApi api) async {
    final hash = state.viewerHash;
    if (hash != null && (_status?.lease.heldBy(hash) ?? false)) {
      return _releaseOwn(api, hash);
    }
    _accept(await api.handBackScreen(profile, force: true));
  }

  /// The app was away too long: control this page still holds goes back to
  /// the bot. Not taken again on return, and never another viewer's.
  Future<void> _awayOver() async {
    final held = _heldHash;
    final api = _api;
    _heldHash = null;
    if (held == null || api == null) return;
    try {
      await _releaseOwn(api, held);
    } on HermesFailure catch (e) {
      log.w('handing the screen of $profile back failed', error: e);
    }
  }

  /// Hands back the control held as viewer [hash]: by this page's viewer
  /// while its socket lives. A viewer of a socket that is gone is unknown
  /// to the gateway, so then by force, only once a fresh status shows
  /// [hash] still holds it: another viewer may have taken over meanwhile.
  Future<void> _releaseOwn(HermesApi api, String hash) async {
    final viewer = _viewerId;
    if (viewer != null && screenViewerHash(viewer) == hash) {
      try {
        return _accept(await api.handBackScreen(profile, viewerId: viewer));
      } on ServerFailure catch (e) {
        if (!_isViewerMismatch(e)) rethrow;
      }
    }
    final status = await api.screenStatus(profile);
    if (status == null || !status.lease.heldBy(hash)) {
      _heldHash = null;
      return;
    }
    _accept(await api.handBackScreen(profile, force: true));
  }

  void _accept(ScreenLease lease) {
    _heldHash = null;
    if (ref.mounted) _screen.acceptLease(lease);
  }

  static bool _isViewerMismatch(ServerFailure e) =>
      e.rpcCode == HermesProtocol.errDisplay &&
      e.data is Map &&
      (e.data! as Map)['code'] == HermesProtocol.viewerMismatch;

  /// The page closed: control it held goes back to the bot. The stream's
  /// clean close does that too, but a web view torn down drops the socket.
  void _leave() {
    final api = _api;
    final viewer = _viewerId;
    if (api != null &&
        viewer != null &&
        (_status?.lease.heldBy(screenViewerHash(viewer)) ?? false)) {
      unawaited(
        api
            .handBackScreen(profile, viewerId: viewer)
            .then<void>(
              (_) {},
              onError: (Object e) =>
                  log.w('handing the screen of $profile back failed', error: e),
            ),
      );
    }
    unawaited(_surface?.detach(handBack: true));
  }
}
