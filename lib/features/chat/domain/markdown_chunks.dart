/// Follows fenced code blocks line by line, so every scanner that must leave
/// code alone agrees on where a fence opens and closes: `` ``` `` or `~~~`,
/// three or more, closed by as many of the same with nothing after.
class MarkdownFence {
  String? _fence;

  bool get inside => _fence != null;

  /// Feeds the next line; true when it belongs to a fence.
  bool feed(String line) {
    final t = line.trimLeft();
    final open = _fence;
    if (open != null) {
      final n = _run(t, open[0]);
      if (n >= open.length && t.substring(n).trim().isEmpty) _fence = null;
      return true;
    }
    if (t.isEmpty || (t[0] != '`' && t[0] != '~')) return false;
    final n = _run(t, t[0]);
    _fence = n >= 3 ? t[0] * n : null;
    return _fence != null;
  }

  static int _run(String t, String c) {
    var n = 0;
    while (n < t.length && t[n] == c) {
      n++;
    }
    return n;
  }
}

/// One row-sized piece of a long reply. [gap]: a blank line stood before it,
/// which the row must paint, or the cut would show.
typedef MarkdownChunk = ({String text, bool gap});

/// Cuts a long reply into pieces the transcript builds one at a time, so a
/// 20 000-character reply does not cost one huge frame per streamed token.
///
/// Cuts fall only between blocks, never inside a fence, a `<details>`, a
/// table, a quote, a paragraph or a nested item, so the pieces render as the
/// whole would. A cut depends on the text before it only.
abstract final class MarkdownChunks {
  static final RegExp _listItem = RegExp(r'^(?:[-*+]|\d{1,9}[.)])[ \t]');
  static final RegExp _heading = RegExp(r'^#{1,6}[ \t]');
  static final RegExp _detailsOpen = RegExp('<details', caseSensitive: false);
  static final RegExp _detailsClose = RegExp(
    '</details>',
    caseSensitive: false,
  );

  /// Pieces of at least [target] characters, except the last. Joined with
  /// `\n` they are [source] again.
  static List<MarkdownChunk> split(String source, {required int target}) {
    if (source.length <= target) return [(text: source, gap: false)];
    final lines = source.split('\n');
    final chunks = <MarkdownChunk>[];
    final fence = MarkdownFence();
    var start = 0;
    var size = 0;
    var gap = false;
    var details = 0;
    var prevBlank = false;
    var prevTable = false;
    var prevQuote = false;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trimLeft();
      final blank = trimmed.isEmpty;
      final indented = line.length != trimmed.length;
      if (i > start &&
          size >= target &&
          !fence.inside &&
          details == 0 &&
          !blank &&
          !indented &&
          (prevBlank ||
              (!prevTable &&
                  !prevQuote &&
                  (_listItem.hasMatch(line) || _heading.hasMatch(line))))) {
        chunks.add((text: lines.sublist(start, i).join('\n'), gap: gap));
        gap = prevBlank;
        start = i;
        size = 0;
      }
      size += line.length + 1;
      if (!fence.feed(line)) {
        details += _detailsOpen.allMatches(line).length;
        details -= _detailsClose.allMatches(line).length;
        if (details < 0) details = 0;
      }
      prevBlank = blank;
      prevTable = trimmed.startsWith('|');
      prevQuote = trimmed.startsWith('>');
    }
    chunks.add((text: lines.sublist(start).join('\n'), gap: gap));
    return chunks;
  }
}
