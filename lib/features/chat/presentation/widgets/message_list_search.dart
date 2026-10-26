part of 'message_list.dart';

/// One find hit: the message and which occurrence in it, oldest first.
typedef _SearchHit = ({String messageId, int ordinal});

mixin _Search on State<MessageList>, _RowCache {
  ScrollController get _controller;

  final TextEditingController _query = TextEditingController();
  final FocusNode _queryFocus = FocusNode();
  bool _searching = false;
  List<_SearchHit> _hits = const [];
  int _active = 0;
  MessageSearchRequests? _launcher;

  _SearchHit? get _activeHit => _active < _hits.length ? _hits[_active] : null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final launcher = MessageSearchLauncher.of(context);
    if (identical(launcher, _launcher)) return;
    _launcher?.removeListener(_open);
    _launcher = launcher?..addListener(_open);
  }

  void _disposeSearch() {
    _launcher?.removeListener(_open);
    _query
      ..removeListener(_onQueryChanged)
      ..dispose();
    _queryFocus.dispose();
  }

  void _open() {
    if (!mounted) return;
    if (!_searching) setState(() => _searching = true);
    _queryFocus.requestFocus();
  }

  void _closeSearch() {
    if (!_searching) return;
    _queryFocus.unfocus();
    _query.clear();
    setState(() {
      _searching = false;
      _hits = const [];
      _active = 0;
    });
  }

  void _onQueryChanged() => _recomputeHits(keepPosition: false);

  void _recomputeHits({required bool keepPosition}) {
    _derive();
    final query = _query.text.trim();
    final previous = _activeHit;
    final hits = <_SearchHit>[
      if (query.length >= AppConfig.minSearchLength)
        for (final m in _visible)
          ...List.generate(
            countMatches(m.text, query),
            (i) => (messageId: m.id, ordinal: i),
          ),
    ];
    final kept = keepPosition && previous != null ? hits.indexOf(previous) : -1;
    setState(() {
      _hits = hits;
      _active = kept < 0 ? 0 : kept;
    });
    if (!keepPosition && hits.isNotEmpty) _revealActive();
  }

  void _move(int delta) {
    if (_hits.isEmpty) return;
    setState(() => _active = (_active + delta) % _hits.length);
    _revealActive();
  }

  void _revealActive() {
    final hit = _activeHit;
    if (hit == null) return;
    var key = hit.messageId;
    final m = _visible.where((m) => m.id == hit.messageId).firstOrNull;
    final pieces = m == null ? const <MarkdownChunk>[] : _chunksOf(m);
    var left = hit.ordinal;
    for (final (i, piece) in pieces.indexed) {
      final n = countMatches(piece.text, _query.text.trim());
      if (left < n) {
        key = '${hit.messageId}#$i';
        break;
      }
      left -= n;
    }
    unawaited(_reveal(key));
  }

  Future<void> _reveal(String key) async {
    final alignment = context.spacing.hitAlignment;
    final direct = _anchors[key]?.currentContext;
    if (direct != null) {
      return Scrollable.ensureVisible(
        direct,
        alignment: alignment,
        duration: context.reduceMotion ? Duration.zero : context.motion.fast,
      );
    }
    final index = _items.indexWhere((i) => i.key == key);
    if (!_controller.hasClients || index < 0) return;
    final p = _controller.position;
    final fromNewest = (_items.length - 1 - index) / _items.length;
    _controller.jumpTo(
      (p.maxScrollExtent * fromNewest).clamp(
        p.minScrollExtent,
        p.maxScrollExtent,
      ),
    );
    await SchedulerBinding.instance.endOfFrame;
    final built = _anchors[key]?.currentContext;
    if (mounted && built != null && built.mounted) {
      await Scrollable.ensureVisible(built, alignment: alignment);
    }
  }

  Widget? _searchBar() => !_searching
      ? null
      : MessageSearchBar(
          controller: _query,
          focusNode: _queryFocus,
          matchCount: _hits.length,
          activeMatch: _hits.isEmpty ? 0 : _active + 1,
          onNext: () => _move(1),
          onPrevious: () => _move(-1),
          onClose: _closeSearch,
        );
}
