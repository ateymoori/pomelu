/// Link reference definitions (`[label]: url "title"`) and footnote
/// definitions (`[^label]: text`), collected across a whole document.
///
/// A reference can sit pages away from its definition, and the incremental
/// view parses a document one blank-line-separated segment at a time, so a
/// segment cannot find its definitions by itself. They are collected from the
/// whole source first ([MarkdownDefinitions.collect]) and handed to every
/// segment's parse.
library;

import 'block_parser.dart';
import 'block_syntax.dart';
import 'entities.dart';
import 'html_tags.dart';
import 'scanner.dart';

/// Where a link reference definition points.
class MdLinkDefinition {
  const MdLinkDefinition({required this.url, this.title});

  final String url;
  final String? title;

  @override
  bool operator ==(Object other) =>
      other is MdLinkDefinition && other.url == url && other.title == title;

  @override
  int get hashCode => Object.hash(url, title);
}

/// The link and footnote definitions of one document.
///
/// Passed to [Plusparse.parse] when a document is parsed in pieces; a whole
/// document parsed at once collects its own.
class MarkdownDefinitions {
  const MarkdownDefinitions._(
    this._links,
    this._footnotes,
    this._footnoteDefinitions,
    this._lookups,
  );

  /// No definitions at all.
  static const MarkdownDefinitions empty = MarkdownDefinitions._(
    <String, MdLinkDefinition>{},
    <String, int>{},
    <String>{},
    null,
  );

  final Map<String, MdLinkDefinition> _links;

  /// Referenced and defined footnotes, to the number each displays as.
  final Map<String, int> _footnotes;

  /// Every defined footnote, referenced or not.
  final Set<String> _footnoteDefinitions;
  final Set<String>? _lookups;

  /// Whether there are no definitions at all.
  bool get isEmpty => _links.isEmpty && _footnoteDefinitions.isEmpty;

  /// The definition for link [label], matched case-insensitively and with
  /// runs of whitespace collapsed, as CommonMark matches labels.
  MdLinkDefinition? link(String label) {
    final lookups = _lookups;
    if (lookups == null && _links.isEmpty) {
      return null;
    }
    final key = normalizeLabel(label);
    lookups?.add('l:$key');
    return _links[key];
  }

  /// The number footnote [label] displays as, or null when it has none.
  ///
  /// Footnotes are numbered in the order they are first referenced, as GitHub
  /// numbers them, so the text reads ¹ ² ³ whatever order the definitions are
  /// written in. A footnote nothing refers to has no number, and is not shown.
  int? footnote(String label) {
    final lookups = _lookups;
    if (lookups == null && _footnoteDefinitions.isEmpty) {
      return null;
    }
    final key = normalizeLabel(label);
    lookups?.add('f:$key');
    return _footnotes[key];
  }

  /// Whether the document defines footnote [label], referenced or not — a
  /// definition line is hidden either way.
  bool definesFootnote(String label) {
    final lookups = _lookups;
    if (lookups == null && _footnoteDefinitions.isEmpty) {
      return false;
    }
    final key = normalizeLabel(label);
    lookups?.add('f:$key');
    return _footnoteDefinitions.contains(key);
  }

  /// A view of these definitions that adds every label looked up through it to
  /// [lookups], so a cache can tell which parses a changed definition reaches.
  ///
  /// Lookups are recorded even while there are no definitions at all: a
  /// reference parsed before its definition arrives has to be found again
  /// when it does.
  MarkdownDefinitions recording(Set<String> lookups) =>
      MarkdownDefinitions._(_links, _footnotes, _footnoteDefinitions, lookups);

  /// The lookup keys (as [recording] records them) whose answer differs
  /// between this and [other].
  Set<String> changedKeys(MarkdownDefinitions other) {
    final changed = <String>{};
    for (final key in {..._links.keys, ...other._links.keys}) {
      if (_links[key] != other._links[key]) {
        changed.add('l:$key');
      }
    }
    for (final key in {
      ..._footnoteDefinitions,
      ...other._footnoteDefinitions,
    }) {
      if (_footnotes[key] != other._footnotes[key] ||
          _footnoteDefinitions.contains(key) !=
              other._footnoteDefinitions.contains(key)) {
        changed.add('f:$key');
      }
    }
    return changed;
  }

  @override
  bool operator ==(Object other) =>
      other is MarkdownDefinitions &&
      _mapEquals(other._links, _links) &&
      _mapEquals(other._footnotes, _footnotes) &&
      other._footnoteDefinitions.length == _footnoteDefinitions.length &&
      other._footnoteDefinitions.containsAll(_footnoteDefinitions);

  @override
  int get hashCode => Object.hash(
    _links.length,
    _footnotes.length,
    _footnoteDefinitions.length,
  );

  /// Every definition in [source], found where the block parser accepts one
  /// — see [collectLines].
  ///
  /// [html] is the HTML the parse understands, when not the default: an
  /// HTML block element decides which lines are Markdown at all.
  static MarkdownDefinitions collect(
    String source, {
    MarkdownBlockRegistry? blockRegistry,
    MarkdownHtml? html,
  }) {
    // Every definition has `]:` in it. Most replies have none, and this keeps
    // the per-token cost of asking to one scan.
    if (!_hasLabelColon(source)) {
      return empty;
    }
    final lines =
        (source.contains('\r')
                ? source.replaceAll('\r\n', '\n').replaceAll('\r', '\n')
                : source)
            .split('\n');
    return collectLines(lines, blockRegistry: blockRegistry, html: html);
  }

  /// [collect] over a document already split into lines.
  ///
  /// The block parser's own pass finds them, without parsing any inline
  /// content, so a definition counts exactly where the parser consumes one:
  /// at the start of a block, inside quotes and list items too, and never in
  /// fenced code, block maths, HTML comments or custom blocks. The first
  /// definition of a label wins.
  static MarkdownDefinitions collectLines(
    List<String> lines, {
    MarkdownBlockRegistry? blockRegistry,
    MarkdownHtml? html,
  }) {
    // Every definition has `]:` in it, and most documents have none.
    if (!lines.any(_hasLabelColon)) {
      return empty;
    }
    final found = collectDefinitions(lines, blockRegistry, html);
    if (found.links.isEmpty && found.footnoteDefinitions.isEmpty) {
      return empty;
    }
    final footnotes = <String, int>{};
    for (final label in found.referenced) {
      if (found.footnoteDefinitions.contains(label)) {
        footnotes[label] = footnotes.length + 1;
      }
    }
    return MarkdownDefinitions._(
      found.links,
      footnotes,
      found.footnoteDefinitions,
      null,
    );
  }
}

/// Adds the label of every `[^label]` reference in [line] to [referenced],
/// in order — outside code spans, and not escaped, and not `[^x](url)`, which
/// is a link.
void scanFootnoteReferences(String line, Set<String> referenced) {
  if (!line.contains('[^')) {
    return;
  }
  var i = 0;
  while (i < line.length) {
    final c = line.codeUnitAt(i);
    if (c == 0x5C /* \ */ ) {
      i += 2;
      continue;
    }
    if (c == 0x60 /* ` */ ) {
      final span = codeSpanAt(line, i);
      i = span != null ? span.close + span.run : i + backtickRunAt(line, i);
      continue;
    }
    if (c == _openBracket &&
        i + 1 < line.length &&
        line.codeUnitAt(i + 1) == 0x5E /* ^ */ ) {
      final close = line.indexOf(']', i + 2);
      if (close > i + 2) {
        final label = line.substring(i + 2, close);
        final isLink =
            close + 1 < line.length && line.codeUnitAt(close + 1) == 0x28;
        if (!isLink && !label.contains(RegExp(r'[\s\[]'))) {
          referenced.add(normalizeLabel(label));
          i = close + 1;
          continue;
        }
      }
    }
    i += 1;
  }
}

const int _openBracket = 0x5B; // '['

/// Whether [source] contains `]:`.
///
/// Not `contains(']:')`: a two-character pattern search measured three times
/// slower than finding each `]` — rare in prose — and looking at the next
/// character, and this runs on the whole reply for every streamed token.
bool _hasLabelColon(String source) {
  var k = source.indexOf(']');
  while (k != -1) {
    if (k + 1 < source.length && source.codeUnitAt(k + 1) == 0x3A /* : */ ) {
      return true;
    }
    k = source.indexOf(']', k + 1);
  }
  return false;
}

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

/// A label as CommonMark compares it: trimmed, inner whitespace collapsed to
/// one space, and case-folded.
String normalizeLabel(String label) {
  final trimmed = label.trim();
  final collapsed = trimmed.contains(_whitespaceToCollapse)
      ? trimmed.replaceAll(_whitespaceRun, ' ')
      : trimmed;
  final lower = collapsed.toLowerCase();
  // Unicode case folding, which lower case alone misses: `ẞ` lowers to `ß`,
  // and folds — like `SS` — to `ss`. Round-tripping through upper case gets
  // there. ASCII needs none of it.
  for (var i = 0; i < lower.length; i++) {
    if (lower.codeUnitAt(i) > 0x7F) {
      return lower.toUpperCase().toLowerCase().replaceAll('ß', 'ss');
    }
  }
  return lower;
}

final RegExp _whitespaceRun = RegExp(r'\s+');

/// Two whitespace characters in a row, or one that is not a plain space —
/// the labels [normalizeLabel] has to rewrite at all.
final RegExp _whitespaceToCollapse = RegExp(r'\s\s|[^\S ]');

/// Where an HTML comment that opens at line [start] ends: the line after the
/// one holding `-->` (or the end of [lines] when it never closes), and the
/// text after `-->` on that line.
({int next, String trailing}) htmlCommentEnd(List<String> lines, int start) {
  final first = lines[start];
  final open = first.indexOf('<!--');
  var from = open + 4;
  for (var k = start; k < lines.length; k++) {
    final line = lines[k];
    final close = line.indexOf('-->', k == start ? from : 0);
    if (close != -1) {
      return (next: k + 1, trailing: line.substring(close + 3));
    }
    from = 0;
  }
  return (next: lines.length, trailing: '');
}

/// A link reference definition occupying the whole of [line], or null — the
/// one-line form of [linkDefinitionIn].
({String label, MdLinkDefinition definition})? linkDefinitionAt(String line) {
  final definition = linkDefinitionIn([line], 0);
  return definition == null
      ? null
      : (label: definition.label, definition: definition.definition);
}

/// A link reference definition starting at line [start] of [lines], or null.
///
/// `[label]: destination "optional title"` — up to three spaces of indent, a
/// label that is not blank and holds no unescaped bracket, then the
/// destination and title, either of which may sit on the next line. Nothing
/// may follow the title on its line; when something does, and the title
/// started a line of its own, the definition ends before it. A label starting
/// with `^` is a footnote, not a link. [next] is the line after it.
({String label, MdLinkDefinition definition, int next})? linkDefinitionIn(
  List<String> lines,
  int start,
) {
  if (!startsAfterIndent(lines[start], 0x5B /* [ */)) {
    return null;
  }
  // A definition spans no blank line. Ten lines is far more than any real one
  // needs, and bounds the work for a long paragraph that only starts with `[`.
  final run = StringBuffer(lines[start]);
  for (var k = start + 1; k < lines.length && k < start + 10; k++) {
    if (isBlank(lines[k])) {
      break;
    }
    run
      ..write('\n')
      ..write(lines[k]);
  }
  final s = run.toString();
  final n = s.length;

  var p = firstNonSpace(s) + 1; // past `[`
  final labelStart = p;
  while (p < n) {
    final c = s.codeUnitAt(p);
    if (c == 0x5C /* \ */ && p + 1 < n) {
      p += 2;
      continue;
    }
    if (c == 0x5B /* [ */ ) {
      return null;
    }
    if (c == 0x5D /* ] */ ) {
      break;
    }
    p += 1;
  }
  if (p >= n || p + 1 >= n || s.codeUnitAt(p + 1) != 0x3A /* : */ ) {
    return null;
  }
  final label = s.substring(labelStart, p);
  if (label.trim().isEmpty || label.startsWith('^') || label.length > 999) {
    return null;
  }
  p += 2;
  p = _skipSpace(s, p, newline: true);

  // The destination.
  final String url;
  if (p < n && s.codeUnitAt(p) == 0x3C /* < */ ) {
    var q = p + 1;
    while (q < n) {
      final c = s.codeUnitAt(q);
      if (c == 0x5C /* \ */ && q + 1 < n) {
        q += 2;
        continue;
      }
      if (c == 0x0A || c == 0x3C /* < */ || c == 0x3E /* > */ ) {
        break;
      }
      q += 1;
    }
    if (q >= n || s.codeUnitAt(q) != 0x3E /* > */ ) {
      return null;
    }
    url = s.substring(p + 1, q);
    p = q + 1;
  } else {
    var q = p;
    var depth = 0;
    while (q < n) {
      final c = s.codeUnitAt(q);
      if (c == 0x5C /* \ */ && q + 1 < n && s.codeUnitAt(q + 1) != 0x0A) {
        q += 2;
        continue;
      }
      if (c <= 0x20) {
        break;
      }
      if (c == 0x28 /* ( */ ) {
        depth += 1;
        if (depth > 32) {
          return null;
        }
      } else if (c == 0x29 /* ) */ ) {
        if (depth == 0) {
          break;
        }
        depth -= 1;
      }
      q += 1;
    }
    if (q == p || depth != 0) {
      return null;
    }
    url = s.substring(p, q);
    p = q;
  }
  final destinationEnd = p;

  int lineAfter(int offset) {
    var count = 0;
    for (var k = 0; k < offset && k < n; k++) {
      if (s.codeUnitAt(k) == 0x0A) {
        count += 1;
      }
    }
    return start + count + 1;
  }

  // Where a definition without a title would end: the destination must end
  // its line.
  final afterDestination = _skipSpace(s, p, newline: false);
  final untitledEnd =
      afterDestination >= n || s.codeUnitAt(afterDestination) == 0x0A
      ? afterDestination
      : -1;

  ({String label, MdLinkDefinition definition, int next})? untitled() =>
      untitledEnd == -1
      ? null
      : (
          label: label,
          definition: MdLinkDefinition(url: _decode(url)),
          next: lineAfter(untitledEnd),
        );

  // The title, separated from the destination by whitespace.
  p = _skipSpace(s, p, newline: true);
  if (p >= n || p == destinationEnd) {
    return untitled();
  }
  final open = s.codeUnitAt(p);
  final close = switch (open) {
    0x22 /* " */ => 0x22,
    0x27 /* ' */ => 0x27,
    0x28 /* ( */ => 0x29,
    _ => -1,
  };
  if (close == -1) {
    return untitled();
  }
  var q = p + 1;
  while (q < n) {
    final c = s.codeUnitAt(q);
    if (c == 0x5C /* \ */ && q + 1 < n) {
      q += 2;
      continue;
    }
    if (c == close) {
      break;
    }
    if (open == 0x28 && c == 0x28) {
      return untitled();
    }
    q += 1;
  }
  if (q >= n) {
    return untitled();
  }
  final title = s.substring(p + 1, q);
  final end = _skipSpace(s, q + 1, newline: false);
  if (end < n && s.codeUnitAt(end) != 0x0A) {
    return untitled();
  }
  return (
    label: label,
    definition: MdLinkDefinition(url: _decode(url), title: _decode(title)),
    next: lineAfter(end),
  );
}

/// The index after the spaces and tabs at [p] — and, with [newline], after
/// at most one line break and the spaces following it.
int _skipSpace(String s, int p, {required bool newline}) {
  var crossed = false;
  while (p < s.length) {
    final c = s.codeUnitAt(p);
    if (c == 0x20 || c == 0x09) {
      p += 1;
    } else if (c == 0x0A && newline && !crossed) {
      crossed = true;
      p += 1;
    } else {
      break;
    }
  }
  return p;
}

/// A footnote definition starting at line [start], or null.
///
/// `[^label]: text`, then its continuation: following lines up to a blank
/// line, unless they start another definition or a block of their own; and
/// after a blank line, further paragraphs indented by four or more spaces.
/// [lines] is its body with the marker and the continuation indent removed.
({String label, List<String> lines, int next})? footnoteDefinitionAt(
  List<String> lines,
  int start,
) {
  final line = lines[start];
  if (!startsAfterIndent(line, 0x5B /* [ */)) {
    return null;
  }
  final t = line.trimLeft();
  if (!t.startsWith('[^')) {
    return null;
  }
  final close = t.indexOf(']');
  if (close < 3 || close + 1 >= t.length || t[close + 1] != ':') {
    return null;
  }
  final label = t.substring(2, close);
  if (label.contains(RegExp(r'[\s\[]'))) {
    return null;
  }
  var first = t.substring(close + 2);
  if (first.startsWith(' ') || first.startsWith('\t')) {
    first = first.substring(1);
  }
  final body = <String>[first];
  var k = start + 1;
  while (k < lines.length) {
    final next = lines[k];
    if (isBlank(next)) {
      var j = k + 1;
      while (j < lines.length && isBlank(lines[j])) {
        j += 1;
      }
      if (j < lines.length && indentWidth(lines[j]) >= 4) {
        for (var b = k; b < j; b++) {
          body.add('');
        }
        k = j;
        continue;
      }
      break;
    }
    if (indentWidth(next) < 4 &&
        (startsDefinition(next) || _interruptsParagraph(next))) {
      break;
    }
    body.add(stripIndent(next, 4));
    k += 1;
  }
  while (body.isNotEmpty && body.last.trim().isEmpty) {
    body.removeLast();
  }
  return (label: label, lines: body, next: k);
}

/// Whether [line] looks like the start of a link or footnote definition.
bool startsDefinition(String line) {
  if (!startsAfterIndent(line, 0x5B /* [ */)) {
    return false;
  }
  final t = line.trimLeft();
  if (!t.startsWith('[')) {
    return false;
  }
  final close = _labelEnd(t, 1);
  return close != -1 && close + 1 < t.length && t[close + 1] == ':';
}

bool _interruptsParagraph(String line) {
  final t = line.trimLeft();
  final marker = listMarkerAt(line);
  return fenceOpen(t) != null ||
      t.startsWith(r'\[') ||
      isHeading(t) != null ||
      isHr(t) ||
      t.startsWith('>') ||
      (marker != null &&
          !marker.blank &&
          (!marker.ordered || marker.number == 1));
}

/// Index of the `]` closing a label that opened just before [from], or -1.
/// Escaped brackets do not count; an unescaped `[` ends the search.
int _labelEnd(String t, int from) {
  var i = from;
  while (i < t.length) {
    final c = t.codeUnitAt(i);
    if (c == 0x5C /* \ */ ) {
      i += 2;
      continue;
    }
    if (c == 0x5B /* [ */ ) {
      return -1;
    }
    if (c == 0x5D /* ] */ ) {
      return i;
    }
    i += 1;
  }
  return -1;
}

/// The destination and optional title inside a link's parentheses (or after
/// a definition's colon).
///
/// `<url with spaces>` is taken whole; otherwise the URL runs to the first
/// whitespace. A title follows in `"…"`, `'…'` or `(…)`. Backslash escapes and
/// entity references are decoded in both.
///
/// With [strict] (definitions) anything else after the URL means there is no
/// definition. Without it (inline links) the whole text is the URL, exactly as
/// before titles were understood — `[doc](My File.pdf)` keeps working.
({String url, String? title})? parseLinkTarget(
  String raw, {
  bool strict = false,
}) {
  final s = raw.trim();
  String url;
  String rest;
  if (s.startsWith('<')) {
    final end = s.indexOf('>');
    if (end == -1 || s.substring(1, end).contains('<')) {
      if (strict) {
        return null;
      }
      return (url: _decode(s), title: null);
    }
    url = s.substring(1, end);
    rest = s.substring(end + 1);
  } else {
    var end = 0;
    while (end < s.length && !isUnicodeWhitespace(s.codeUnitAt(end))) {
      end += 1;
    }
    url = s.substring(0, end);
    rest = s.substring(end);
  }
  final trimmedRest = rest.trim();
  if (trimmedRest.isEmpty) {
    return (url: _decode(url), title: null);
  }
  // A title must be separated from the URL by whitespace.
  final separated = rest.isNotEmpty && isUnicodeWhitespace(rest.codeUnitAt(0));
  final title = separated ? _title(trimmedRest) : null;
  if (title == null) {
    if (strict) {
      return null;
    }
    return (url: _decode(s), title: null);
  }
  return (url: _decode(url), title: _decode(title));
}

String? _title(String s) {
  if (s.length < 2) {
    return null;
  }
  final open = s.codeUnitAt(0);
  final close = s.codeUnitAt(s.length - 1);
  final matches =
      (open == 0x22 && close == 0x22) || // "
      (open == 0x27 && close == 0x27) || // '
      (open == 0x28 && close == 0x29); // ( )
  if (!matches) {
    return null;
  }
  final inner = s.substring(1, s.length - 1);
  // The closing quote must be the only unescaped one.
  for (var i = 0; i < inner.length; i++) {
    final c = inner.codeUnitAt(i);
    if (c == 0x5C /* \ */ ) {
      i += 1;
      continue;
    }
    if (c == close || (open == 0x28 && c == 0x28)) {
      return null;
    }
  }
  return inner;
}

String _decode(String s) => decodeEntities(unescapeBackslashes(s));

/// [s] with every backslash escape of ASCII punctuation replaced by the
/// character it escapes.
String unescapeBackslashes(String s) {
  if (!s.contains(r'\')) {
    return s;
  }
  final out = StringBuffer();
  var i = 0;
  while (i < s.length) {
    final c = s.codeUnitAt(i);
    if (c == 0x5C &&
        i + 1 < s.length &&
        isAsciiPunctuation(s.codeUnitAt(i + 1))) {
      out.writeCharCode(s.codeUnitAt(i + 1));
      i += 2;
      continue;
    }
    out.writeCharCode(c);
    i += 1;
  }
  return out.toString();
}
