part of 'message_list.dart';

/// Where the reader is: at the newest turn or scrolled up, how many turns
/// came since, and whether the oldest row is near enough to load the
/// conversation before it.
mixin _Follow on State<MessageList>, _RowCache {
  ScrollController get _controller;

  final ValueNotifier<bool> _atBottom = ValueNotifier(true);
  final ValueNotifier<int> _unseen = ValueNotifier(0);

  String? _lastSeenId;

  void _disposeFollow() {
    _atBottom.dispose();
    _unseen.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final atBottom = _controller.offset <= context.spacing.followThreshold;
    final was = _atBottom.value;
    _atBottom.value = atBottom;
    // Reaching the newest row marks it read.
    if (atBottom && !was) _syncUnseen();
    _checkNearTop();
  }

  void _syncUnseen() {
    _derive();
    final last = _visible.lastOrNull;
    if (last == null || _atBottom.value) {
      _lastSeenId = last?.id;
      _unseen.value = 0;
      return;
    }
    final at = _visible.lastIndexWhere((m) => m.id == _lastSeenId);
    _unseen.value = at < 0 ? 0 : _visible.length - 1 - at;
  }

  void _checkNearTopSoon() {
    if (widget.onNearTop == null || widget.state.earlierDone) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkNearTop();
    });
  }

  void _checkNearTop() {
    final ask = widget.onNearTop;
    if (ask == null || widget.state.earlierDone || !_controller.hasClients) {
      return;
    }
    final position = _controller.position;
    // Reversed: what is after the viewport is the past.
    if (position.hasContentDimensions &&
        position.extentAfter <= context.spacing.earlierThreshold) {
      ask();
    }
  }

  void _jumpToLatest() {
    if (!_controller.hasClients) return;
    if (context.reduceMotion) return _controller.jumpTo(0);
    _controller.animateTo(
      0,
      duration: context.motion.normal,
      curve: context.motion.enter,
    );
  }
}
