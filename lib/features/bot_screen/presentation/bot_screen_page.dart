import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../core/utils/failure_text.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../hermes/models/bot_screen.dart';
import '../../sidebar/presentation/sidebar_providers.dart';
import '../domain/screen_view.dart';
import 'bot_screen_providers.dart';
import 'screen_session.dart';
import 'widgets/remote_keyboard.dart';
import 'widgets/screen_controls.dart';
import 'widgets/screen_stage.dart';
import 'widgets/screen_top_bar.dart';

final ThemeData _dark = AppTheme.dark();
final ThemeData _darkContrast = AppTheme.darkContrast();

/// A bot's screen, full screen: watch the bot work, Take over, Hand back.
/// Dark in either theme, as a picture viewer: the desktop is the content,
/// the controls float over it on glass, and the desktop fits between them.
/// In a window too short for two rows of controls they share the top one;
/// over the soft keyboard only the key row stays, so the desktop keeps the
/// most room.
class BotScreenPage extends StatelessWidget {
  const BotScreenPage({required this.profile, super.key});

  final String profile;

  @override
  Widget build(BuildContext context) => Theme(
    data: MediaQuery.highContrastOf(context) ? _darkContrast : _dark,
    child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: _ScreenPage(profile: profile),
    ),
  );
}

class _ScreenPage extends ConsumerStatefulWidget {
  const _ScreenPage({required this.profile});

  final String profile;

  @override
  ConsumerState<_ScreenPage> createState() => _ScreenPageState();
}

class _ScreenPageState extends ConsumerState<_ScreenPage> {
  final FocusNode _typing = FocusNode();

  /// Under the bottom layer's inset: a snack bar shown from here clears the
  /// controls.
  final GlobalKey _body = GlobalKey();
  double _top = 0;
  double _bottom = 0;

  @override
  void dispose() {
    _typing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final l10n = context.l10n;
    final spacing = context.spacing;
    final name = ref.watch(botTitleProvider(profile));
    final screen = ref.watch(botScreenProvider(profile));
    final view = ref.watch(screenSessionProvider(profile));
    final status = screen.value;
    final shown = status != null && status.available && status.running;
    final control = status?.lease.controlFor(view.viewerHash);
    final short = MediaQuery.sizeOf(context).height < spacing.railMaxHeight;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    _listen(context, name, control);

    final controls = shown
        ? ScreenControls(
            profile: profile,
            name: name,
            status: status,
            view: view,
            typing: _typing,
          )
        : null;
    return Scaffold(
      backgroundColor: context.colors.backdropMid,
      resizeToAvoidBottomInset: false,
      body: BottomLayerInset(
        height: _bottom + keyboard,
        child: Stack(
          key: _body,
          fit: StackFit.expand,
          children: [
            if (shown)
              ScreenStage(
                profile: profile,
                label: l10n.screenLabel(name),
                insets: EdgeInsets.only(top: _top, bottom: _bottom + keyboard),
              ),
            Padding(
              padding: EdgeInsets.only(top: _top, bottom: _bottom + keyboard),
              child: _Placeholder(
                profile: profile,
                name: name,
                screen: screen,
                view: view,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SizeReporter(
                onSize: (s) => _measured(top: s.height),
                child: ScreenTopBar(
                  profile: profile,
                  name: name,
                  status: status,
                  view: view,
                  controls: short ? controls : null,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboard),
                child: SizeReporter(
                  onSize: (s) => _measured(bottom: s.height),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.all(spacing.gutter),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: spacing.screenControlsWidth,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (control == ScreenControl.you)
                              RemoteKeyboard(profile: profile, focus: _typing),
                            if (!short && keyboard == 0 && controls != null)
                              controls,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _measured({double? top, double? bottom}) {
    if (!mounted) return;
    if ((top ?? _top) == _top && (bottom ?? _bottom) == _bottom) return;
    setState(() {
      _top = top ?? _top;
      _bottom = bottom ?? _bottom;
    });
  }

  /// Says once what changed by itself, and what failed.
  void _listen(BuildContext context, String name, ScreenControl? control) {
    final l10n = context.l10n;
    ref.listen(screenSessionProvider(widget.profile), (before, now) {
      final snacks = AppSnacks.of(_body.currentContext ?? context);
      if (now.notice != null && now.notice != before?.notice) {
        snacks.show(l10n.screenControlTaken);
      }
      final failure = now.failure;
      final task = before?.task;
      if (failure != null && task != null && now.task == null) {
        final message = failureText(context, failure);
        snacks.show(switch (task) {
          ScreenTask.start => l10n.screenStartFailed(message),
          ScreenTask.takeOver => l10n.screenTakeOverFailed(message),
          ScreenTask.handBack => l10n.screenHandBackFailed(message),
        });
      }
    });
    // The keyboard is for the one in control.
    if (control != ScreenControl.you && _typing.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _typing.unfocus());
    }
  }
}

/// What shows where the desktop is not (yet): a spinner while it comes up,
/// Start while it is off, Reconnect once the stream is lost.
class _Placeholder extends ConsumerWidget {
  const _Placeholder({
    required this.profile,
    required this.name,
    required this.screen,
    required this.view,
  });

  final String profile;
  final String name;
  final AsyncValue<ScreenStatus?> screen;
  final ScreenView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.read(screenSessionProvider(profile).notifier);
    final status = screen.value;
    if (status == null) {
      if (screen.isLoading) return const Center(child: AppSpinner());
      if (screen.error case final error?) {
        return EmptyState(
          icon: CupertinoIcons.desktopcomputer,
          title: l10n.screenAction,
          message: failureText(context, error),
          liveRegion: true,
          action: FilledButton(
            onPressed: () => ref.invalidate(botScreenProvider(profile)),
            child: Text(l10n.actionRetry),
          ),
        );
      }
    }
    if (status == null || !status.available) {
      return EmptyState(
        icon: CupertinoIcons.desktopcomputer,
        title: l10n.screenNone,
        message: l10n.screenNoneMessage,
      );
    }
    if (!status.running) {
      if (status.blocker case final blocker?) {
        return EmptyState(
          icon: CupertinoIcons.desktopcomputer,
          title: l10n.screenCannotStart,
          message: blocker,
        );
      }
      final starting = view.task == ScreenTask.start;
      return EmptyState(
        icon: CupertinoIcons.desktopcomputer,
        title: l10n.screenOff,
        message: l10n.screenOffMessage(name),
        action: FilledButton.icon(
          key: const Key('screen-start'),
          onPressed: view.busy ? null : () => unawaited(session.start()),
          icon: starting
              ? const AppSpinner.icon()
              : const Icon(CupertinoIcons.play_fill),
          label: Text(l10n.screenStart),
        ),
      );
    }
    return switch (view.stream) {
      ScreenStream.live => const SizedBox.shrink(),
      ScreenStream.ended => EmptyState(
        icon: CupertinoIcons.desktopcomputer,
        title: l10n.screenEnded,
        message: view.failure == null
            ? l10n.screenEndedMessage
            : failureText(context, view.failure!),
        liveRegion: true,
        action: FilledButton.icon(
          key: const Key('screen-reconnect'),
          onPressed: session.reconnect,
          icon: const Icon(CupertinoIcons.arrow_clockwise),
          label: Text(l10n.screenReconnect),
        ),
      ),
      // The still of the screen shows under it, in the page.
      ScreenStream.idle || ScreenStream.attaching => const IgnorePointer(
        child: Center(child: AppSpinner()),
      ),
    };
  }
}
