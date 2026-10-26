import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/config/assets.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../hermes/hermes_constants.dart';
import '../../../connection/presentation/connection_providers.dart';
import '../../domain/remote_input.dart';
import '../../domain/screen_view.dart';
import '../screen_session.dart';
import '../screen_surface.dart';

/// The bot's desktop: noVNC in a web view (`assets/bot_screen`, built from
/// `tool/bot_screen`), fitted inside [insets] (the chrome floating over it).
/// It is the [ScreenSession]'s [ScreenSurface]: the session says what to
/// show, the page reports the stream back.
///
/// The page loads under the gateway's origin, so the stream's socket goes
/// out with the gateway's own Origin, which the gateway's guard accepts.
class ScreenStage extends ConsumerStatefulWidget {
  const ScreenStage({
    required this.profile,
    required this.insets,
    required this.label,
    super.key,
  });

  final String profile;
  final EdgeInsets insets;

  /// What a screen reader says for the desktop.
  final String label;

  @override
  ConsumerState<ScreenStage> createState() => _ScreenStageState();
}

class _ScreenStageState extends ConsumerState<ScreenStage>
    implements ScreenSurface {
  static const String _channel = 'Pomelu';

  final WebViewController _web = WebViewController();
  final Completer<void> _ready = Completer<void>();
  late final ScreenSession _session;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _session = ref.read(screenSessionProvider(widget.profile).notifier);
    unawaited(_load());
  }

  Future<void> _load() async {
    final base = ref.read(hermesClientProvider)?.baseUrl;
    if (base == null) return;
    try {
      await _web.setJavaScriptMode(JavaScriptMode.unrestricted);
      await _web.setBackgroundColor(Colors.transparent);
      await _web.enableZoom(false);
      await _web.addJavaScriptChannel(
        _channel,
        onMessageReceived: (m) => _onMessage(m.message),
      );
      // The page itself, and nothing after it: no link leaves it.
      await _web.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (_) => _loaded
              ? NavigationDecision.prevent
              : NavigationDecision.navigate,
        ),
      );
      final page = await rootBundle.loadString(Assets.botScreenPage);
      await _web.loadHtmlString(page, baseUrl: base.origin);
    } on Object catch (e) {
      log.w('the screen page did not load', error: e);
    }
  }

  void _onMessage(String raw) {
    final Object? message;
    try {
      message = jsonDecode(raw);
    } on FormatException {
      return;
    }
    if (message is! Map<String, dynamic> || !mounted) return;
    switch (message['type']) {
      case 'ready':
        _loaded = true;
        if (!_ready.isCompleted) _ready.complete();
        unawaited(_layout());
        _session.bind(this);
      case 'connect':
        _session.onStreamOpen();
      case 'disconnect':
        final code = message['code'];
        _session.onStreamClosed(code is int ? code : 0);
      case 'zoom':
        _session.onZoom(
          zoomed: message['zoomed'] == true,
          canFill: message['canFill'] == true,
        );
      case 'drag':
        final drag = ScreenDrag.values.asNameMap()[message['state']];
        if (drag != null) _session.onDrag(drag);
      case 'error':
        log.w('screen page: ${message['message']}');
    }
  }

  @override
  void didUpdateWidget(ScreenStage old) {
    super.didUpdateWidget(old);
    if (old.insets != widget.insets) unawaited(_layout());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) unawaited(_layout());
  }

  @override
  void dispose() {
    _session.bind(null);
    // A clean close hands control back at the gateway; the session asks
    // too, as a web view torn down may drop the socket instead.
    unawaited(_call('detach', [HermesProtocol.screenHandBack]));
    super.dispose();
  }

  Future<void> _layout() {
    final i = widget.insets;
    final accent = context.colors.accent;
    final motion = context.reduceMotion
        ? 0
        : context.motion.normal.inMilliseconds;
    String channel(double v) => '${(v * 255).round()}';
    return _call('layout', [
      {'top': i.top, 'right': i.right, 'bottom': i.bottom, 'left': i.left},
      'rgb(${channel(accent.r)}, ${channel(accent.g)}, ${channel(accent.b)})',
      context.surfaces.borderWidth * 2,
      motion,
    ]);
  }

  /// Calls `pomelu.<fn>` in the page once it is up.
  Future<void> _call(String fn, List<Object?> args) async {
    await _ready.future;
    try {
      await _web.runJavaScript('pomelu.$fn(${args.map(jsonEncode).join(',')})');
    } on Object catch (e) {
      log.w('screen page call $fn failed', error: e);
    }
  }

  List<String> _names(Set<ScreenModifier> modifiers) => [
    for (final m in modifiers) m.name,
  ];

  @override
  Future<void> attach(Uri stream, {required bool viewOnly}) =>
      _call('attach', [stream.toString(), viewOnly, HermesProtocol.screenKeep]);

  @override
  Future<void> detach({required bool handBack}) {
    final code = handBack
        ? HermesProtocol.screenHandBack
        : HermesProtocol.screenKeep;
    return _call('detach', [code]);
  }

  @override
  Future<void> setViewOnly({required bool viewOnly}) =>
      _call('viewOnly', [viewOnly]);

  @override
  Future<void> poster(String? dataUrl) => _call('poster', [dataUrl]);

  @override
  Future<void> type(
    int backspaces,
    String text,
    Set<ScreenModifier> modifiers,
  ) => _call('type', [backspaces, text, _names(modifiers)]);

  @override
  Future<void> press(ScreenKey key, Set<ScreenModifier> modifiers) =>
      _call('press', [key.name, _names(modifiers)]);

  @override
  Future<void> setClipboard(String text) => _call('clipboard', [text]);

  @override
  Future<void> drag({required bool on}) => _call('drag', [on]);

  @override
  Future<void> fit() => _call('fit', const []);

  @override
  Future<void> fill() => _call('fill', const []);

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    image: true,
    label: widget.label,
    child: ExcludeSemantics(
      child: WebViewWidget(
        controller: _web,
        // Every touch is the desktop's, or the page's own zoom.
        gestureRecognizers: const {
          Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
        },
      ),
    ),
  );
}
