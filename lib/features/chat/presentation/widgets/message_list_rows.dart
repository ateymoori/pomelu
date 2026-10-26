part of 'message_list.dart';

/// The transcript's rows: which messages show, a long reply cut into
/// pieces, and each built row kept by key until what it paints changes.
mixin _RowCache on State<MessageList> {
  /// Built rows by key, reused while what they paint is unchanged, so a
  /// streamed token rebuilds only the piece it landed in.
  final Map<String, ({TranscriptItem item, Widget row})> _rows = {};

  final Map<String, GlobalKey> _anchors = {};

  /// The cut of each long reply, so a settled one is cut once.
  final Map<String, ({String text, List<MarkdownChunk> chunks})> _cuts = {};

  ChatState? _derivedFor;
  List<ChatMessage> _visible = const [];
  List<TranscriptItem> _items = const [];
  Map<String, DateTime> _dayBreaks = const {};
  Map<String, int>? _index;

  void _derive() {
    final state = widget.state;
    if (identical(_derivedFor, state)) return;
    _derivedFor = state;
    bool shown(ChatMessage m) =>
        m.boundary ||
        m.isCommand ||
        ((m.isUser || m.isAssistant) &&
            (!m.isEmptyVisual || m.streaming) &&
            !state.hidden.contains(m.rowId));
    _visible = [...state.earlier, ...state.messages].where(shown).toList();
    _dayBreaks = dayBreaks(_visible);
    _items = [for (final m in _visible) ..._itemsOf(m)];
    _index = null;
    final live = {for (final m in _visible) m.id};
    _cuts.removeWhere((id, _) => !live.contains(id));
    if (_rows.length > _items.length) {
      final keys = {for (final i in _items) i.key};
      _rows.removeWhere((k, _) => !keys.contains(k));
      _anchors.removeWhere((k, _) => !keys.contains(k));
    }
  }

  List<MarkdownChunk> _chunksOf(ChatMessage m) {
    if (!m.isAssistant || m.text.length <= AppConfig.replyChunkChars) {
      return const [];
    }
    final hit = _cuts[m.id];
    if (hit != null && hit.text == m.text) return hit.chunks;
    final cut = MarkdownChunks.split(m.text, target: AppConfig.replyChunkChars);
    // One piece means no safe cut: the message stays one row.
    final chunks = cut.length > 1 ? cut : const <MarkdownChunk>[];
    _cuts[m.id] = (text: m.text, chunks: chunks);
    return chunks;
  }

  List<TranscriptItem> _itemsOf(ChatMessage m) {
    final chunks = _chunksOf(m);
    if (chunks.isEmpty) return [TranscriptItem(m)];
    final direction = markdownDirection(m.text);
    return [
      for (final (i, c) in chunks.indexed)
        TranscriptItem(
          m,
          part: i,
          parts: chunks.length,
          text: c.text,
          gap: c.gap,
          direction: direction,
        ),
    ];
  }

  ChatMessage _latest(ChatMessage built) =>
      _visible.lastWhere((m) => m.id == built.id, orElse: () => built);

  Widget _rowFor(TranscriptItem item) {
    final hit = _rows[item.key];
    if (hit != null && hit.item.paintsSameAs(item)) return hit.row;
    final m = item.message;
    final onRetry = widget.onRetry;
    final row = _Row(
      key: ValueKey(item.key),
      anchor: _anchors.putIfAbsent(item.key, GlobalKey.new),
      messageId: m.id,
      child: m.boundary
          ? TranscriptSeparator(label: context.l10n.chatNewConversation)
          : m.isUser
          ? UserMessage(
              message: m,
              target: widget.target,
              onRetry: onRetry == null
                  ? null
                  : () => widget.onRetry?.call(m.id),
            )
          : m.isCommand
          ? SlashOutput(message: m, target: widget.target)
          : AssistantMessage(
              message: m,
              target: widget.target,
              item: item.parts == 1 ? null : item,
              latest: () => _latest(m),
            ),
    );
    _rows[item.key] = (item: item, row: row);
    return row;
  }
}
