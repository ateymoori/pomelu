/// Inline parser: turns a run of text into inline [MdNode]s (bold, italic,
/// code, links, images, LaTeX, source tags, …).
///
/// CommonMark's algorithm. One left-to-right scan turns what binds tightest —
/// code spans, maths, autolinks, escapes, entities — into finished nodes, and
/// leaves runs of `*`, `_` and `~~` on a delimiter stack and `[` / `![` on a
/// bracket stack. A `]` resolves its bracket into a link or image as soon as
/// it is seen, and emphasis is matched last, inside each link's text and then
/// across the rest, so `*[foo*](url)` is a literal `*` before a link and
/// `*foo **bar***` nests the way it reads.
///
/// The package's own syntax rides on the same scan: `\( … \)`, `\[ … \]` and
/// (when enabled) `$ … $` maths, `[1]` citations, `[^note]` footnotes, `~~`
/// strikethrough and `<u>` underline.
library;

import 'dart:math' show max;
import 'dart:typed_data';

import 'ast.dart';
import 'definitions.dart';
import 'entities.dart';
import 'html_tags.dart';
import 'scanner.dart';

const int _bang = 0x21; // '!'
const int _openBracket = 0x5B; // '['
const int _star = 0x2A; // '*'
const int _underscore = 0x5F; // '_'
const int _tilde = 0x7E; // '~'
const int _backtick = 0x60; // '`'
const int _lt = 0x3C; // '<'
const int _gt = 0x3E; // '>'
const int _backslash = 0x5C; // '\'
const int _dollar = 0x24; // '$'
const int _amp = 0x26; // '&'
const int _caret = 0x5E; // '^'
const int _newline = 0x0A; // '\n'
const int _space = 0x20; // ' '
const int _tab = 0x09; // '\t'
const int _openParen = 0x28; // '('
const int _closeBracket = 0x5D; // ']'
const int _closeParen = 0x29; // ')'
const int _quote = 0x22; // '"'
const int _apostrophe = 0x27; // '\''

/// Code units that can begin an inline construct.
///
/// Everything else is ordinary text, and the parser's only job for it is to
/// copy it through. Testing that with a table lets a run of plain prose be
/// found with one comparison per character and copied with a single
/// `substring`, instead of running the whole construct dispatch on every
/// character and appending them one at a time — which is most of the work in
/// the common case, because most of a reply is prose.
///
/// A table rather than a bitmask: Dart's web targets have no 64-bit integers,
/// and a mask over the ASCII range would need them.
final Uint8List _inlineTriggers = () {
  final table = Uint8List(128);
  for (final unit in <int>[
    _bang,
    _dollar,
    _amp,
    _star,
    _underscore,
    _lt,
    _openBracket,
    _closeBracket,
    _backslash,
    _backtick,
    _tilde,
    _newline,
  ]) {
    table[unit] = 1;
  }
  return table;
}();

/// Whether [unit] can begin an inline construct.
///
/// Non-ASCII never can — every delimiter in the dialect is ASCII — so the
/// bounds check doubles as the answer for the whole of Unicode above 127.
bool _canStartConstruct(int unit) => unit < 128 && _inlineTriggers[unit] == 1;

/// Whether the `_` at [j] sits between two ASCII letters or digits.
///
/// Such an underscore can neither open nor close emphasis, so the plain-text
/// fast path keeps going through it. Identifiers like `snake_case_name` are
/// common in replies, and sending each of their underscores through the
/// dispatch chain is wasted work. Only ever asked about an actual `_`, so the
/// per-character cost of the fast path is unchanged.
bool _intrawordUnderscore(String text, int j) =>
    j > 0 &&
    j + 1 < text.length &&
    _isAsciiAlphanumeric(text.codeUnitAt(j - 1)) &&
    _isAsciiAlphanumeric(text.codeUnitAt(j + 1));

bool _isAsciiAlphanumeric(int c) =>
    (c >= 0x30 && c <= 0x39) ||
    (c >= 0x41 && c <= 0x5A) ||
    (c >= 0x61 && c <= 0x7A);

bool _isPlain(String text, int j) {
  final unit = text.codeUnitAt(j);
  return !_canStartConstruct(unit) ||
      (unit == _underscore && _intrawordUnderscore(text, j));
}

List<MdNode> parseInline(
  String text,
  bool useDollar, [
  MarkdownDefinitions defs = MarkdownDefinitions.empty,
  MarkdownHtml? html,
]) {
  final n = text.length;

  // Most runs of an assistant's prose contain no markup at all. Finding that
  // out costs one scan, and skips the parse entirely.
  var plainUntil = 0;
  while (plainUntil < n && _isPlain(text, plainUntil)) {
    plainUntil += 1;
  }
  if (plainUntil == n) {
    return n == 0 ? <MdNode>[] : <MdNode>[MdText(text: text)];
  }
  return _InlineParser(
    text,
    useDollar,
    defs,
    html ?? MarkdownHtml.defaults,
  ).parse();
}

// ---------------------------------------------------------------------------
// The working list
// ---------------------------------------------------------------------------

/// One entry of the parse's working list: literal text, or a finished node.
/// Emphasis and links are built by wrapping a stretch of the list into one
/// node, which is why it is linked.
sealed class _Item {
  _Item? prev;
  _Item? next;
}

class _Text extends _Item {
  _Text(this.text);
  String text;
}

class _Node extends _Item {
  _Node(this.node);
  final MdNode node;
}

/// A run of `*`, `_` or `~~` that may open or close emphasis.
class _Delim {
  _Delim({
    required this.item,
    required this.char,
    required this.count,
    required this.canOpen,
    required this.canClose,
  }) : original = count;

  final _Text item;
  final int char;

  /// Delimiters left in the run; matching uses them up.
  int count;

  /// The run's length as written, for the rule of three.
  final int original;
  final bool canOpen;
  final bool canClose;
  _Delim? prev;
  _Delim? next;
}

/// An open `[` or `![`, waiting for its `]`.
class _Bracket {
  _Bracket({
    required this.item,
    required this.image,
    required this.index,
    required this.previous,
    required this.previousDelimiter,
  });

  final _Text item;
  final bool image;

  /// Where the bracket's text starts in the source, just past `[`.
  final int index;
  final _Bracket? previous;
  final _Delim? previousDelimiter;

  /// False once a link has formed after it: links do not nest.
  bool active = true;

  /// Whether another bracket opened after this one, which rules out reading
  /// this one as a shortcut reference.
  bool bracketAfter = false;
}

class _InlineParser {
  _InlineParser(this.text, this.useDollar, this.defs, this.html)
    : dollars = useDollar ? DollarMathCloser(text) : null,
      urls = _BareUrls(text);

  final String text;
  final bool useDollar;
  final MarkdownDefinitions defs;
  final MarkdownHtml html;
  final DollarMathCloser? dollars;
  final _BareUrls urls;

  _Item? _head;
  _Item? _tail;
  _Delim? _delimiters;
  _Bracket? _brackets;
  final StringBuffer _buf = StringBuffer();

  // ----- the list -------------------------------------------------------

  void _append(_Item item) {
    _flush();
    _appendRaw(item);
  }

  void _appendRaw(_Item item) {
    final tail = _tail;
    item.prev = tail;
    item.next = null;
    if (tail == null) {
      _head = item;
    } else {
      tail.next = item;
    }
    _tail = item;
  }

  void _flush() {
    if (_buf.isNotEmpty) {
      _appendRaw(_Text(_buf.toString()));
      _buf.clear();
    }
  }

  void _unlink(_Item item) {
    final prev = item.prev;
    final next = item.next;
    if (prev == null) {
      _head = next;
    } else {
      prev.next = next;
    }
    if (next == null) {
      _tail = prev;
    } else {
      next.prev = prev;
    }
    item.prev = null;
    item.next = null;
  }

  /// The items strictly between [from] and [to], as nodes, unlinked.
  List<MdNode> _takeBetween(_Item from, _Item? to) {
    final nodes = _nodes(from.next, to);
    var item = from.next;
    while (item != null && item != to) {
      final next = item.next;
      _unlink(item);
      item = next;
    }
    return nodes;
  }

  /// [node] inserted right after [after].
  void _insertAfter(_Item after, _Item node) {
    final next = after.next;
    node.prev = after;
    node.next = next;
    after.next = node;
    if (next == null) {
      _tail = node;
    } else {
      next.prev = node;
    }
  }

  /// The items from [from] up to (not including) [to] as nodes, adjacent
  /// text merged.
  static List<MdNode> _nodes(_Item? from, _Item? to) {
    final out = <MdNode>[];
    StringBuffer? pending;
    var item = from;
    while (item != null && item != to) {
      switch (item) {
        case _Text(:final text):
          if (text.isNotEmpty) {
            (pending ??= StringBuffer()).write(text);
          }
        case _Node(:final node):
          if (pending != null) {
            out.add(MdText(text: pending.toString()));
            pending = null;
          }
          out.add(node);
      }
      item = item.next;
    }
    if (pending != null) {
      out.add(MdText(text: pending.toString()));
    }
    return out;
  }

  // ----- the scan -------------------------------------------------------

  List<MdNode> parse() {
    final n = text.length;
    var i = 0;
    while (i < n) {
      // A run of characters that cannot begin a construct is copied through
      // in one piece. This is the bulk of ordinary prose.
      if (_isPlain(text, i)) {
        var j = i + 1;
        while (j < n && _isPlain(text, j)) {
          j += 1;
        }
        _buf.write(text.substring(i, j));
        i = j;
        continue;
      }
      i = _construct(i);
    }
    _flush();
    _processEmphasis(null);
    return _nodes(_head, null);
  }

  /// Handles the construct that may start at [i]; returns where to go on.
  int _construct(int i) {
    final n = text.length;
    final c = text.codeUnitAt(i);
    switch (c) {
      case _newline:
        return _lineBreak(i);
      case _backslash:
        return _backslashAt(i);
      case _backtick:
        final span = codeSpanAt(text, i);
        if (span != null) {
          _append(
            _Node(
              MdInlineCode(
                text: codeSpanContent(text.substring(i + span.run, span.close)),
              ),
            ),
          );
          return span.close + span.run;
        }
        final run = backtickRunAt(text, i);
        _buf.write(text.substring(i, i + run));
        return i + run;
      case _star || _underscore:
        return _delimiterRun(i, c);
      case _tilde:
        var run = 1;
        while (i + run < n && text.codeUnitAt(i + run) == _tilde) {
          run += 1;
        }
        if (run != 2) {
          _buf.write(text.substring(i, i + run));
          return i + run;
        }
        final item = _Text('~~');
        _append(item);
        _pushDelimiter(
          _Delim(
            item: item,
            char: _tilde,
            count: 2,
            canOpen: true,
            canClose: true,
          ),
        );
        return i + 2;
      case _openBracket:
        final item = _Text('[');
        _append(item);
        _pushBracket(item, image: false, index: i + 1);
        return i + 1;
      case _bang:
        if (i + 1 < n && text.codeUnitAt(i + 1) == _openBracket) {
          final item = _Text('![');
          _append(item);
          _pushBracket(item, image: true, index: i + 2);
          return i + 2;
        }
        _buf.writeCharCode(c);
        return i + 1;
      case _closeBracket:
        return _closeBracketAt(i);
      case _lt:
        return _angle(i);
      case _amp:
        // Not inside a bare URL: the autolinker reads the raw text there, and
        // GFM has it leave a trailing `&amp;` out of the link, which it can
        // only do if the reference is still written.
        if (!urls.contains(i)) {
          final entity = entityAt(text, i);
          if (entity != null) {
            _buf.write(entity.value);
            return entity.next;
          }
        }
        _buf.writeCharCode(c);
        return i + 1;
      case _dollar:
        if (useDollar) {
          if (i + 1 < n && text.codeUnitAt(i + 1) == _dollar) {
            final end = text.indexOf(r'$$', i + 2);
            if (end != -1) {
              _append(
                _Node(MdInlineLatex(tex: text.substring(i + 2, end).trim())),
              );
              return end + 2;
            }
          }
          final end = dollars!.find(i);
          if (end != -1) {
            _append(
              _Node(MdInlineLatex(tex: text.substring(i + 1, end).trim())),
            );
            return end + 1;
          }
        }
        _buf.writeCharCode(c);
        return i + 1;
    }
    _buf.writeCharCode(c);
    return i + 1;
  }

  /// A line ending: a hard break after two or more spaces, otherwise kept as
  /// a newline — this package shows every line break, where CommonMark folds
  /// a soft one into a space. Spaces around it are dropped either way.
  int _lineBreak(int i) {
    // The spaces before it are the end of the buffer: nothing but plain text
    // writes a space. Counted in the source, so the buffer is only copied
    // when there are some to drop.
    var spaces = 0;
    while (i - spaces > 0 && text.codeUnitAt(i - spaces - 1) == _space) {
      spaces += 1;
    }
    if (spaces > 0) {
      final before = _buf.toString();
      _buf
        ..clear()
        ..write(before.substring(0, max(0, before.length - spaces)));
    }
    if (spaces >= 2) {
      _append(_Node(const MdLineBreak()));
    } else {
      _buf.writeCharCode(_newline);
    }
    // One line per buffer, so the copy above stays the length of a line.
    _flush();
    return _skipLeadingSpace(i + 1);
  }

  int _skipLeadingSpace(int i) {
    while (i < text.length &&
        (text.codeUnitAt(i) == _space || text.codeUnitAt(i) == _tab)) {
      i += 1;
    }
    return i;
  }

  // Where a search for `\)` / `\]` found none: a later search from further
  // right finds none either. Without this a line of stray `\(` costs a scan
  // to the end per opener.
  int _noRoundCloserFrom = -1;
  int _noSquareCloserFrom = -1;

  int _mathCloser(int from, {required bool round}) {
    final failed = round ? _noRoundCloserFrom : _noSquareCloserFrom;
    if (failed != -1 && from >= failed) {
      return -1;
    }
    final end = text.indexOf(round ? r'\)' : r'\]', from);
    if (end == -1) {
      if (round) {
        _noRoundCloserFrom = from;
      } else {
        _noSquareCloserFrom = from;
      }
    }
    return end;
  }

  int _backslashAt(int i) {
    final n = text.length;
    if (i + 1 >= n) {
      _buf.writeCharCode(_backslash);
      return i + 1;
    }
    final next = text.codeUnitAt(i + 1);
    // \( inline maths \) and \[ display maths \] — when they close around a
    // formula. Otherwise they are the escaped brackets CommonMark says they
    // are.
    if (next == _openParen || next == _openBracket) {
      final end = _mathCloser(i + 2, round: next == _openParen);
      if (end != -1) {
        final tex = text.substring(i + 2, end).trim();
        if (isMathBody(tex)) {
          _append(
            _Node(
              next == _openParen
                  ? MdInlineLatex(tex: tex)
                  : MdBlockLatex(tex: tex),
            ),
          );
          return end + 2;
        }
      }
    }
    // A backslash before a line break is a hard break.
    if (next == _newline) {
      _append(_Node(const MdLineBreak()));
      return _skipLeadingSpace(i + 2);
    }
    // Any ASCII punctuation after a backslash is literal — `\*`, `\_`, `\#`,
    // `\$`, and `\|`, the GFM escape a table cell uses for a pipe (cells are
    // split before this runs; see _splitPipes in block_parser.dart).
    if (isAsciiPunctuation(next)) {
      _buf.writeCharCode(next);
      return i + 2;
    }
    _buf.writeCharCode(_backslash);
    return i + 1;
  }

  // ----- emphasis -------------------------------------------------------

  int _delimiterRun(int i, int c) {
    final n = text.length;
    var run = 1;
    while (i + run < n && text.codeUnitAt(i + run) == c) {
      run += 1;
    }
    final canOpen = _canOpen(text, i, run, c, urls);
    final canClose = _canClose(text, i, run, c);
    final item = _Text(text.substring(i, i + run));
    _append(item);
    if (canOpen || canClose) {
      _pushDelimiter(
        _Delim(
          item: item,
          char: c,
          count: run,
          canOpen: canOpen,
          canClose: canClose,
        ),
      );
    }
    return i + run;
  }

  void _pushDelimiter(_Delim d) {
    d.prev = _delimiters;
    _delimiters?.next = d;
    _delimiters = d;
  }

  void _removeDelimiter(_Delim d) {
    d.prev?.next = d.next;
    if (d.next == null) {
      _delimiters = d.prev;
    } else {
      d.next!.prev = d.prev;
    }
  }

  /// Matches the delimiters above [bottom] into emphasis — CommonMark's
  /// "process emphasis" procedure.
  void _processEmphasis(_Delim? bottom) {
    // Per delimiter kind, how far down an opener search may go: below that,
    // an earlier search already found nothing.
    final openersBottom = <int, _Delim?>{};

    var closer = _delimiters;
    while (closer != null && closer.prev != bottom) {
      closer = closer.prev;
    }
    while (closer != null) {
      if (!closer.canClose) {
        closer = closer.next;
        continue;
      }
      final key =
          closer.char * 8 + (closer.canOpen ? 4 : 0) + closer.original % 3;
      final floor = openersBottom.containsKey(key)
          ? openersBottom[key]
          : bottom;
      var opener = closer.prev;
      var found = false;
      while (opener != null && opener != bottom && opener != floor) {
        if (opener.char == closer.char && opener.canOpen) {
          final oddMatch =
              closer.char != _tilde &&
              (closer.canOpen || opener.canClose) &&
              closer.original % 3 != 0 &&
              (opener.original + closer.original) % 3 == 0;
          if (!oddMatch) {
            found = true;
            break;
          }
        }
        opener = opener.prev;
      }

      if (!found) {
        openersBottom[key] = closer.prev;
        final next = closer.next;
        if (!closer.canOpen) {
          _removeDelimiter(closer);
        }
        closer = next;
        continue;
      }

      final o = opener!;
      final use = closer.char == _tilde
          ? 2
          : (closer.count >= 2 && o.count >= 2 ? 2 : 1);
      o.count -= use;
      closer.count -= use;
      o.item.text = o.item.text.substring(0, o.item.text.length - use);
      closer.item.text = closer.item.text.substring(use);

      final children = _takeBetween(o.item, closer.item);
      final MdNode node = closer.char == _tilde
          ? MdStrike(children: children)
          : use == 2
          ? MdBold(children: children)
          : MdItalic(children: children);
      _insertAfter(o.item, _Node(node));

      // Delimiters between the two are now inside the node, as text.
      var between = closer.prev;
      while (between != null && between != o) {
        final prev = between.prev;
        _removeDelimiter(between);
        between = prev;
      }
      if (o.count == 0) {
        _unlink(o.item);
        _removeDelimiter(o);
      }
      if (closer.count == 0) {
        final next = closer.next;
        _unlink(closer.item);
        _removeDelimiter(closer);
        closer = next;
      }
    }

    // What did not match is plain text.
    while (_delimiters != null && _delimiters != bottom) {
      _removeDelimiter(_delimiters!);
    }
  }

  // ----- links and images ----------------------------------------------

  void _pushBracket(_Text item, {required bool image, required int index}) {
    _brackets?.bracketAfter = true;
    _brackets = _Bracket(
      item: item,
      image: image,
      index: index,
      previous: _brackets,
      previousDelimiter: _delimiters,
    );
  }

  int _closeBracketAt(int i) {
    final opener = _brackets;
    if (opener == null) {
      _buf.writeCharCode(_closeBracket);
      return i + 1;
    }
    if (!opener.active) {
      _brackets = opener.previous;
      _buf.writeCharCode(_closeBracket);
      return i + 1;
    }
    _flush();
    final label = text.substring(opener.index, i);
    final after = i + 1;

    MdNode? node;
    var next = after;

    // [text](destination "title")
    final inline = after < text.length && text.codeUnitAt(after) == _openParen
        ? _inlineTarget(after)
        : null;
    if (inline != null) {
      node = _linkOrImage(opener, inline.url, inline.title);
      next = inline.next;
    }

    // [text][label], [text][] or [text] against a reference definition.
    var fullLabel = false;
    if (node == null) {
      final ref = _referenceAt(after);
      String? key;
      if (ref != null && ref.label.isNotEmpty) {
        key = ref.label;
        fullLabel = true;
      } else if (!opener.bracketAfter && !_isExtensionLabel(label)) {
        key = label;
      }
      final definition = key == null || key.length > 999
          ? null
          : defs.link(key);
      if (definition != null) {
        node = _linkOrImage(opener, definition.url, definition.title);
        next = ref?.next ?? after;
      }
      // A full reference that does not resolve leaves the brackets literal;
      // its label is scanned on as text of its own.
      if (node == null && fullLabel && !_isExtensionLabel(label)) {
        _brackets = opener.previous;
        _buf.writeCharCode(_closeBracket);
        return i + 1;
      }
    }

    // [^note] and [1] — the package's footnotes and citations.
    if (node == null && !opener.image) {
      node = _extension(opener, label);
    }

    if (node == null) {
      _brackets = opener.previous;
      _buf.writeCharCode(_closeBracket);
      return i + 1;
    }

    _insertAfter(opener.item, _Node(node));
    _unlink(opener.item);
    _brackets = opener.previous;
    if (!opener.image && node is MdLink) {
      // No links inside links: an earlier `[` can no longer make one.
      for (var b = _brackets; b != null; b = b.previous) {
        if (!b.image) {
          b.active = false;
        }
      }
    }
    return next;
  }

  /// The link or image [opener] makes: its text, parsed so far, becomes the
  /// node's content.
  MdNode _linkOrImage(_Bracket opener, String url, String? title) {
    _processEmphasis(opener.previousDelimiter);
    final children = _takeBetween(opener.item, null);
    if (opener.image) {
      final alt = plainText(children);
      final size = _parseImageSize(alt);
      return MdImage(
        url: url,
        alt: alt,
        width: size.width,
        height: size.height,
        title: title,
      );
    }
    return MdLink(children: children, url: url, title: title);
  }

  /// Whether [label] is the package's own bracket syntax rather than a
  /// reference: `^note` or all digits.
  static bool _isExtensionLabel(String label) =>
      label.startsWith('^') || (label.isNotEmpty && _allAsciiDigits(label));

  MdNode? _extension(_Bracket opener, String label) {
    if (label.isNotEmpty && _allAsciiDigits(label)) {
      // A citation stays a chip even when the document defines its URL.
      _takeBetween(opener.item, null);
      return MdSourceTag(id: label, url: defs.link(label)?.url);
    }
    if (label.length > 1 && label.codeUnitAt(0) == _caret) {
      final name = label.substring(1);
      for (var k = 0; k < name.length; k++) {
        final c = name.codeUnitAt(k);
        if (isUnicodeWhitespace(c) || c == _openBracket) {
          return null;
        }
      }
      final number = defs.footnote(name);
      if (number == null) {
        return null;
      }
      _takeBetween(opener.item, null);
      return MdFootnoteReference(label: name, number: number);
    }
    return null;
  }

  /// A `[label]` starting at [i]: its text and the index after it. An empty
  /// `[]` has an empty label. Null when there is no well-formed one.
  ({String label, int next})? _referenceAt(int i) {
    final n = text.length;
    if (i >= n || text.codeUnitAt(i) != _openBracket) {
      return null;
    }
    var j = i + 1;
    while (j < n && j - i <= 1000) {
      final c = text.codeUnitAt(j);
      if (c == _backslash && j + 1 < n) {
        j += 2;
        continue;
      }
      if (c == _openBracket) {
        return null;
      }
      if (c == _closeBracket) {
        final label = text.substring(i + 1, j);
        if (label.isNotEmpty && label.trim().isEmpty) {
          return null;
        }
        return (label: label, next: j + 1);
      }
      j += 1;
    }
    return null;
  }

  /// The `(destination "title")` starting at the `(` at [i].
  ///
  /// CommonMark's form first. Failing that, one leniency: everything up to
  /// the matching `)` on the same line is the destination — models write
  /// `[the report](My Report.pdf)`, spaces and all. Not when the text in
  /// brackets is a defined reference, which then wins, as CommonMark has it.
  ({String url, String? title, int next})? _inlineTarget(int i) {
    final strict = _strictTarget(i);
    if (strict != null) {
      return strict;
    }
    // The leniency needs a `)` before the line ends. Where the next `)` is,
    // is remembered: asked again further right, the answer is usually the
    // same, and without that a line of `[a](` repeated costs a scan to its
    // end per bracket.
    final n = text.length;
    if (_nextCloseParen < i + 1 && _nextCloseParen != -1) {
      _nextCloseParen = text.indexOf(')', i + 1);
    }
    if (_nextLineEnd < i + 1 && _nextLineEnd != -1) {
      _nextLineEnd = text.indexOf('\n', i + 1);
    }
    if (_nextCloseParen == -1 ||
        (_nextLineEnd != -1 && _nextLineEnd < _nextCloseParen)) {
      return null;
    }
    var depth = 0;
    var j = i + 1;
    while (j < n) {
      final c = text.codeUnitAt(j);
      if (c == _newline) {
        return null;
      }
      if (c == _backslash && j + 1 < n) {
        j += 2;
        continue;
      }
      if (c == _openParen) {
        depth += 1;
      } else if (c == _closeParen) {
        if (depth == 0) {
          break;
        }
        depth -= 1;
      }
      j += 1;
    }
    if (j >= n) {
      return null;
    }
    final raw = text.substring(i + 1, j).trim();
    if (raw.isEmpty || raw.startsWith('<')) {
      return null;
    }
    final opener = _brackets!;
    if (defs.link(text.substring(opener.index, i - 1)) != null) {
      return null;
    }
    return (
      url: decodeEntities(unescapeBackslashes(raw)),
      title: null,
      next: j + 1,
    );
  }

  int _nextCloseParen = -2;
  int _nextLineEnd = -2;

  ({String url, String? title, int next})? _strictTarget(int i) {
    final n = text.length;
    var p = _skipWhitespace(i + 1);
    if (p >= n) {
      return null;
    }
    // Destination.
    String url;
    if (text.codeUnitAt(p) == _lt) {
      var q = p + 1;
      while (q < n) {
        final c = text.codeUnitAt(q);
        if (c == _backslash && q + 1 < n) {
          q += 2;
          continue;
        }
        if (c == _newline || c == _lt || c == _gt) {
          break;
        }
        q += 1;
      }
      if (q >= n || text.codeUnitAt(q) != _gt) {
        return null;
      }
      url = text.substring(p + 1, q);
      p = q + 1;
    } else {
      var q = p;
      var depth = 0;
      while (q < n) {
        final c = text.codeUnitAt(q);
        if (c == _backslash &&
            q + 1 < n &&
            isAsciiPunctuation(text.codeUnitAt(q + 1))) {
          q += 2;
          continue;
        }
        if (c <= _space) {
          break;
        }
        if (c == _openParen) {
          depth += 1;
          if (depth > 32) {
            return null;
          }
        } else if (c == _closeParen) {
          if (depth == 0) {
            break;
          }
          depth -= 1;
        }
        q += 1;
      }
      if (depth != 0) {
        return null;
      }
      url = text.substring(p, q);
      p = q;
    }
    final destinationEnd = p;
    p = _skipWhitespace(p);
    if (p >= n) {
      return null;
    }
    String? title;
    final open = text.codeUnitAt(p);
    if (p > destinationEnd &&
        (open == _quote || open == _apostrophe || open == _openParen)) {
      final close = open == _openParen ? _closeParen : open;
      var q = p + 1;
      while (q < n) {
        final c = text.codeUnitAt(q);
        if (c == _backslash && q + 1 < n) {
          q += 2;
          continue;
        }
        if (c == close) {
          break;
        }
        if (open == _openParen && c == _openParen) {
          return null;
        }
        q += 1;
      }
      if (q >= n) {
        return null;
      }
      title = text.substring(p + 1, q);
      p = _skipWhitespace(q + 1);
    }
    if (p >= n || text.codeUnitAt(p) != _closeParen) {
      return null;
    }
    return (
      url: decodeEntities(unescapeBackslashes(url)),
      title: title == null ? null : decodeEntities(unescapeBackslashes(title)),
      next: p + 1,
    );
  }

  /// Past spaces, tabs and line breaks — ASCII whitespace only: a no-break
  /// space is part of a destination.
  int _skipWhitespace(int p) {
    while (p < text.length) {
      final c = text.codeUnitAt(p);
      if (c != _space && c != _tab && c != _newline) {
        break;
      }
      p += 1;
    }
    return p;
  }

  // ----- angle brackets -------------------------------------------------

  int _angle(int i) {
    // <!-- comment --> — dropped, as an HTML renderer would hide it.
    if (text.startsWith('<!--', i)) {
      final end = text.indexOf('-->', i + 4);
      if (end != -1) {
        return end + 3;
      }
    }

    // <https://example.com> and <someone@example.com>
    final autolink = _autolinkAt(i);
    if (autolink != null) {
      _append(
        _Node(
          MdLink(
            children: [MdText(text: autolink.text)],
            url: autolink.url,
            autolink: true,
          ),
        ),
      );
      return autolink.next;
    }

    // An allowlisted HTML tag: <b>, <br>, <a href>, <img src>, …
    final tag = htmlTagAt(text, i);
    if (tag != null && !tag.closing) {
      final next = _htmlTag(tag);
      if (next != -1) {
        return next;
      }
    }
    // A closing tag for an element that has none: browsers read `</br>` as
    // `<br>`, and drop the rest — `</img>`, `</hr>`.
    if (tag != null && tag.closing && voidHtmlTags.contains(tag.name)) {
      final kind = html[tag.name]?.kind;
      if (kind == HtmlTagKind.lineBreak) {
        _append(_Node(const MdLineBreak()));
        return tag.end;
      }
      if (kind != null) {
        return tag.end;
      }
    }

    _buf.writeCharCode(_lt);
    return i + 1;
  }

  /// Where [tag] — an opening tag — and what it encloses end, having added
  /// what its rule in [html] makes of it; -1 when it stays text.
  int _htmlTag(ParsedHtmlTag tag) {
    final syntax = html[tag.name];
    if (syntax == null) {
      return -1;
    }
    final kind = syntax.kind;
    switch (kind) {
      case HtmlTagKind.lineBreak:
        _append(_Node(const MdLineBreak()));
        return tag.end;
      case HtmlTagKind.image:
        final src = tag.attributes['src'];
        if (src == null || src.isEmpty) {
          return -1;
        }
        _append(
          _Node(
            MdImage(
              url: decodeEntities(src),
              alt: decodeEntities(tag.attributes['alt'] ?? ''),
              title: _attribute(tag, 'title'),
              width: double.tryParse(tag.attributes['width'] ?? ''),
              height: double.tryParse(tag.attributes['height'] ?? ''),
            ),
          ),
        );
        return tag.end;
      // A rule inside a line of text is not one.
      case HtmlTagKind.rule:
        return -1;
      // Mid-line, a checkbox is its glyph.
      case HtmlTagKind.checkbox:
        if ((tag.attributes['type'] ?? '').toLowerCase() != 'checkbox') {
          return -1;
        }
        _buf.write(tag.attributes.containsKey('checked') ? '☑' : '☐');
        return tag.end;
      default:
        break;
    }
    final element =
        kind == HtmlTagKind.inlineElement ||
        kind == HtmlTagKind.blockElement ||
        kind == HtmlTagKind.svg;
    if (tag.isVoid) {
      if (element) {
        _append(_Node(_element(tag, syntax, '', const [])));
        return tag.end;
      }
      // `<meta>`, `<link>`: nothing to show.
      return kind == HtmlTagKind.hidden ? tag.end : -1;
    }
    final close = _closeTag(
      tag.name,
      tag.end,
      nested: !htmlContentIsRaw(syntax),
    );
    if (close == null) {
      return -1;
    }
    final inner = text.substring(tag.end, close.start);
    switch (kind) {
      case HtmlTagKind.hidden:
        break;
      case HtmlTagKind.code || HtmlTagKind.codeBlock:
        _append(_Node(MdInlineCode(text: decodeEntities(inner))));
      case HtmlTagKind.bold:
        _append(_Node(MdBold(children: _parse(inner))));
      case HtmlTagKind.italic:
        _append(_Node(MdItalic(children: _parse(inner))));
      case HtmlTagKind.strike:
        _append(_Node(MdStrike(children: _parse(inner))));
      case HtmlTagKind.underline:
        _append(_Node(MdUnderline(children: _parse(inner))));
      case HtmlTagKind.superscript:
        _append(_Node(MdSuperscript(children: _parse(inner))));
      case HtmlTagKind.subscript:
        _append(_Node(MdSubscript(children: _parse(inner))));
      case HtmlTagKind.highlight:
        _append(_Node(MdHighlight(children: _parse(inner))));
      case HtmlTagKind.link:
        final href = tag.attributes['href'];
        if (href == null) {
          _splice(_parse(inner));
        } else {
          _append(
            _Node(
              MdLink(
                children: _parse(inner),
                url: decodeEntities(href),
                title: _attribute(tag, 'title'),
              ),
            ),
          );
        }
      case HtmlTagKind.inlineElement ||
          HtmlTagKind.blockElement ||
          HtmlTagKind.svg:
        _append(
          _Node(
            _element(
              tag,
              syntax,
              inner,
              syntax.rawContent ? const [] : _parse(inner),
            ),
          ),
        );
      // `<span>`, and a block tag inside a line: the content, as if
      // untagged.
      default:
        _splice(_parse(inner));
    }
    return close.end;
  }

  List<MdNode> _parse(String inner) =>
      parseInline(inner, useDollar, defs, html);

  MdCustomBlock _element(
    ParsedHtmlTag tag,
    HtmlTagSyntax syntax,
    String inner,
    List<MdNode> children,
  ) => MdCustomBlock(
    type: htmlElementType,
    body: inner,
    data: HtmlElementData(
      name: tag.name,
      attributes: {
        for (final entry in tag.attributes.entries)
          entry.key: decodeEntities(entry.value),
      },
      children: children,
      source: inner,
      block: false,
    ),
  );

  String? _attribute(ParsedHtmlTag tag, String name) {
    final value = tag.attributes[name];
    return value == null ? null : decodeEntities(value);
  }

  /// [nodes] added in place, text merged with the text around it.
  void _splice(List<MdNode> nodes) {
    for (final node in nodes) {
      if (node is MdText) {
        _buf.write(node.text);
      } else {
        _append(_Node(node));
      }
    }
  }

  /// Per tag name, where its last closing tag in [text] starts, or -1.
  ///
  /// An opening tag after that point cannot be closed, so it is text without
  /// a search — which keeps a line of a thousand stray `<b>` linear. A failed
  /// search says nothing about a later opening tag: in
  /// `The <b> tag makes <b>text bold.</b>` the first `<b>` finds no closer of
  /// its own (the `</b>` belongs to the second), and the second still has
  /// one.
  Map<String, int>? _lastCloseTag;

  int _lastCloseTagOf(String name) =>
      (_lastCloseTag ??= {})[name] ??= _findLastCloseTag(name);

  int _findLastCloseTag(String name) {
    var p = text.lastIndexOf('</');
    while (p != -1) {
      final tag = htmlTagAt(text, p);
      if (tag != null && tag.closing && tag.name == name) {
        return p;
      }
      p = p == 0 ? -1 : text.lastIndexOf('</', p - 1);
    }
    return -1;
  }

  /// The closing tag for the opening tag [name] ending at [from]: the
  /// nearest-pair rule of [matchingCloseTag], or its first closer when
  /// not [nested].
  ({int start, int end})? _closeTag(
    String name,
    int from, {
    required bool nested,
  }) {
    if (from > _lastCloseTagOf(name)) {
      return null;
    }
    return matchingCloseTag(text, name, from, nested: nested);
  }

  /// A CommonMark autolink at [i]: `<scheme:anything-but-space>` or
  /// `<email@address>`.
  ({String text, String url, int next})? _autolinkAt(int i) {
    final n = text.length;
    var j = i + 1;
    // URI: a scheme of 2–32 characters, a colon, no spaces, `<` or `>`.
    if (j < n && _isAsciiLetter(text.codeUnitAt(j))) {
      var k = j + 1;
      while (k < n && k - j < 33) {
        final c = text.codeUnitAt(k);
        if (_isAsciiAlphanumeric(c) || c == 0x2B || c == 0x2E || c == 0x2D) {
          k += 1;
        } else {
          break;
        }
      }
      final scheme = k - j;
      if (k < n &&
          text.codeUnitAt(k) == 0x3A /* : */ &&
          scheme >= 2 &&
          scheme <= 32) {
        var e = k + 1;
        while (e < n) {
          final c = text.codeUnitAt(e);
          if (c <= _space || c == _lt || c == _gt) {
            break;
          }
          e += 1;
        }
        if (e < n && text.codeUnitAt(e) == _gt) {
          final uri = text.substring(j, e);
          return (text: uri, url: uri, next: e + 1);
        }
      }
    }
    // Email.
    final end = text.indexOf('>', j);
    if (end == -1) {
      return null;
    }
    final candidate = text.substring(j, end);
    if (_email.hasMatch(candidate)) {
      return (text: candidate, url: 'mailto:$candidate', next: end + 1);
    }
    return null;
  }
}

bool _isAsciiLetter(int c) =>
    (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);

final RegExp _email = RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
);

/// The text [nodes] read as: what an image's alt text is made of.
String plainText(List<MdNode> nodes) {
  final out = StringBuffer();
  void walk(List<MdNode> nodes) {
    for (final node in nodes) {
      switch (node) {
        case MdText(:final text):
          out.write(text);
        case MdInlineCode(:final text):
          out.write(text);
        case MdInlineLatex(:final tex):
          out.write(tex);
        case MdImage(:final alt):
          out.write(alt);
        case MdLineBreak():
          out.write('\n');
        case MdSourceTag(:final id):
          out.write('[$id]');
        case MdBold(:final children) ||
            MdItalic(:final children) ||
            MdStrike(:final children) ||
            MdUnderline(:final children) ||
            MdSuperscript(:final children) ||
            MdSubscript(:final children) ||
            MdHighlight(:final children) ||
            MdLink(:final children):
          walk(children);
        default:
          break;
      }
    }
  }

  walk(nodes);
  return out.toString();
}

/// Whether the run of [run] [delimiter]s at [i] can open emphasis.
///
/// CommonMark's flanking rules, with one leniency: a run of two or more `*`
/// only needs a non-space after it to open, and a non-space before it to
/// close. CommonMark's punctuation rule would stop `**Note:**text` and CJK
/// text such as `**粗体：**中文` from being bold, which models write
/// constantly. A single `*` follows CommonMark exactly, so `2 * 3 * 4` and
/// `a*"b"*` stay as written.
///
/// `_` cannot open inside a word — `snake_case_name` stays an identifier —
/// nor inside a bare URL, so `https://x.com/_a_` reaches the autolinker
/// whole.
bool _canOpen(String text, int i, int run, int delimiter, _BareUrls urls) {
  final after = codePointAt(text, i + run);
  if (isUnicodeWhitespace(after)) {
    return false;
  }
  if (delimiter == _star && run >= 2) {
    return true;
  }
  final before = codePointBefore(text, i);
  final beforeSpace = isUnicodeWhitespace(before);
  final beforePunctuation = isUnicodePunctuation(before);
  final leftFlanking =
      !isUnicodePunctuation(after) || beforeSpace || beforePunctuation;
  if (!leftFlanking) {
    return false;
  }
  if (delimiter == _star) {
    return true;
  }
  // Also right-flanking — inside a word — unless punctuation precedes it.
  final rightFlanking = !beforeSpace;
  if (rightFlanking && !beforePunctuation) {
    return false;
  }
  return !urls.contains(i);
}

/// Whether the run of [run] [delimiter]s at [i] can close emphasis — the
/// mirror image of [_canOpen].
bool _canClose(String text, int i, int run, int delimiter) {
  final before = codePointBefore(text, i);
  if (isUnicodeWhitespace(before)) {
    return false;
  }
  if (delimiter == _star && run >= 2) {
    return true;
  }
  final after = codePointAt(text, i + run);
  final afterSpace = isUnicodeWhitespace(after);
  final afterPunctuation = isUnicodePunctuation(after);
  final rightFlanking =
      !isUnicodePunctuation(before) || afterSpace || afterPunctuation;
  if (!rightFlanking) {
    return false;
  }
  if (delimiter == _star) {
    return true;
  }
  // Also left-flanking — inside a word — unless punctuation follows it.
  return afterSpace || afterPunctuation;
}

/// Answers "is this position inside a bare URL?" for one parse: whether
/// the whitespace-delimited word around it starts with `www.` or holds `://`
/// before it.
///
/// Positions must be asked about left to right. The scan state carries over
/// between questions, so the whole parse reads each character once — walking
/// back to the start of the word on every `&` or `_` made a long run of them
/// quadratic.
class _BareUrls {
  _BareUrls(this.text);

  final String text;
  int _scanned = 0;
  int _wordStart = 0;
  bool _hasScheme = false;

  bool contains(int i) {
    for (var j = _scanned; j < i; j++) {
      final c = text.codeUnitAt(j);
      if (isUnicodeWhitespace(c)) {
        _wordStart = j + 1;
        _hasScheme = false;
      } else if (!_hasScheme &&
          c == 0x2F /* / */ &&
          j - 2 >= _wordStart &&
          text.codeUnitAt(j - 1) == 0x2F &&
          text.codeUnitAt(j - 2) == 0x3A /* : */ ) {
        _hasScheme = true;
      }
    }
    if (i > _scanned) {
      _scanned = i;
    }
    if (_hasScheme) {
      return true;
    }
    return i - _wordStart >= 4 &&
        text.substring(_wordStart, _wordStart + 4).toLowerCase() == 'www.';
  }
}

/// Parse an alt text of the form `WxH` (e.g. `100x200`, `100x`, `x200`).
({double? width, double? height}) _parseImageSize(String alt) {
  final t = alt.trim();
  final x = t.indexOf('x');
  if (x != -1) {
    final a = t.substring(0, x);
    final b = t.substring(x + 1);
    final aOk = a.isNotEmpty && _allAsciiDigits(a);
    final bOk = b.isNotEmpty && _allAsciiDigits(b);
    if ((aOk || a.isEmpty) && (bOk || b.isEmpty) && (aOk || bOk)) {
      return (
        width: aOk ? double.tryParse(a) : null,
        height: bOk ? double.tryParse(b) : null,
      );
    }
  }
  return (width: null, height: null);
}

bool _allAsciiDigits(String s) {
  for (var i = 0; i < s.length; i++) {
    final c = s.codeUnitAt(i);
    if (c < 0x30 || c > 0x39) {
      return false;
    }
  }
  return true;
}
