import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/chat_message.dart';
import '../../domain/chat_state.dart';
import '../../domain/chat_target.dart';
import '../../domain/markdown_chunks.dart';
import '../../domain/transcript_item.dart';
import 'assistant_message.dart';
import 'message_parts.dart';
import 'message_search.dart';
import 'slash_output.dart';
import 'user_message.dart';

part 'message_list_follow.dart';
part 'message_list_parts.dart';
part 'message_list_rows.dart';
part 'message_list_search.dart';

/// The reverse-scrolling transcript: earlier conversations above the open
/// one, each closed by a "New conversation" line; nearing the oldest row
/// asks for the one before. A jump-to-latest pill counts unread turns.
class MessageList extends StatefulWidget {
  const MessageList({
    required this.target,
    required this.state,
    required this.botName,
    required this.topPadding,
    required this.bottomPadding,
    super.key,
    this.onRetry,
    this.onNearTop,
    this.onReopen,
    this.topOverlay,
  });

  final ChatTarget target;
  final ChatState state;
  final String botName;
  final double topPadding;

  /// Room kept clear above the composer.
  final double bottomPadding;

  /// Sends a failed turn again.
  final ValueChanged<String>? onRetry;

  /// The oldest row is close: load the conversation before it.
  final VoidCallback? onNearTop;

  /// Opens a chat that failed to open; null hides its button.
  final VoidCallback? onReopen;

  /// Stacked above the find bar: the error banner.
  final Widget? topOverlay;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList>
    with _RowCache, _Search, _Follow {
  @override
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _query.addListener(_onQueryChanged);
    // Nothing scrolled yet: the baseline of what the user sees.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncUnseen();
    });
    _checkNearTopSoon();
  }

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rows capture these.
    if (widget.target != oldWidget.target ||
        (widget.onRetry == null) != (oldWidget.onRetry == null)) {
      _rows.clear();
    }
    // A taller composer under a reader scrolled up must not move the text
    // read; pinned to the newest turn, the rows move with it.
    final delta = widget.bottomPadding - oldWidget.bottomPadding;
    if (delta != 0 &&
        _controller.hasClients &&
        !_atBottom.value &&
        _controller.position.hasPixels) {
      _controller.jumpTo(math.max(0, _controller.position.pixels + delta));
    }
    if (!identical(widget.state, oldWidget.state)) {
      _syncUnseen();
      if (_searching) _recomputeHits(keepPosition: true);
      _checkNearTopSoon();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    _disposeSearch();
    _disposeFollow();
    super.dispose();
  }

  Widget _list(EdgeInsets padding) {
    final items = _items;
    final activity = widget.state.running;
    return ListView.builder(
      controller: _controller,
      reverse: true,
      padding: padding,
      addAutomaticKeepAlives: false,
      itemCount: items.length + (activity ? 1 : 0),
      // A new row moves every index: matching by key keeps the elements.
      findChildIndexCallback: (key) {
        if (key is! ValueKey<String>) return null;
        final at = (_index ??= {
          for (var i = 0; i < items.length; i++) items[i].key: i,
        })[key.value];
        return at == null ? null : items.length - 1 - at + (activity ? 1 : 0);
      },
      itemBuilder: (context, i) {
        if (activity && i == 0) {
          return _Row(child: _ActivityLine(state: widget.state));
        }
        final item = items[items.length - 1 - (activity ? i - 1 : i)];
        final row = _rowFor(item);
        final day = item.isFirst ? _dayBreaks[item.message.id] : null;
        if (day == null) return row;
        // The cached row stays identical inside a fresh column.
        return Column(
          key: ValueKey(item.key),
          mainAxisSize: MainAxisSize.min,
          children: [
            _Row(child: TranscriptSeparator.day(context, day)),
            row,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _derive();
    final spacing = context.spacing;
    final padding = EdgeInsets.fromLTRB(
      spacing.gutter,
      widget.topPadding,
      spacing.gutter,
      widget.bottomPadding,
    );
    final state = widget.state;
    final transcript = _items.isNotEmpty || state.running;
    final Widget body;
    if (state.loading && state.messages.isEmpty && state.earlier.isEmpty) {
      body = _Skeleton(padding: padding);
    } else if (!transcript) {
      final failed =
          state.error != null && state.runtimeId.isEmpty && !state.loading;
      body = Padding(
        padding: padding,
        child: failed
            ? _OpenFailed(onRetry: widget.onReopen)
            : _Greeting(botName: widget.botName),
      );
    } else {
      body = _list(padding);
    }
    final active = _activeHit;
    // The query is published, not passed down: rows are cached, and only the
    // widgets that paint highlights rebuild.
    return MessageSearchScope(
      query: _searching ? _query.text : '',
      activeMessageId: active?.messageId,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): _closeSearch,
        },
        child: Stack(
          children: [
            Positioned.fill(child: body),
            Positioned(
              top: widget.topPadding,
              left: 0,
              right: 0,
              child: ReadingColumn(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [?widget.topOverlay, ?_searchBar()],
                ),
              ),
            ),
            if (_items.isNotEmpty || state.running)
              Positioned(
                left: 0,
                right: 0,
                bottom: widget.bottomPadding + spacing.sm,
                child: ReadingColumn(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _JumpPill(
                      atBottom: _atBottom,
                      unseen: _unseen,
                      onPressed: _jumpToLatest,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
