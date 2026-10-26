import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/models/local_attachment.dart';
import '../../data/attachments.dart';
import '../../domain/new_id.dart';
import 'recording_hint.dart';

/// Hold to talk, as in Telegram: the take starts when the finger goes down
/// and is delivered when it lifts; slide toward the start (left, or right
/// in a right-to-left layout) to cancel; shorter than
/// [AppConfig.minVoiceTake] is a tap. Raw pointer events, since the tooltip
/// owns the long press. A screen reader or a switch starts a take with the
/// tap action and sends it with a second tap.
class MicButton extends StatefulWidget {
  const MicButton({
    required this.onChanged,
    required this.onRecorded,
    required this.onDenied,
    required this.onTooShort,
    super.key,
    this.enabled = true,
    this.recorder,
    this.tempDirectory = getTemporaryDirectory,
    this.maxTake = AppConfig.maxVoiceTake,
  });

  /// Progress while recording, null once it ends.
  final ValueChanged<RecordingProgress?> onChanged;
  final ValueChanged<LocalAttachment> onRecorded;

  /// The microphone permission was refused.
  final VoidCallback onDenied;
  final VoidCallback onTooShort;

  /// Null is the platform recorder.
  final AudioRecorder? recorder;
  final Future<Directory> Function() tempDirectory;
  final bool enabled;

  /// A take stops by itself after this long, and is kept.
  final Duration maxTake;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> {
  /// Made on the first take: a mic never pressed opens no recorder.
  AudioRecorder? _made;
  AudioRecorder get _recorder => _made ??= widget.recorder ?? AudioRecorder();
  Timer? _ticker;
  DateTime? _startedAt;
  bool _cancelling = false;
  bool _active = false;

  bool _held = false;

  Offset? _down;

  bool _byTap = false;

  @override
  void dispose() {
    _ticker?.cancel();
    unawaited(_made?.dispose());
    super.dispose();
  }

  Duration get _elapsed => _startedAt == null
      ? Duration.zero
      : DateTime.now().difference(_startedAt!);

  void _report() => widget.onChanged((
    elapsed: _elapsed,
    cancelling: _cancelling,
    byTap: _byTap,
  ));

  void _toggleByTap() {
    if (_active) {
      unawaited(_finish(cancel: false));
      return;
    }
    _byTap = true;
    unawaited(_start());
  }

  Future<void> _start() async {
    if (_active || !widget.enabled) return;
    _held = true;
    _cancelling = false;
    try {
      if (!await _recorder.hasPermission()) {
        _held = false;
        widget.onDenied();
        return;
      }
      // The permission dialog took the finger away: nothing to record.
      if (!_held) return;
      final dir = await widget.tempDirectory();
      final path =
          '${dir.path}${Platform.pathSeparator}voice-${newId()}'
          '.${AppConfig.voiceNoteExtension}';
      await _recorder.start(
        // The default encoder is AAC LC too; spelled out because the file
        // name above depends on it.
        // ignore: avoid_redundant_argument_values
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
    } on Object catch (e, st) {
      log.w('recording failed to start', error: e, stackTrace: st);
      widget.onChanged(null);
      return;
    }
    if (!mounted || !_held) {
      // The finger lifted, or the composer went, while the recorder started.
      await _cancelQuietly();
      return;
    }
    setState(() => _active = true);
    _startedAt = DateTime.now();
    _ticker = Timer.periodic(AppConfig.recordingTick, (_) {
      // Long enough: the take ends and goes, as a lifted finger would.
      if (_elapsed >= widget.maxTake) {
        unawaited(_finish(cancel: false));
        return;
      }
      _report();
    });
    _report();
  }

  Future<void> _cancelQuietly() async {
    try {
      await _recorder.cancel();
    } on Object catch (e) {
      log.d('recording not cancelled: $e');
    }
  }

  Future<void> _finish({required bool cancel}) async {
    final starting = _held && !_active;
    _held = false;
    // Lifted before the recorder was up: a tap. Say how to use it.
    if (starting && !cancel) widget.onTooShort();
    if (!_active) {
      _byTap = false;
      return;
    }
    setState(() => _active = false);
    _byTap = false;
    _ticker?.cancel();
    _ticker = null;
    final elapsed = _elapsed;
    _startedAt = null;
    widget.onChanged(null);
    final tooShort = elapsed < AppConfig.minVoiceTake;
    try {
      if (cancel || tooShort) {
        await _cancelQuietly();
        if (tooShort && !cancel && mounted) widget.onTooShort();
        return;
      }
      final path = await _recorder.stop();
      if (path == null) return;
      final take = await Attachments.fromPath(
        path,
        mimeHint: AppConfig.voiceNoteMime,
        duration: elapsed,
        kind: AttachmentKind.audio,
      );
      // The composer may have gone while the file was read.
      if (take != null && mounted) widget.onRecorded(take);
    } on Object catch (e, st) {
      log.w('recording failed to stop', error: e, stackTrace: st);
    }
  }

  void _onMove(double dx) {
    // Toward the start of the line: left, or right in a right-to-left one.
    final toStart = Directionality.of(context) == TextDirection.rtl ? dx : -dx;
    final cancelling = toStart > context.spacing.slideToCancel;
    if (cancelling == _cancelling) return;
    _cancelling = cancelling;
    if (_active) _report();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      container: true,
      button: true,
      enabled: widget.enabled,
      // What a tap does now: start a take, or end and send the one running.
      label: _active ? l10n.chatRecordStop : l10n.chatRecordButton,
      onTap: widget.enabled ? _toggleByTap : null,
      excludeSemantics: true,
      child: Listener(
        onPointerDown: (e) {
          _down = e.position;
          _byTap = false;
          unawaited(_start());
        },
        onPointerMove: (e) {
          final origin = _down;
          if (origin != null) _onMove(e.position.dx - origin.dx);
        },
        onPointerUp: (_) => unawaited(_finish(cancel: _cancelling)),
        onPointerCancel: (_) => unawaited(_finish(cancel: true)),
        // The label above is the one for screen readers; a tooltip bubble
        // would cover the recording hint.
        child: TooltipVisibility(
          visible: false,
          child: AppIconButton(
            icon: _active ? CupertinoIcons.mic_fill : CupertinoIcons.mic,
            tooltip: l10n.chatRecord,
            filled: _active,
            onPressed: widget.enabled ? () {} : null,
          ),
        ),
      ),
    );
  }
}
