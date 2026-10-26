part of 'composer.dart';

mixin _ComposerInput on ConsumerState<Composer> {
  final TextEditingController _text = TextEditingController();
  final FocusNode _focus = FocusNode();
  RecordingProgress? _recording;

  String? _paletteDismissedFor;

  /// A composer serves one chat for its life.
  late final ComposerDraftController _draft = ref.read(
    composerDraftControllerProvider(widget.target).notifier,
  );

  List<LocalAttachment> get _attachments =>
      ref.read(composerDraftControllerProvider(widget.target)).attachments;

  ChatController get _controller =>
      ref.read(chatControllerProvider(widget.target).notifier);

  /// As the send button: composing works offline (a queued turn), not
  /// while a voice message is turned into words.
  bool get _active =>
      (widget.enabled ||
          ref.read(chatControllerProvider(widget.target)).canCompose) &&
      !ref.read(composerDraftControllerProvider(widget.target)).transcribing;

  void _snack(String message) => AppSnacks.of(context).show(message);

  void _onTextChanged() {
    if (_paletteDismissedFor != _text.text) _paletteDismissedFor = null;
    setState(() {});
    _draft.typed(_text.text);
  }

  void _applySeed(ComposerSeed? seed) {
    if (seed == null || seed.isEmpty) return;
    if (seed.text.isNotEmpty) _addText(seed.text, gap: '\n\n');
    if (seed.attachments.isEmpty) return;
    // The draft may not change while the tree builds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _admit(seed.attachments);
    });
  }

  void _addText(String text, {String gap = '\n'}) {
    final existing = _text.text.trimRight();
    final next = existing.isEmpty ? text : '$existing$gap$text';
    _text
      ..text = next
      ..selection = TextSelection.collapsed(offset: next.length);
    _focus.requestFocus();
  }

  void _admit(List<LocalAttachment> picked) {
    final l10n = context.l10n;
    for (final r in _draft.admit(picked)) {
      _snack(switch (r.reason) {
        AttachRefusal.tooMany => l10n.attachTooMany(
          HermesLimits.maxAttachmentsPerMessage,
        ),
        AttachRefusal.tooLarge => l10n.attachTooLarge(
          r.file.name,
          Format.bytes(l10n, Attachments.limitFor(r.file)),
        ),
        AttachRefusal.batchTooLarge => l10n.attachBatchTooLarge(
          Format.bytes(l10n, HermesLimits.maxTotalAttachmentBytes),
        ),
      });
    }
  }

  /// The attach menu, at [button].
  Future<void> _pick(BuildContext button) async {
    final l10n = context.l10n;
    final source = await showAppMenu<AttachSource>(
      button,
      items: [
        for (final (source, icon, label) in [
          (
            AttachSource.photo,
            CupertinoIcons.photo_on_rectangle,
            l10n.attachPhoto,
          ),
          (AttachSource.camera, CupertinoIcons.camera, l10n.attachCamera),
          (AttachSource.video, CupertinoIcons.video_camera, l10n.attachVideo),
          (AttachSource.file, CupertinoIcons.paperclip, l10n.attachFile),
          (AttachSource.location, CupertinoIcons.map_pin, l10n.attachLocation),
        ])
          AppMenuItem(value: source, label: label, icon: icon),
      ],
    );
    if (source == null || !mounted) return;
    if (source == AttachSource.location) {
      // The question goes on the line under the place.
      final place = await pickLocation(context);
      if (place != null && mounted) _addText('$place\n');
      return;
    }
    try {
      final picked = await Attachments.pick(source);
      if (mounted) _admit(picked);
    } on Object catch (e, st) {
      // No camera, a refused permission: say so, not close as if nothing.
      log.w('attachment picking failed', error: e, stackTrace: st);
      if (mounted) _snack(l10n.attachPickFailed);
    }
  }

  /// A hardware keyboard, as on a tablet: Return sends, Shift or Option
  /// with it starts a new line, as in Messages; Command or Control with it
  /// sends too. The on-screen keyboard's Return types its new line through
  /// the text input, not as a key, and so does Gboard for a plain Return
  /// on a hardware keyboard: on Android, Control-Enter sends.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    if (key != LogicalKeyboardKey.enter &&
        key != LogicalKeyboardKey.numpadEnter) {
      return KeyEventResult.ignored;
    }
    // A word still being composed (Japanese, Chinese) takes its Return.
    if (_text.value.isComposingRangeValid) return KeyEventResult.ignored;
    if (event is KeyUpEvent) return KeyEventResult.handled;
    final keys = HardwareKeyboard.instance;
    if (keys.isShiftPressed || keys.isAltPressed) {
      // Typed here: iOS drops a modified Return the app passes on.
      final value = _text.value;
      final at = value.selection.isValid
          ? value.selection
          : TextSelection.collapsed(offset: value.text.length);
      _text.value = value.replaced(at, '\n');
      return KeyEventResult.handled;
    }
    // While a turn runs the button stops it, which Return must not do.
    if (event is KeyDownEvent &&
        !widget.running &&
        _recording == null &&
        _active) {
      unawaited(_send());
    }
    return KeyEventResult.handled;
  }

  Future<void> _send() async {
    final text = _text.text;
    final attachments = _attachments;
    if (text.trim().isEmpty && attachments.isEmpty) return;
    // Text with files is a message, never a command.
    final command = attachments.isEmpty ? SlashCommand.parse(text) : null;
    if (command != null) return _runSlash(command);
    if (_controller.isQueueFull()) return _snack(context.l10n.chatQueueFull);
    _text.clear();
    // The turn is the queue's now; the draft must not bring it back.
    _draft.clear();
    await _controller.send(text, attachments: attachments);
  }

  Future<void> _runSlash(SlashCommand command) async {
    final l10n = context.l10n;
    if (command.needsSession &&
        !ref.read(chatControllerProvider(widget.target)).canDeliver) {
      return _snack(l10n.slashNotReady);
    }
    if (command.confirms) {
      final restart = command == SlashCommand.restart;
      final ok = await showConfirmDialog(
        context,
        title: restart
            ? l10n.slashRestartConfirmTitle
            : l10n.slashUpdateConfirmTitle,
        body: restart
            ? l10n.slashRestartConfirmBody
            : l10n.slashUpdateConfirmBody,
        confirmLabel: restart
            ? l10n.slashRestartConfirmAction
            : l10n.slashUpdateConfirmAction,
        icon: command.icon,
      );
      if (!ok) return;
    }
    if (!mounted) return;
    _text.clear();
    _draft.clear();
    await _controller.runSlash(command);
  }

  Future<void> _openSettings() async {
    final state = ref.read(chatControllerProvider(widget.target));
    await showComposerSettings(
      context,
      load: _controller.modelOptions,
      currentModel: state.model,
      currentEffort: state.effort,
      onModel: (model, provider) =>
          unawaited(_controller.switchModel(model, provider: provider)),
      onEffort: (effort) => unawaited(_controller.setEffort(effort)),
    );
  }

  Future<void> _onRecorded(LocalAttachment take) async {
    final l10n = context.l10n;
    Future<void> drop() async {
      try {
        await File(take.path).delete();
      } on Object catch (e) {
        log.d('voice take not deleted: $e');
      }
    }

    if (take.sizeBytes > HermesLimits.maxAudioBytes) {
      _snack(
        l10n.attachTooLarge(
          take.name,
          Format.bytes(l10n, HermesLimits.maxAudioBytes),
        ),
      );
      return drop();
    }
    final draft = _draft;
    final String words;
    try {
      words = await draft.transcribe(take);
    } on Object catch (e, st) {
      log.w('transcription failed', error: e, stackTrace: st);
      if (!mounted) return drop();
      // The take stays while the snack bar offers it again.
      var retried = false;
      final bar = AppSnacks.of(context).show(
        l10n.chatVoiceFailed,
        action: SnackBarAction(
          label: l10n.actionRetry,
          onPressed: () {
            retried = true;
            unawaited(mounted ? _onRecorded(take) : drop());
          },
        ),
      );
      unawaited(
        (bar?.closed ?? Future.value(SnackBarClosedReason.remove)).then((_) {
          if (!retried) unawaited(drop());
        }),
      );
      return;
    }
    unawaited(drop());
    if (!mounted) return;
    if (words.isEmpty) return _snack(l10n.chatVoiceEmpty);
    final existing = _text.text.trimRight();
    _text.text = existing.isEmpty ? words : '$existing $words';
    await _send();
  }
}
