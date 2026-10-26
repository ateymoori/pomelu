/// HTML in Markdown: which tags the parser understands, and what each one
/// becomes.
///
/// Raw HTML is not rendered — this is a Flutter renderer, not a browser.
/// Instead every tag the parser understands has a rule, an [HtmlTagSyntax],
/// in one table, [MarkdownHtml]. A rule maps the tag onto a node the tree
/// already has (`<b>` is bold, `<a href>` a link), drops it so its content
/// renders in place (`<span>`, `<div>`), hides it (`<script>`), or keeps it
/// as an element of its own for the app to render (`HtmlTagKind.inlineElement`,
/// `HtmlTagKind.blockElement`). A tag with no rule — and any tag that is not
/// closed — stays text, so `the <b> tag` reads as written.
///
/// The parser, the streaming hold and the segment splitter all read the same
/// table, so they cannot disagree about a tag.
library;

import 'ast.dart';

/// What the parser makes of a tag.
enum HtmlTagKind {
  /// Its content is bold ([MdBold]): `<b>`, `<strong>`.
  bold,

  /// Italic ([MdItalic]): `<i>`, `<em>`.
  italic,

  /// Struck through ([MdStrike]): `<s>`, `<del>`.
  strike,

  /// Underlined ([MdUnderline]): `<u>`, `<ins>`.
  underline,

  /// Inline code ([MdInlineCode]) holding the raw content: `<code>`, `<kbd>`.
  code,

  /// Superscript ([MdSuperscript]): `<sup>`.
  superscript,

  /// Subscript ([MdSubscript]): `<sub>`.
  subscript,

  /// Highlighted ([MdHighlight]): `<mark>`.
  highlight,

  /// A line break ([MdLineBreak]): `<br>`. On a line of its own, nothing.
  lineBreak,

  /// An image ([MdImage]) from `src`, `alt`, `title`, `width` and `height`:
  /// `<img>`.
  image,

  /// A link ([MdLink]) from `href` and `title`: `<a>`. Without `href`, its
  /// content.
  link,

  /// A horizontal rule ([MdHorizontalRule]) when on a line of its own:
  /// `<hr>`.
  rule,

  /// A heading ([MdHeading]) whose level is the digit in the tag's name
  /// (`<h2>` is level 2), when it starts a block.
  heading,

  /// A block quote ([MdBlockQuote]) of the Markdown inside, when it starts a
  /// block: `<blockquote>`.
  quote,

  /// A fenced code block ([MdCodeBlock]) of the raw content, when it starts
  /// a block: `<pre>`. An inner `<code class="language-x">` gives the
  /// language.
  codeBlock,

  /// A table, when it starts a block: `<table>`. Kept as an element
  /// ([MdCustomBlock] of type [htmlElementType]) whose content is its
  /// structure — `<caption>`, `<thead>`, `<tbody>`, `<tfoot>`, `<tr>`, `<th>`
  /// and `<td>`, each with its attributes — and drawn as a grid that honours
  /// `colspan` and `rowspan`. Rows in `<thead>`, and rows of `<th>` cells,
  /// are header rows; a table without either has none. `align` and
  /// `style="text-align: …"` on a cell or its row align the cell.
  table,

  /// A bulleted list ([MdUnorderedList]) of its `<li>` items, when it starts
  /// a block: `<ul>`.
  unorderedList,

  /// A numbered list ([MdOrderedList]) of its `<li>` items, from `start`,
  /// when it starts a block: `<ol>`.
  orderedList,

  /// A checkbox ([MdCheckbox]) — `<input type="checkbox">`, `checked` or not —
  /// labelled by the rest of its line when it starts one. Any other input
  /// stays text.
  checkbox,

  /// Dropped together with everything inside it, when closed: `<script>`,
  /// `<style>`.
  hidden,

  /// The tag is dropped and its content renders in its place: `<span>`.
  inlineContent,

  /// On lines of its own, the tag is dropped and the Markdown around it
  /// renders as if it were not there: `<div align="center">`, `<details>`.
  blockContent,

  /// An SVG drawing: `<svg>`. Kept as an element ([MdCustomBlock] of type
  /// [htmlElementType]) with its markup raw in [HtmlElementData.source], and
  /// drawn as a picture — as a block when it starts one, inside the line
  /// otherwise.
  svg,

  /// Kept as an element ([MdCustomBlock] of type [htmlElementType] carrying
  /// [HtmlElementData]) inside a paragraph, for the app to render.
  inlineElement,

  /// Kept as an element ([MdCustomBlock] of type [htmlElementType] carrying
  /// [HtmlElementData]) holding the Markdown blocks inside it, when it starts
  /// a block; inside a paragraph, an inline element.
  blockElement,
}

/// The rule for one tag.
class HtmlTagSyntax {
  const HtmlTagSyntax(this.kind, {this.rawContent = false});

  final HtmlTagKind kind;

  /// For an element: its content is kept as raw text
  /// ([HtmlElementData.source]) and not parsed as Markdown.
  final bool rawContent;

  static const bold = HtmlTagSyntax(HtmlTagKind.bold);
  static const italic = HtmlTagSyntax(HtmlTagKind.italic);
  static const strike = HtmlTagSyntax(HtmlTagKind.strike);
  static const underline = HtmlTagSyntax(HtmlTagKind.underline);
  static const code = HtmlTagSyntax(HtmlTagKind.code);
  static const superscript = HtmlTagSyntax(HtmlTagKind.superscript);
  static const subscript = HtmlTagSyntax(HtmlTagKind.subscript);
  static const highlight = HtmlTagSyntax(HtmlTagKind.highlight);
  static const table = HtmlTagSyntax(HtmlTagKind.table);
  static const unorderedList = HtmlTagSyntax(HtmlTagKind.unorderedList);
  static const orderedList = HtmlTagSyntax(HtmlTagKind.orderedList);
  static const checkbox = HtmlTagSyntax(HtmlTagKind.checkbox);
  static const lineBreak = HtmlTagSyntax(HtmlTagKind.lineBreak);
  static const image = HtmlTagSyntax(HtmlTagKind.image);
  static const link = HtmlTagSyntax(HtmlTagKind.link);
  static const rule = HtmlTagSyntax(HtmlTagKind.rule);
  static const heading = HtmlTagSyntax(HtmlTagKind.heading);
  static const quote = HtmlTagSyntax(HtmlTagKind.quote);
  static const codeBlock = HtmlTagSyntax(HtmlTagKind.codeBlock);
  static const hidden = HtmlTagSyntax(HtmlTagKind.hidden);
  static const inlineContent = HtmlTagSyntax(HtmlTagKind.inlineContent);
  static const blockContent = HtmlTagSyntax(HtmlTagKind.blockContent);
  static const svg = HtmlTagSyntax(HtmlTagKind.svg, rawContent: true);
  static const inlineElement = HtmlTagSyntax(HtmlTagKind.inlineElement);
  static const blockElement = HtmlTagSyntax(HtmlTagKind.blockElement);

  /// Whether the tag can span lines as a block — what the segment splitter
  /// has to keep whole.
  bool get spansLines => switch (kind) {
    HtmlTagKind.quote ||
    HtmlTagKind.codeBlock ||
    HtmlTagKind.heading ||
    HtmlTagKind.hidden ||
    HtmlTagKind.table ||
    HtmlTagKind.unorderedList ||
    HtmlTagKind.orderedList ||
    HtmlTagKind.svg ||
    HtmlTagKind.blockElement => true,
    _ => false,
  };

  @override
  bool operator ==(Object other) =>
      other is HtmlTagSyntax &&
      other.kind == kind &&
      other.rawContent == rawContent;

  @override
  int get hashCode => Object.hash(kind, rawContent);
}

/// The table of tags the parser understands, by lower-case name.
class MarkdownHtml {
  /// A table of exactly [tags]. Names are matched case-insensitively.
  MarkdownHtml(Map<String, HtmlTagSyntax> tags)
    : _tags = {
        for (final entry in tags.entries) entry.key.toLowerCase(): entry.value,
      };

  const MarkdownHtml._(this._tags);

  final Map<String, HtmlTagSyntax> _tags;

  /// No HTML: every tag is text.
  static const MarkdownHtml none = MarkdownHtml._(<String, HtmlTagSyntax>{});

  /// The tags understood out of the box.
  static final MarkdownHtml defaults = MarkdownHtml(const {
    'b': HtmlTagSyntax.bold,
    'strong': HtmlTagSyntax.bold,
    'i': HtmlTagSyntax.italic,
    'em': HtmlTagSyntax.italic,
    'cite': HtmlTagSyntax.italic,
    'var': HtmlTagSyntax.italic,
    's': HtmlTagSyntax.strike,
    'del': HtmlTagSyntax.strike,
    'strike': HtmlTagSyntax.strike,
    'u': HtmlTagSyntax.underline,
    'ins': HtmlTagSyntax.underline,
    'code': HtmlTagSyntax.code,
    'kbd': HtmlTagSyntax.code,
    'samp': HtmlTagSyntax.code,
    'tt': HtmlTagSyntax.code,
    'sup': HtmlTagSyntax.superscript,
    'sub': HtmlTagSyntax.subscript,
    'mark': HtmlTagSyntax.highlight,
    'table': HtmlTagSyntax.table,
    'ul': HtmlTagSyntax.unorderedList,
    'ol': HtmlTagSyntax.orderedList,
    'input': HtmlTagSyntax.checkbox,
    'br': HtmlTagSyntax.lineBreak,
    'img': HtmlTagSyntax.image,
    'a': HtmlTagSyntax.link,
    'hr': HtmlTagSyntax.rule,
    'h1': HtmlTagSyntax.heading,
    'h2': HtmlTagSyntax.heading,
    'h3': HtmlTagSyntax.heading,
    'h4': HtmlTagSyntax.heading,
    'h5': HtmlTagSyntax.heading,
    'h6': HtmlTagSyntax.heading,
    'blockquote': HtmlTagSyntax.quote,
    'pre': HtmlTagSyntax.codeBlock,
    'svg': HtmlTagSyntax.svg,
    'script': HtmlTagSyntax.hidden,
    'style': HtmlTagSyntax.hidden,
    'iframe': HtmlTagSyntax.hidden,
    'object': HtmlTagSyntax.hidden,
    'embed': HtmlTagSyntax.hidden,
    'noscript': HtmlTagSyntax.hidden,
    'template': HtmlTagSyntax.hidden,
    'head': HtmlTagSyntax.hidden,
    'title': HtmlTagSyntax.hidden,
    'meta': HtmlTagSyntax.hidden,
    'link': HtmlTagSyntax.hidden,
    'span': HtmlTagSyntax.inlineContent,
    'small': HtmlTagSyntax.inlineContent,
    'big': HtmlTagSyntax.inlineContent,
    'font': HtmlTagSyntax.inlineContent,
    'abbr': HtmlTagSyntax.inlineContent,
    'q': HtmlTagSyntax.inlineContent,
    'div': HtmlTagSyntax.blockContent,
    'p': HtmlTagSyntax.blockContent,
    'center': HtmlTagSyntax.blockContent,
    'section': HtmlTagSyntax.blockContent,
    'article': HtmlTagSyntax.blockContent,
    'header': HtmlTagSyntax.blockContent,
    'footer': HtmlTagSyntax.blockContent,
    'main': HtmlTagSyntax.blockContent,
    'aside': HtmlTagSyntax.blockContent,
    'nav': HtmlTagSyntax.blockContent,
    'figure': HtmlTagSyntax.blockContent,
    'figcaption': HtmlTagSyntax.blockContent,
    'details': HtmlTagSyntax.blockContent,
    'summary': HtmlTagSyntax.blockContent,
    'body': HtmlTagSyntax.blockContent,
    'html': HtmlTagSyntax.blockContent,
  });

  /// The rule for tag [name] (lower case), or null when it stays text.
  HtmlTagSyntax? operator [](String name) => _tags[name];

  /// Every tag name with a rule.
  Iterable<String> get names => _tags.keys;

  bool get isEmpty => _tags.isEmpty;

  /// This table with [overrides] applied: a rule replaces or adds one, and
  /// null removes one, so that tag stays text.
  MarkdownHtml extend(Map<String, HtmlTagSyntax?> overrides) {
    if (overrides.isEmpty) {
      return this;
    }
    final tags = Map<String, HtmlTagSyntax>.of(_tags);
    for (final entry in overrides.entries) {
      final name = entry.key.toLowerCase();
      final syntax = entry.value;
      if (syntax == null) {
        tags.remove(name);
      } else {
        tags[name] = syntax;
      }
    }
    return MarkdownHtml._(tags);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! MarkdownHtml || other._tags.length != _tags.length) {
      return false;
    }
    for (final entry in _tags.entries) {
      if (other._tags[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAllUnordered(
    _tags.entries.map((e) => Object.hash(e.key, e.value)),
  );
}

/// The [MdCustomBlock.type] of an HTML element kept in the tree
/// ([HtmlTagKind.inlineElement], [HtmlTagKind.blockElement]). Its
/// [MdCustomBlock.data] is an [HtmlElementData].
const String htmlElementType = 'gpt_markdown.html';

/// One HTML element kept in the tree: its tag, attributes and content.
class HtmlElementData {
  const HtmlElementData({
    required this.name,
    required this.attributes,
    required this.children,
    required this.source,
    required this.block,
  });

  /// The tag's name, lower case.
  final String name;

  /// Attribute names (lower case) to values, references decoded. A bare
  /// attribute maps to the empty string.
  final Map<String, String> attributes;

  /// The content, parsed: inline nodes for an inline element, blocks for a
  /// block one. Empty when the rule keeps the content raw, and for an empty
  /// or void element.
  final List<MdNode> children;

  /// The content as written, between the opening and closing tags.
  final String source;

  /// Whether it stood as a block of its own.
  final bool block;
}

/// Elements that never have content or a closing tag.
const Set<String> voidHtmlTags = {
  'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', //
  'meta', 'param', 'source', 'track', 'wbr',
};

/// One HTML tag at a position in some text.
class ParsedHtmlTag {
  const ParsedHtmlTag({
    required this.name,
    required this.attributes,
    required this.closing,
    required this.selfClosing,
    required this.end,
  });

  /// Lower case.
  final String name;

  /// Lower-case names to values, references not yet decoded. A bare
  /// attribute maps to the empty string.
  final Map<String, String> attributes;

  /// `</name>`.
  final bool closing;

  /// `<name />`.
  final bool selfClosing;

  /// The index just past `>`.
  final int end;

  /// Whether nothing follows it: no content, no closing tag.
  bool get isVoid => selfClosing || voidHtmlTags.contains(name);
}

/// Follows the HTML blocks a run of lines opens and closes, for code that
/// cuts a document into pieces at blank lines and must not cut inside one.
class HtmlBlockTracker {
  HtmlBlockTracker(this.html);

  final MarkdownHtml html;
  String? _name;
  int _depth = 0;

  /// Whether a block opened by an earlier line is still open.
  bool get isOpen => _name != null;

  /// Takes the next line into account.
  void add(String line) {
    final name = _name;
    if (name != null) {
      _count(line, name, 0);
      return;
    }
    final start = _firstNonSpace(line);
    if (start == -1 || line.codeUnitAt(start) != 0x3C /* < */ ) {
      return;
    }
    final tag = htmlTagAt(line, start);
    if (tag == null || tag.closing || tag.isVoid) {
      return;
    }
    final syntax = html[tag.name];
    if (syntax == null || !syntax.spansLines) {
      return;
    }
    _name = tag.name;
    _depth = 1;
    _count(line, tag.name, tag.end);
  }

  void _count(String line, String name, int from) {
    var p = line.indexOf('<', from);
    while (p != -1) {
      final tag = htmlTagAt(line, p);
      if (tag != null && tag.name == name && !tag.selfClosing) {
        _depth += tag.closing ? -1 : 1;
        if (_depth == 0) {
          _name = null;
          return;
        }
      }
      p = line.indexOf('<', p + 1);
    }
  }
}

int _firstNonSpace(String line) {
  for (var i = 0; i < line.length; i++) {
    final c = line.codeUnitAt(i);
    if (c != 0x20 && c != 0x09) {
      return i;
    }
  }
  return -1;
}

/// The tag starting at the `<` at [i], or null.
///
/// CommonMark's grammar for an open or closing tag: a name of letters,
/// digits and `-`, attributes with optional unquoted, single- or
/// double-quoted values, an optional `/`, then `>`. [limit] bounds how far a
/// tag may run.
ParsedHtmlTag? htmlTagAt(String text, int i, {int limit = 2000}) {
  final n = text.length;
  final stop = i + limit < n ? i + limit : n;
  if (i + 2 > stop || text.codeUnitAt(i) != 0x3C /* < */ ) {
    return null;
  }
  var p = i + 1;
  var closing = false;
  if (text.codeUnitAt(p) == 0x2F /* / */ ) {
    closing = true;
    p += 1;
  }
  final nameStart = p;
  if (p >= stop || !_isLetter(text.codeUnitAt(p))) {
    return null;
  }
  while (p < stop && _isNameChar(text.codeUnitAt(p))) {
    p += 1;
  }
  final name = text.substring(nameStart, p).toLowerCase();
  final attributes = <String, String>{};
  if (closing) {
    p = _skipSpace(text, p, stop);
    if (p < stop && text.codeUnitAt(p) == 0x3E /* > */ ) {
      return ParsedHtmlTag(
        name: name,
        attributes: attributes,
        closing: true,
        selfClosing: false,
        end: p + 1,
      );
    }
    return null;
  }
  while (true) {
    final afterSpace = _skipSpace(text, p, stop);
    if (afterSpace >= stop) {
      return null;
    }
    final c = text.codeUnitAt(afterSpace);
    if (c == 0x3E /* > */ ) {
      return ParsedHtmlTag(
        name: name,
        attributes: attributes,
        closing: false,
        selfClosing: false,
        end: afterSpace + 1,
      );
    }
    if (c == 0x2F /* / */ ) {
      if (afterSpace + 1 < stop && text.codeUnitAt(afterSpace + 1) == 0x3E) {
        return ParsedHtmlTag(
          name: name,
          attributes: attributes,
          closing: false,
          selfClosing: true,
          end: afterSpace + 2,
        );
      }
      return null;
    }
    // An attribute needs whitespace before it.
    if (afterSpace == p || !_isAttributeStart(c)) {
      return null;
    }
    p = afterSpace;
    final attrStart = p;
    while (p < stop && _isAttributeChar(text.codeUnitAt(p))) {
      p += 1;
    }
    final attrName = text.substring(attrStart, p).toLowerCase();
    var value = '';
    final beforeEquals = _skipSpace(text, p, stop);
    if (beforeEquals < stop && text.codeUnitAt(beforeEquals) == 0x3D /* = */ ) {
      p = _skipSpace(text, beforeEquals + 1, stop);
      if (p >= stop) {
        return null;
      }
      final q = text.codeUnitAt(p);
      if (q == 0x22 /* " */ || q == 0x27 /* ' */ ) {
        var close = p + 1;
        while (close < stop && text.codeUnitAt(close) != q) {
          close += 1;
        }
        if (close >= stop) {
          return null;
        }
        value = text.substring(p + 1, close);
        p = close + 1;
      } else {
        final valueStart = p;
        while (p < stop && _isUnquotedValueChar(text.codeUnitAt(p))) {
          p += 1;
        }
        if (p == valueStart) {
          return null;
        }
        value = text.substring(valueStart, p);
      }
    }
    attributes.putIfAbsent(attrName, () => value);
  }
}

int _skipSpace(String text, int p, int stop) {
  while (p < stop) {
    final c = text.codeUnitAt(p);
    if (c != 0x20 && c != 0x09 && c != 0x0A) {
      break;
    }
    p += 1;
  }
  return p;
}

bool _isLetter(int c) => (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);

bool _isNameChar(int c) =>
    _isLetter(c) || (c >= 0x30 && c <= 0x39) || c == 0x2D /* - */;

bool _isAttributeStart(int c) =>
    _isLetter(c) || c == 0x5F /* _ */ || c == 0x3A /* : */;

bool _isAttributeChar(int c) =>
    _isAttributeStart(c) ||
    (c >= 0x30 && c <= 0x39) ||
    c == 0x2E /* . */ ||
    c == 0x2D /* - */;

bool _isUnquotedValueChar(int c) =>
    c > 0x20 &&
    c != 0x22 &&
    c != 0x27 &&
    c != 0x3D &&
    c != 0x3C &&
    c != 0x3E &&
    c != 0x60;

/// The closing tag that matches the open tag [name] ending at [from]:
/// where it starts and where it ends. Nested tags of the same name are
/// counted, up to a depth of 32, so a closing tag belongs to the nearest
/// opening tag before it; past that depth, or with no closer, null.
///
/// Without [nested] — a tag whose content is raw, `<code>` or `<script>` —
/// the first closing tag ends it, as in HTML: a `<code>` written inside
/// `<code>` is text.
({int start, int end})? matchingCloseTag(
  String text,
  String name,
  int from, {
  bool nested = true,
}) {
  var depth = 0;
  var p = text.indexOf('<', from);
  while (p != -1) {
    final tag = htmlTagAt(text, p);
    if (tag != null &&
        tag.name == name &&
        !tag.selfClosing &&
        (nested || tag.closing)) {
      if (tag.closing) {
        if (depth == 0) {
          return (start: p, end: tag.end);
        }
        depth -= 1;
      } else {
        depth += 1;
        if (depth > 32) {
          return null;
        }
      }
    }
    p = text.indexOf('<', p + 1);
  }
  return null;
}

/// Whether the content of a tag with [syntax] is raw text rather than
/// Markdown — and so whether its first closing tag ends it, nested tags of
/// the same name not counted.
bool htmlContentIsRaw(HtmlTagSyntax syntax) =>
    syntax.rawContent ||
    switch (syntax.kind) {
      HtmlTagKind.code ||
      HtmlTagKind.codeBlock ||
      HtmlTagKind.hidden ||
      HtmlTagKind.svg => true,
      _ => false,
    };

/// The alignment an HTML element's `align` attribute, or the `text-align` in
/// its `style`, asks for.
MdAlign htmlAlign(Map<String, String> attributes) {
  var value = (attributes['align'] ?? '').toLowerCase();
  if (value.isEmpty) {
    final style = (attributes['style'] ?? '').toLowerCase();
    final at = style.indexOf('text-align');
    if (at != -1) {
      value = style.substring(at);
    }
  }
  if (value.contains('center')) {
    return MdAlign.center;
  }
  if (value.contains('right')) {
    return MdAlign.right;
  }
  if (value.contains('left')) {
    return MdAlign.left;
  }
  return MdAlign.none;
}
