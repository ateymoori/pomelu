import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/remote_input.dart';
import '../screen_session.dart';
import 'screen_controls.dart';

/// The soft keyboard for the bot's desktop: a hidden field ([focus]) the
/// keyboard types into, each change sent as keys, and while it is up a row
/// of the keys a phone keyboard lacks, and Paste. Ctrl and Alt hold for the
/// next key.
/// A hardware keyboard's Escape, Tab and arrows go to the desktop too, not
/// to the field.
///
/// Nothing is learned or corrected: what is typed may be a password.
class RemoteKeyboard extends ConsumerStatefulWidget {
  const RemoteKeyboard({required this.profile, required this.focus, super.key});

  final String profile;
  final FocusNode focus;

  @override
  ConsumerState<RemoteKeyboard> createState() => _RemoteKeyboardState();
}

class _RemoteKeyboardState extends ConsumerState<RemoteKeyboard> {
  final TextEditingController _field = TextEditingController();
  String _last = '';
  Set<ScreenModifier> _held = const {};

  ScreenSession get _session =>
      ref.read(screenSessionProvider(widget.profile).notifier);

  /// A hardware key the desktop gets instead of the field.
  static final Map<LogicalKeyboardKey, ScreenKey> _hardwareKeys = {
    LogicalKeyboardKey.escape: ScreenKey.escape,
    LogicalKeyboardKey.tab: ScreenKey.tab,
    LogicalKeyboardKey.arrowLeft: ScreenKey.left,
    LogicalKeyboardKey.arrowUp: ScreenKey.up,
    LogicalKeyboardKey.arrowRight: ScreenKey.right,
    LogicalKeyboardKey.arrowDown: ScreenKey.down,
  };

  @override
  void initState() {
    super.initState();
    _refill();
    _field.addListener(_pinCaret);
    widget.focus.addListener(_onFocus);
  }

  @override
  void dispose() {
    widget.focus.removeListener(_onFocus);
    _field.dispose();
    super.dispose();
  }

  /// The caret stays at the end: [RemoteTyping.diff] compares from the
  /// start, so a caret moved inside the filler (iOS's space-bar trackpad)
  /// would turn the next letter into backspaces.
  void _pinCaret() {
    final value = _field.value;
    final end = value.text.length;
    if (value.composing.isCollapsed &&
        (value.selection.baseOffset != end ||
            value.selection.extentOffset != end)) {
      _field.selection = TextSelection.collapsed(offset: end);
    }
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    final key = _hardwareKeys[event.logicalKey];
    if (key == null || event is KeyUpEvent) return KeyEventResult.ignored;
    final keyboard = HardwareKeyboard.instance;
    _session.press(key, {
      ..._held,
      if (keyboard.isControlPressed) ScreenModifier.ctrl,
      if (keyboard.isAltPressed) ScreenModifier.alt,
    });
    _release();
    return KeyEventResult.handled;
  }

  void _onFocus() => setState(() => _held = const {});

  void _refill() {
    _last = RemoteTyping.filler;
    _field.value = TextEditingValue(
      text: _last,
      selection: TextSelection.collapsed(offset: _last.length),
    );
  }

  void _onChanged(String text) {
    final typed = RemoteTyping.diff(_last, text);
    if (typed.backspaces > 0 || typed.text.isNotEmpty) {
      _session.type(typed.backspaces, typed.text, _held);
      _release();
    }
    // Not mid-word: the keyboard would lose the word it is composing.
    if (RemoteTyping.spent(text) && _field.value.composing.isCollapsed) {
      _refill();
    } else {
      _last = text;
    }
  }

  void _press(ScreenKey key) {
    _session.press(key, _held);
    _release();
  }

  void _release() {
    if (_held.isNotEmpty) setState(() => _held = const {});
  }

  void _toggle(ScreenModifier m) => setState(
    () => _held = _held.contains(m) ? ({..._held}..remove(m)) : {..._held, m},
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final text = Theme.of(context).textTheme.labelLarge;
    Widget cap(
      String label,
      String spoken,
      VoidCallback onPressed, {
      bool held = false,
    }) => AppIconButton(
      tooltip: spoken,
      filled: held,
      onPressed: onPressed,
      child: FittedBox(child: Text(label, style: text)),
    );
    Widget arrow(IconData icon, String spoken, ScreenKey key) => AppIconButton(
      icon: icon,
      tooltip: spoken,
      onPressed: () => _press(key),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.focus.hasFocus)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.sm),
            child: AppGlass.capsule(
              padding: EdgeInsets.all(spacing.xs),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    cap(
                      l10n.screenKeyEscapeCap,
                      l10n.screenKeyEscape,
                      () => _press(ScreenKey.escape),
                    ),
                    cap(
                      l10n.screenKeyTab,
                      l10n.screenKeyTab,
                      () => _press(ScreenKey.tab),
                    ),
                    cap(
                      l10n.screenKeyControlCap,
                      l10n.screenKeyControl,
                      () => _toggle(ScreenModifier.ctrl),
                      held: _held.contains(ScreenModifier.ctrl),
                    ),
                    cap(
                      l10n.screenKeyAlt,
                      l10n.screenKeyAlt,
                      () => _toggle(ScreenModifier.alt),
                      held: _held.contains(ScreenModifier.alt),
                    ),
                    arrow(
                      CupertinoIcons.arrow_left,
                      l10n.screenKeyLeft,
                      ScreenKey.left,
                    ),
                    arrow(
                      CupertinoIcons.arrow_up,
                      l10n.screenKeyUp,
                      ScreenKey.up,
                    ),
                    arrow(
                      CupertinoIcons.arrow_down,
                      l10n.screenKeyDown,
                      ScreenKey.down,
                    ),
                    arrow(
                      CupertinoIcons.arrow_right,
                      l10n.screenKeyRight,
                      ScreenKey.right,
                    ),
                    AppIconButton(
                      icon: CupertinoIcons.doc_on_clipboard,
                      tooltip: l10n.screenPaste,
                      onPressed: () =>
                          unawaited(pasteOnScreen(context, _session)),
                    ),
                    AppIconButton(
                      icon: CupertinoIcons.keyboard_chevron_compact_down,
                      tooltip: l10n.screenKeyboardHide,
                      onPressed: widget.focus.unfocus,
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Laid out (the keyboard needs a field on screen) but not seen.
        SizedBox.square(
          dimension: 1,
          child: Opacity(
            opacity: 0,
            // Before the app's text-editing shortcuts, which would move the
            // caret or the focus.
            child: Focus(
              canRequestFocus: false,
              skipTraversal: true,
              onKeyEvent: _onKey,
              child: TextField(
                key: const Key('screen-typing'),
                controller: _field,
                focusNode: widget.focus,
                onChanged: _onChanged,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                autocorrect: false,
                enableSuggestions: false,
                enableIMEPersonalizedLearning: false,
                smartDashesType: SmartDashesType.disabled,
                smartQuotesType: SmartQuotesType.disabled,
                enableInteractiveSelection: false,
                showCursor: false,
                decoration: InputDecoration.collapsed(
                  hintText: l10n.screenTyping,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
