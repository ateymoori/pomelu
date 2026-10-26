/// Low-level, single-pass line helpers shared by the block parser. No regex —
/// everything is hand-written character scanning (ported 1:1 from the Rust
/// plusparse scanner).
library;

const int _space = 0x20; // ' '
const int _tab = 0x09; // '\t'
const int _hash = 0x23; // '#'
const int _zero = 0x30; // '0'
const int _nine = 0x39; // '9'

/// Number of leading-indent columns (space = 1, tab = 4).
int indentWidth(String line) {
  var w = 0;
  for (var i = 0; i < line.length; i++) {
    final c = line.codeUnitAt(i);
    if (c == _space) {
      w += 1;
    } else if (c == _tab) {
      w += 4;
    } else {
      break;
    }
  }
  return w;
}

/// Remove up to [max] columns of leading indentation, returning the remainder.
String stripIndent(String line, int max) {
  var removed = 0;
  var idx = 0;
  while (idx < line.length && removed < max) {
    final c = line.codeUnitAt(idx);
    if (c == _space) {
      removed += 1;
      idx += 1;
    } else if (c == _tab) {
      // A tab only partly inside the indent leaves the rest of its width
      // as spaces.
      if (removed + 4 > max) {
        return ' ' * (removed + 4 - max) + line.substring(idx + 1);
      }
      removed += 4;
      idx += 1;
    } else {
      break;
    }
  }
  return line.substring(idx);
}

bool isBlank(String line) => line.trim().isEmpty;

/// ATX heading: 1–6 `#` followed by a space or tab, or ending the line — `#`
/// alone is an empty heading. Returns (level, content), with the optional
/// closing sequence (`## Title ##`) removed.
({int level, String content})? isHeading(String trimmed) {
  var level = 0;
  while (level < trimmed.length && trimmed.codeUnitAt(level) == _hash) {
    level += 1;
  }
  if (level < 1 || level > 6) {
    return null;
  }
  if (level == trimmed.length) {
    return (level: level, content: '');
  }
  final after = trimmed.codeUnitAt(level);
  if (after != _space && after != _tab) {
    return null;
  }
  return (
    level: level,
    content: stripClosingHashes(trimmed.substring(level + 1).trim()),
  );
}

/// Thematic break: 3+ of `-`, `*`, or `_` (optionally space-separated), or `⸻`.
bool isHr(String trimmed) {
  final start = firstNonSpace(trimmed);
  if (start == -1) {
    return false;
  }
  final lead = trimmed.codeUnitAt(start);
  if (lead != 0x2D /* - */ &&
      lead != 0x2A /* * */ &&
      lead != 0x5F /* _ */ &&
      lead != 0x2E3B /* ⸻ */ ) {
    return false;
  }
  final t = trimmed.trim();
  if (t == '⸻') {
    return true;
  }
  if (t.isEmpty) {
    return false;
  }
  final first = t[0];
  if (first != '-' && first != '*' && first != '_') {
    return false;
  }
  var count = 0;
  for (var i = 0; i < t.length; i++) {
    final c = t[i];
    if (c == first) {
      count += 1;
    } else if (c == ' ') {
      continue;
    } else {
      return false;
    }
  }
  return count >= 3;
}

/// `- `, `* `, or `+ ` bullet. Returns the content after the marker.
String? unorderedMarker(String trimmed) {
  if (trimmed.length >= 2 && trimmed.codeUnitAt(1) == _space) {
    final c = trimmed[0];
    if (c == '-' || c == '*' || c == '+') {
      return trimmed.substring(2);
    }
  }
  return null;
}

/// `N. ` or `N) ` ordered marker. Returns (number, content).
({int number, String content})? orderedMarker(String trimmed) {
  var idx = 0;
  while (idx < trimmed.length) {
    final c = trimmed.codeUnitAt(idx);
    if (c < _zero || c > _nine) {
      break;
    }
    idx += 1;
  }
  if (idx == 0) {
    return null;
  }
  if (idx < trimmed.length &&
      (trimmed[idx] == '.' || trimmed[idx] == ')') &&
      idx + 1 < trimmed.length &&
      trimmed.codeUnitAt(idx + 1) == _space) {
    final num = int.tryParse(trimmed.substring(0, idx)) ?? 1;
    return (number: num, content: trimmed.substring(idx + 2));
  }
  return null;
}

/// A list item's marker, as CommonMark reads it.
class ListMarker {
  const ListMarker({
    required this.indent,
    required this.ordered,
    required this.delimiter,
    required this.number,
    required this.contentCol,
    required this.content,
    required this.blank,
  });

  /// Columns of indentation before the marker.
  final int indent;
  final bool ordered;

  /// The bullet (`-`, `+`, `*`) or, for an ordered marker, the character
  /// after the number (`.` or `)`). Changing it starts a new list.
  final int delimiter;

  /// The ordered number; 0 for a bullet.
  final int number;

  /// The column the item's content starts at. Lines indented this far belong
  /// to the item.
  final int contentCol;

  /// The rest of the marker line: the item's first line.
  final String content;

  /// Whether nothing follows the marker on its line.
  final bool blank;

  /// Whether an item with this marker continues a list started with [other].
  bool sameKind(ListMarker other) =>
      ordered == other.ordered && delimiter == other.delimiter;
}

/// The list marker opening [line] — `-`, `+` or `*`, or up to nine digits and
/// `.` or `)` — followed by whitespace or the end of the line.
///
/// One to four spaces after the marker set where the content starts. Five or
/// more count as one (CommonMark reads the rest as indented code inside the
/// item), and so does an empty item, whose content starts on the next line.
ListMarker? listMarkerAt(String line) {
  var idx = 0;
  var indent = 0;
  while (idx < line.length) {
    final c = line.codeUnitAt(idx);
    if (c == _space) {
      indent += 1;
    } else if (c == _tab) {
      indent += 4;
    } else {
      break;
    }
    idx += 1;
  }
  if (idx >= line.length) {
    return null;
  }
  final first = line.codeUnitAt(idx);
  var ordered = false;
  var number = 0;
  int delimiter;
  var end = idx;
  if (first == 0x2D /* - */ ||
      first == 0x2B /* + */ ||
      first == 0x2A /* * */ ) {
    delimiter = first;
    end = idx + 1;
  } else {
    while (end < line.length &&
        end - idx < 10 &&
        line.codeUnitAt(end) >= _zero &&
        line.codeUnitAt(end) <= _nine) {
      end += 1;
    }
    final digits = end - idx;
    if (digits == 0 || digits > 9 || end >= line.length) {
      return null;
    }
    delimiter = line.codeUnitAt(end);
    if (delimiter != 0x2E /* . */ && delimiter != 0x29 /* ) */ ) {
      return null;
    }
    ordered = true;
    number = int.parse(line.substring(idx, end));
    end += 1;
  }
  final markerCol = indent + (end - idx);
  if (end == line.length) {
    return ListMarker(
      indent: indent,
      ordered: ordered,
      delimiter: delimiter,
      number: number,
      contentCol: markerCol + 1,
      content: '',
      blank: true,
    );
  }
  final after = line.codeUnitAt(end);
  if (after != _space && after != _tab) {
    return null;
  }
  var spaceEnd = end;
  var width = 0;
  while (spaceEnd < line.length) {
    final c = line.codeUnitAt(spaceEnd);
    if (c == _space) {
      width += 1;
    } else if (c == _tab) {
      width += 4 - (markerCol + width) % 4;
    } else {
      break;
    }
    spaceEnd += 1;
  }
  if (spaceEnd == line.length) {
    return ListMarker(
      indent: indent,
      ordered: ordered,
      delimiter: delimiter,
      number: number,
      contentCol: markerCol + 1,
      content: '',
      blank: true,
    );
  }
  if (width > 4) {
    return ListMarker(
      indent: indent,
      ordered: ordered,
      delimiter: delimiter,
      number: number,
      contentCol: markerCol + 1,
      content: line.substring(end + 1),
      blank: false,
    );
  }
  return ListMarker(
    indent: indent,
    ordered: ordered,
    delimiter: delimiter,
    number: number,
    contentCol: markerCol + width,
    content: line.substring(spaceEnd),
    blank: false,
  );
}

/// Whether [tex] — the inside of `\(…\)` or `\[…\]` — is a formula.
///
/// Not when it is empty, or nothing but punctuation and spaces: `\(\)` and
/// `\[\\\]` are escaped brackets in prose, and a "formula" of only symbols
/// is almost always that.
bool isMathBody(String tex) {
  for (var i = 0; i < tex.length; i++) {
    final c = tex.codeUnitAt(i);
    if (c != _space && c != _tab && c != 0x0A && !isAsciiPunctuation(c)) {
      return true;
    }
  }
  return false;
}

/// `[x] ` / `[ ] ` checkbox. Returns (checked, content).
({bool checked, String content})? checkboxMarker(String trimmed) {
  if (trimmed.startsWith('[x] ') || trimmed.startsWith('[X] ')) {
    return (checked: true, content: trimmed.substring(4));
  }
  if (trimmed.startsWith('[ ] ')) {
    return (checked: false, content: trimmed.substring(4));
  }
  return null;
}

/// `(x) ` / `( ) ` radio. Returns (selected, content).
({bool selected, String content})? radioMarker(String trimmed) {
  if (trimmed.startsWith('(x) ') || trimmed.startsWith('(X) ')) {
    return (selected: true, content: trimmed.substring(4));
  }
  if (trimmed.startsWith('( ) ')) {
    return (selected: false, content: trimmed.substring(4));
  }
  return null;
}

// ---------------------------------------------------------------------------
// Fenced code blocks
// ---------------------------------------------------------------------------

const int _backtickUnit = 0x60; // '`'
const int _tildeUnit = 0x7E; // '~'

/// The opening line of a fenced code block: a run of at least three backticks
/// or tildes.
///
/// [fenceChar] and [length] are what a closing line has to match — see
/// [isFenceClose]. [info] is the rest of the line, trimmed (the language).
typedef FenceOpen = ({int fenceChar, int length, String info});

/// The fence [trimmed] (an already left-trimmed line) opens, or null.
///
/// CommonMark: a backtick fence's info string may not contain a backtick.
/// That is what keeps a one-line ```` ```code``` ```` an inline code span
/// instead of a fence that swallows the rest of the document.
FenceOpen? fenceOpen(String trimmed) {
  if (trimmed.length < 3) {
    return null;
  }
  final c = trimmed.codeUnitAt(0);
  if (c != _backtickUnit && c != _tildeUnit) {
    return null;
  }
  var run = 1;
  while (run < trimmed.length && trimmed.codeUnitAt(run) == c) {
    run += 1;
  }
  if (run < 3) {
    return null;
  }
  final info = trimmed.substring(run).trim();
  if (c == _backtickUnit && info.contains('`')) {
    return null;
  }
  return (fenceChar: c, length: run, info: info);
}

/// Whether [line] closes [open]: the same character, at least as many of
/// them, and nothing after but whitespace.
bool isFenceClose(String line, FenceOpen open) {
  final t = line.trim();
  if (t.length < open.length) {
    return false;
  }
  for (var i = 0; i < t.length; i++) {
    if (t.codeUnitAt(i) != open.fenceChar) {
      return false;
    }
  }
  return true;
}

/// Whether a fence opened in [lines] is still open after the last line.
///
/// The one fence-tracking loop shared by the parser's neighbours (segment
/// splitting, the streaming reveal), so they agree with the parser about
/// where a fence ends.
///
/// Fences inside a block quote count: ```` > ```bash ```` opens one, and it
/// closes with its closing line or when the quote ends.
FenceOpen? openFenceAfter(Iterable<String> lines) {
  FenceOpen? open;
  var depth = 0;
  for (final line in lines) {
    final current = open;
    final lineDepth = quoteDepth(line);
    if (current != null && lineDepth >= depth) {
      if (isFenceClose(unquoted(line), current)) {
        open = null;
      }
      continue;
    }
    open = fenceOpen(unquoted(line));
    depth = lineDepth;
  }
  return open;
}

// ---------------------------------------------------------------------------
// Code spans
// ---------------------------------------------------------------------------

/// The code span whose opening backtick run starts at [i], if it closes.
///
/// CommonMark: a span opens with a run of N backticks and closes at the next
/// run of exactly N. Returns the index of the closing run and N, or null when
/// no run of the same length follows — the opening run is then literal text.
///
/// [end] bounds the search, for callers scanning more than one paragraph: a
/// code span never crosses a blank line.
({int close, int run})? codeSpanAt(String text, int i, {int? end}) {
  final n = end ?? text.length;
  var run = 0;
  while (i + run < n && text.codeUnitAt(i + run) == _backtickUnit) {
    run += 1;
  }
  if (run == 0) {
    return null;
  }
  var j = i + run;
  while (j < n) {
    if (text.codeUnitAt(j) != _backtickUnit) {
      j += 1;
      continue;
    }
    var close = 0;
    while (j + close < n && text.codeUnitAt(j + close) == _backtickUnit) {
      close += 1;
    }
    if (close == run) {
      return (close: j, run: run);
    }
    j += close;
  }
  return null;
}

/// Length of the backtick run starting at [i].
int backtickRunAt(String text, int i) {
  var run = 0;
  while (i + run < text.length && text.codeUnitAt(i + run) == _backtickUnit) {
    run += 1;
  }
  return run;
}

/// The content of a code span, normalised the CommonMark way: line endings
/// become spaces, and one space is stripped from each end when both ends have
/// one and the content is not all spaces — which is what lets
/// ``` `` `a` `` ``` hold a backtick at its edge.
String codeSpanContent(String raw) {
  var s = raw.contains('\n') ? raw.replaceAll('\n', ' ') : raw;
  if (s.length >= 2 &&
      s.codeUnitAt(0) == _space &&
      s.codeUnitAt(s.length - 1) == _space &&
      s.trim().isNotEmpty) {
    s = s.substring(1, s.length - 1);
  }
  return s;
}

// ---------------------------------------------------------------------------
// Character classes
// ---------------------------------------------------------------------------

/// Whether [unit] is ASCII punctuation — the set a backslash can escape.
bool isAsciiPunctuation(int unit) =>
    (unit >= 0x21 && unit <= 0x2F) ||
    (unit >= 0x3A && unit <= 0x40) ||
    (unit >= 0x5B && unit <= 0x60) ||
    (unit >= 0x7B && unit <= 0x7E);

/// Unicode whitespace in CommonMark's sense: the `Zs` category plus tab, line
/// feed, form feed and carriage return. -1 (outside the text) counts as
/// whitespace, so the start and end of a run behave like a space.
bool isUnicodeWhitespace(int codePoint) {
  if (codePoint < 0) {
    return true;
  }
  if (codePoint < 0x80) {
    return codePoint == _space ||
        codePoint == _tab ||
        codePoint == 0x0A ||
        codePoint == 0x0C ||
        codePoint == 0x0D;
  }
  return codePoint == 0xA0 ||
      codePoint == 0x1680 ||
      (codePoint >= 0x2000 && codePoint <= 0x200A) ||
      codePoint == 0x202F ||
      codePoint == 0x205F ||
      codePoint == 0x3000;
}

final RegExp _unicodePunctuation = RegExp(r'^[\p{P}\p{S}]$', unicode: true);

/// Unicode punctuation in CommonMark's sense: the `P` and `S` categories.
bool isUnicodePunctuation(int codePoint) {
  if (codePoint < 0) {
    return false;
  }
  if (codePoint < 0x80) {
    return isAsciiPunctuation(codePoint);
  }
  return _unicodePunctuation.hasMatch(String.fromCharCode(codePoint));
}

/// The code point that ends just before [i], or -1 at the start.
int codePointBefore(String text, int i) {
  if (i <= 0) {
    return -1;
  }
  final low = text.codeUnitAt(i - 1);
  if (low >= 0xDC00 && low <= 0xDFFF && i >= 2) {
    final high = text.codeUnitAt(i - 2);
    if (high >= 0xD800 && high <= 0xDBFF) {
      return 0x10000 + ((high - 0xD800) << 10) + (low - 0xDC00);
    }
  }
  return low;
}

/// The code point that starts at [i], or -1 at the end.
int codePointAt(String text, int i) {
  if (i >= text.length) {
    return -1;
  }
  final high = text.codeUnitAt(i);
  if (high >= 0xD800 && high <= 0xDBFF && i + 1 < text.length) {
    final low = text.codeUnitAt(i + 1);
    if (low >= 0xDC00 && low <= 0xDFFF) {
      return 0x10000 + ((high - 0xD800) << 10) + (low - 0xDC00);
    }
  }
  return high;
}

// ---------------------------------------------------------------------------
// Headings
// ---------------------------------------------------------------------------

/// The level of a setext underline — `1` for `===`, `2` for `---` — or null.
///
/// Up to three spaces of indent, then one run of a single character, then
/// only whitespace. Internal spaces (`- - -`) make it a thematic break, not an
/// underline.
int? setextUnderlineLevel(String line) {
  final indent = firstNonSpace(line);
  if (indent == -1 || indent > 3) {
    return null;
  }
  final first = line.codeUnitAt(indent);
  if (first != 0x3D /* = */ && first != 0x2D /* - */ ) {
    return null;
  }
  final t = line.trim();
  if (t.isEmpty) {
    return null;
  }
  final c = t.codeUnitAt(0);
  if (c != 0x3D /* = */ && c != 0x2D /* - */ ) {
    return null;
  }
  for (var i = 1; i < t.length; i++) {
    if (t.codeUnitAt(i) != c) {
      return null;
    }
  }
  return c == 0x3D ? 1 : 2;
}

/// [content] without an ATX heading's optional closing sequence.
///
/// `# Title ##` is `Title`. The `#`s only close the heading when a space comes
/// before them, so `# C#` keeps its `#`, and so does an escaped `\#`.
String stripClosingHashes(String content) {
  var end = content.length;
  while (end > 0 && content.codeUnitAt(end - 1) == _hash) {
    end -= 1;
  }
  if (end == content.length) {
    return content;
  }
  if (end == 0) {
    return '';
  }
  final before = content.codeUnitAt(end - 1);
  if (before != _space && before != _tab) {
    return content;
  }
  return content.substring(0, end).trimRight();
}

// ---------------------------------------------------------------------------
// HTML comments
// ---------------------------------------------------------------------------

/// Index of the first character that is not a space or tab, or -1.
int firstNonSpace(String line) {
  for (var i = 0; i < line.length; i++) {
    final c = line.codeUnitAt(i);
    if (c != _space && c != _tab) {
      return i;
    }
  }
  return -1;
}

/// Whether [line] starts, after up to three spaces, with [unit] — the cheap
/// test that lets a line-level check skip copying a line that cannot match.
bool startsAfterIndent(String line, int unit) {
  final i = firstNonSpace(line);
  return i != -1 && i <= 3 && line.codeUnitAt(i) == unit;
}

/// Whether [trimmed] opens an HTML comment.
bool startsHtmlComment(String trimmed) => trimmed.startsWith('<!--');

// ---------------------------------------------------------------------------
// Dollar maths
// ---------------------------------------------------------------------------

/// Finds the closing `$` of single-dollar maths, for one text.
///
/// Maths first: a `$` pairs with the next unescaped `$` on its line, and the
/// pair is maths unless it is provably two prices —
///
/// * both dollars lead an amount: `$5 and $10`, `$5-$10`, `$5M to $10M`;
/// * both dollars follow one: `5$ and 10$`.
///
/// Everything else on one line is maths: `$ x $`, `$2 + 3$`,
/// `$1a \theta $2`, `$1 \theta $2a`. A `$` with no partner on its line, a
/// pair with nothing but spaces between, and a `$` next to another `$` (half
/// of a `$$`) open nothing. An escaped `\$` is never a partner.
///
/// The second dollar of a price pair is spent: it does not open again, so
/// in `$5 and $10 then $x$` only `x` is maths.
///
/// The one rule the parser, the `$` rewrite and the streaming reveal share.
/// Openers must be asked about left to right, each at most once, so the
/// spent dollars are known. Each search stops at the next `$` or line break,
/// so a whole text costs one pass.
class DollarMathCloser {
  DollarMathCloser(this.text);

  final String text;

  /// The second dollar of the last price pair, which opens nothing.
  int _spent = -1;

  /// The closer for the `$` at [i], or -1.
  int find(int i) {
    if (i == _spent) {
      return -1;
    }
    final n = text.length;
    if (i > 0 && text.codeUnitAt(i - 1) == _dollarSign) {
      return -1;
    }
    var k = i + 1;
    if (k < n && text.codeUnitAt(k) == _dollarSign) {
      return -1;
    }
    var blank = true;
    while (k < n) {
      final c = text.codeUnitAt(k);
      if (c == 0x0A) {
        return -1;
      }
      if (c == _dollarSign && text.codeUnitAt(k - 1) != _backslashChar) {
        break;
      }
      if (blank && !isUnicodeWhitespace(c)) {
        blank = false;
      }
      k += 1;
    }
    if (k >= n || blank) {
      return -1;
    }
    if (k + 1 < n && text.codeUnitAt(k + 1) == _dollarSign) {
      return -1;
    }
    if ((leadsPrice(text, i) && leadsPrice(text, k)) ||
        (followsPrice(text, i) && followsPrice(text, k))) {
      _spent = k;
      return -1;
    }
    return k;
  }
}

const int _dollarSign = 0x24;
const int _backslashChar = 0x5C;

/// Whether the `$` at [i] is directly followed by an amount: digits, with
/// `,` groups and a `.` fraction (`5`, `1,000`, `9.99`), an optional size
/// suffix (`k`, `K`, `M`, `B`, `bn`, `m`), then the end of the word.
bool leadsPrice(String text, int i) {
  final n = text.length;
  var k = i + 1;
  if (k >= n || !_isDigit(text.codeUnitAt(k))) {
    return false;
  }
  while (k < n) {
    final c = text.codeUnitAt(k);
    if (_isDigit(c)) {
      k += 1;
    } else if ((c == 0x2C /* , */ || c == 0x2E /* . */ ) &&
        k + 1 < n &&
        _isDigit(text.codeUnitAt(k + 1))) {
      k += 2;
    } else {
      break;
    }
  }
  if (k < n) {
    final c = text.codeUnitAt(k);
    if (c == 0x62 /* b */ && k + 1 < n && text.codeUnitAt(k + 1) == 0x6E) {
      k += 2; // bn
    } else if (c == 0x6B /* k */ ||
        c == 0x4B /* K */ ||
        c == 0x4D /* M */ ||
        c == 0x42 /* B */ ||
        c == 0x6D /* m */ ) {
      k += 1;
    }
  }
  return _endsWord(text, k);
}

/// Whether the `$` at [i] directly follows an amount (`5$`, `9.99$`,
/// `1,000$`) that starts a word, and ends its own word.
bool followsPrice(String text, int i) {
  var k = i - 1;
  if (k < 0 || !_isDigit(text.codeUnitAt(k))) {
    return false;
  }
  while (k >= 0) {
    final c = text.codeUnitAt(k);
    if (_isDigit(c)) {
      k -= 1;
    } else if ((c == 0x2C || c == 0x2E) &&
        k > 0 &&
        _isDigit(text.codeUnitAt(k - 1))) {
      k -= 2;
    } else {
      break;
    }
  }
  if (k >= 0 && _isWordPart(text.codeUnitAt(k))) {
    return false;
  }
  return _endsWord(text, i + 1);
}

bool _isDigit(int c) => c >= _zero && c <= _nine;

/// A character that would make an amount part of something else: a letter,
/// a digit, or TeX's `\`, `^`, `_`, `{`, `}`.
bool _isWordPart(int c) =>
    _isDigit(c) ||
    (c >= 0x41 && c <= 0x5A) ||
    (c >= 0x61 && c <= 0x7A) ||
    c == _backslashChar ||
    c == 0x5E /* ^ */ ||
    c == 0x5F /* _ */ ||
    c == 0x7B /* { */ ||
    c == 0x7D /* } */;

bool _endsWord(String text, int k) =>
    k >= text.length || !_isWordPart(text.codeUnitAt(k));

/// Index of the end of the paragraph containing [i]: the next line break that
/// is followed by a blank line, or the end of [text].
int paragraphEnd(String text, int i) {
  var k = text.indexOf('\n', i);
  while (k != -1) {
    var j = k + 1;
    while (j < text.length &&
        (text.codeUnitAt(j) == _space || text.codeUnitAt(j) == _tab)) {
      j += 1;
    }
    if (j >= text.length || text.codeUnitAt(j) == 0x0A) {
      return k;
    }
    k = text.indexOf('\n', j);
  }
  return text.length;
}

// ---------------------------------------------------------------------------
// Blank lines inside a block
// ---------------------------------------------------------------------------

/// Whether a blank line followed by [next] continues the block that [before]
/// ends with, rather than separating two blocks.
///
/// It does when [next] is indented under a list item — a second paragraph
/// or a fenced code block that belongs to the item, the shape of almost every
/// step-by-step answer — or under a footnote definition. The owner is the
/// nearest earlier line indented less than [next]; it continues the item
/// exactly when the parser would nest [next] under it.
///
/// For the code that cuts a document into independently parsed pieces at
/// blank lines: cutting here moved the item's code block out of the list,
/// and parsed alone, every line of it kept the item's indentation.
bool continuesAfterBlank(List<String> before, String next) {
  final indent = indentWidth(next);
  if (indent == 0) {
    return false;
  }
  for (var k = before.length - 1; k >= 0; k--) {
    final line = before[k];
    if (isBlank(line)) {
      continue;
    }
    if (indentWidth(line) >= indent) {
      continue;
    }
    final t = line.trimLeft();
    if (unorderedMarker(t) != null || orderedMarker(t) != null) {
      return true;
    }
    return indent >= 4 && t.startsWith('[^');
  }
  return false;
}

// ---------------------------------------------------------------------------
// Block quote markers
// ---------------------------------------------------------------------------

/// How many `>` quote markers open [line].
int quoteDepth(String line) {
  var depth = 0;
  var i = 0;
  while (i < line.length) {
    final c = line.codeUnitAt(i);
    if (c == _space || c == _tab) {
      i += 1;
    } else if (c == 0x3E /* > */ ) {
      depth += 1;
      i += 1;
    } else {
      break;
    }
  }
  return depth;
}

/// [line] without its leading `>` quote markers and indentation — what a
/// fence check has to look at, so ```` > ```bash ```` is seen as the fence
/// it is.
String unquoted(String line) {
  var i = 0;
  while (i < line.length) {
    final c = line.codeUnitAt(i);
    if (c == _space || c == _tab || c == 0x3E /* > */ ) {
      i += 1;
    } else {
      break;
    }
  }
  return i == 0 ? line : line.substring(i);
}
