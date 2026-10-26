import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../core/utils/failure_text.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../share/presentation/composer_seeds_provider.dart';
import '../../sidebar/presentation/sidebar_providers.dart';
import '../domain/chat_target.dart';
import 'chat_controller.dart';
import 'pending_request_provider.dart';
import 'widgets/chat_chrome.dart';
import 'widgets/composer.dart';
import 'widgets/message_list.dart';
import 'widgets/message_search.dart';
import 'widgets/plan_card.dart';
import 'widgets/request_card.dart';

part 'chat_view_overlays.dart';

/// One chat: the transcript, under a glass header at the top and, floating
/// over its bottom, the agent's open question and the composer. No app bar.
class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key, required this.target, this.onOpenSidebar});

  final ChatTarget target;

  /// Set on compact layouts: the header gets a menu button.
  final VoidCallback? onOpenSidebar;

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  ComposerSeed? _seed;

  /// Heights of the glass header and of the floating bottom layer: the
  /// transcript pads by them and scrolls on beneath.
  double _topLayer = 0;
  double _bottomLayer = 0;

  final MessageSearchRequests _searchRequests = MessageSearchRequests();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _takeSeed());
  }

  @override
  void dispose() {
    _searchRequests.dispose();
    super.dispose();
  }

  void _takeSeed() {
    if (!mounted) return;
    final seed = ref
        .read(composerSeedsProvider.notifier)
        .take(widget.target.key);
    if (seed != null && !seed.isEmpty) setState(() => _seed = seed);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Map<String, ComposerSeed>>(composerSeedsProvider, (_, next) {
      if (next.containsKey(widget.target.key)) _takeSeed();
    });
    final spacing = context.spacing;
    // No watch of the whole state here: each part below selects its slice,
    // so a streamed token does not rebuild the composer or the header.
    final provider = chatControllerProvider(widget.target);
    final controller = ref.read(provider.notifier);
    final botName = ref.watch(botTitleProvider(widget.target.profile));
    return Focus(
      autofocus: true,
      skipTraversal: true,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyF, control: true):
              _searchRequests.open,
          const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
              _searchRequests.open,
        },
        child: BottomLayerInset(
          height: _bottomLayer,
          child: MessageSearchLauncher(
            requests: _searchRequests,
            // Left and right only: the glass header covers the status bar
            // and the composer pads for the gesture bar itself.
            child: SafeArea(
              top: false,
              bottom: false,
              child: LayoutBuilder(
                builder: (context, pane) => Stack(
                  children: [
                    Positioned.fill(
                      child: Consumer(
                        builder: (context, ref, _) => MessageList(
                          target: widget.target,
                          state: ref.watch(provider),
                          botName: botName,
                          topPadding: _topLayer + spacing.sm,
                          bottomPadding: _bottomLayer + spacing.lg,
                          onRetry: (id) => unawaited(controller.retry(id)),
                          onNearTop: () => unawaited(controller.loadEarlier()),
                          onReopen: () => unawaited(controller.reopen()),
                          topOverlay: _Banner(target: widget.target),
                        ),
                      ),
                    ),
                    // The status bar keeps the page behind it; below it the
                    // transcript scrolls on under the header's floating glass.
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height:
                          MediaQuery.paddingOf(context).top +
                          spacing.scrollEdgeFade,
                      child: const ScrollEdge(child: SizedBox.expand()),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SizeReporter(
                        onSize: (size) {
                          if (mounted && size.height != _topLayer) {
                            setState(() => _topLayer = size.height);
                          }
                        },
                        child: SafeArea(
                          bottom: false,
                          // The side pane's header starts on this line too.
                          minimum: EdgeInsets.only(top: spacing.sm),
                          // Its own node, as the floating layer below.
                          child: Semantics(
                            container: true,
                            child: ChatTopActions(
                              target: widget.target,
                              botName: botName,
                              onOpenSidebar: widget.onOpenSidebar,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _floatingLayer(pane, botName),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _floatingLayer(BoxConstraints pane, String botName) => SizeReporter(
    onSize: (size) {
      if (mounted && size.height != _bottomLayer) {
        setState(() => _bottomLayer = size.height);
      }
    },
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: pane.maxHeight * context.spacing.bottomLayerMaxFraction,
      ),
      child: Padding(
        // The gesture bar's inset is the composer's, not the whole view's.
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Only the plan and the agent's question scroll when space runs
            // out. The composer is never inside a scroll view: one whose
            // viewport lags a growing composer marks its controls hidden,
            // and iOS then drops them from VoiceOver.
            Flexible(
              child: SingleChildScrollView(
                reverse: true,
                primary: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Plan(target: widget.target),
                    _Question(target: widget.target, pane: pane),
                  ],
                ),
              ),
            ),
            Consumer(
              builder: (context, ref, _) {
                final flags = ref.watch(
                  chatControllerProvider(widget.target)
                      .select((s) => (ready: s.isReady, running: s.running)),
                );
                return Composer(
                  // One composer per chat, with its own draft.
                  key: ValueKey(widget.target),
                  target: widget.target,
                  botName: botName,
                  enabled: flags.ready,
                  running: flags.running,
                  seed: _seed,
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
