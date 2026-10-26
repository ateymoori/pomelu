/// The Markdown document AST produced by the plusparse parser.
///
/// This is a pure-Dart rewrite of the original Rust plusparse AST. The
/// renderer (or any consumer) walks this tree, so it covers every construct
/// gpt_markdown supports. Block-level and inline-level variants share one
/// sealed hierarchy so the tree can nest freely (e.g. bold inside a heading
/// inside a list item).
library;

/// Root of a parsed document.
class MdDocument {
  const MdDocument({required this.children});

  final List<MdNode> children;
}

/// Column alignment for tables (from the `:---:` separator row).
enum MdAlign { none, left, center, right }

/// One cell of a table row; holds inline content.
class MdTableCell {
  const MdTableCell({required this.content});

  final List<MdNode> content;
}

/// One row of a table.
class MdTableRow {
  const MdTableRow({required this.cells});

  final List<MdTableCell> cells;
}

/// One item of an ordered/unordered list. [children] holds the item's inline
/// content followed by any nested block nodes (e.g. a nested list).
class MdListItem {
  const MdListItem({required this.children, this.number});

  final List<MdNode> children;

  /// The literal marker number for ordered-list items (`5.` → 5), preserved
  /// so non-sequential numbering renders as written. Null for bullets.
  final int? number;
}

/// A node in the Markdown tree.
sealed class MdNode {
  const MdNode();
}

// ---------- Block-level ----------

class MdHeading extends MdNode {
  const MdHeading({required this.level, required this.children});

  /// 1–6.
  final int level;
  final List<MdNode> children;
}

class MdParagraph extends MdNode {
  const MdParagraph({required this.children});

  final List<MdNode> children;
}

class MdBlockQuote extends MdNode {
  const MdBlockQuote({required this.children, this.alert});

  /// The quote's content, exactly as written — for an alert, the `[!TYPE]`
  /// marker line included. A walker that does not know about alerts sees an
  /// ordinary quote.
  final List<MdNode> children;

  /// Set when the quote opens with an alert marker such as `[!NOTE]`.
  final MdAlert? alert;
}

/// The kind of an alert, from the marker on the first line of a quote:
///
/// ```markdown
/// > [!WARNING]
/// > Back up your data first.
/// ```
enum MarkdownAlertType {
  /// `[!NOTE]` — information worth noticing even when skimming.
  note,

  /// `[!TIP]` — optional advice for doing something better.
  tip,

  /// `[!IMPORTANT]` — information needed to succeed.
  important,

  /// `[!WARNING]` — something that needs attention straight away.
  warning,

  /// `[!CAUTION]` — the risks or negative outcomes of an action.
  caution;

  static final RegExp _marker = RegExp(
    r'^\s*\[!(note|tip|important|warning|caution)\]\s*$',
    caseSensitive: false,
  );

  /// The type [line] marks, or null when it is not exactly one marker.
  ///
  /// Case-insensitive, and surrounding whitespace is ignored. Anything else on
  /// the line — or an unknown name such as `[!FOO]` — is not a marker, and the
  /// quote stays an ordinary quote.
  static MarkdownAlertType? fromMarker(String line) {
    final match = _marker.firstMatch(line);
    if (match == null) {
      return null;
    }
    return MarkdownAlertType.values.byName(match.group(1)!.toLowerCase());
  }
}

/// The alert a [MdBlockQuote] carries. Not an [MdNode]: it rides on the quote,
/// so the node hierarchy — and every exhaustive `switch` over it — is
/// unchanged.
class MdAlert {
  const MdAlert({required this.type, required this.children});

  final MarkdownAlertType type;

  /// The body, without the marker line.
  final List<MdNode> children;
}

class MdCodeBlock extends MdNode {
  const MdCodeBlock({
    required this.language,
    required this.code,
    required this.closed,
  });

  final String language;
  final String code;

  /// `false` while a fenced block is still open (useful for streaming).
  final bool closed;
}

class MdUnorderedList extends MdNode {
  const MdUnorderedList({required this.items, this.loose = false});

  final List<MdListItem> items;

  /// Whether blank lines separate the items, or the blocks inside one — a
  /// CommonMark "loose" list, whose items an HTML renderer wraps in `<p>`.
  /// The package's own renderer spaces both kinds alike.
  final bool loose;
}

class MdOrderedList extends MdNode {
  const MdOrderedList({
    required this.start,
    required this.items,
    this.loose = false,
  });

  /// The first ordered number (e.g. 3 for a list starting `3.`).
  final int start;
  final List<MdListItem> items;

  /// Whether blank lines separate the items, or the blocks inside one. See
  /// [MdUnorderedList.loose].
  final bool loose;
}

class MdCheckbox extends MdNode {
  const MdCheckbox({required this.checked, required this.children});

  final bool checked;
  final List<MdNode> children;
}

class MdRadio extends MdNode {
  const MdRadio({required this.selected, required this.children});

  final bool selected;
  final List<MdNode> children;
}

class MdTable extends MdNode {
  const MdTable({
    required this.aligns,
    required this.header,
    required this.rows,
  });

  final List<MdAlign> aligns;
  final MdTableRow header;
  final List<MdTableRow> rows;
}

class MdBlockLatex extends MdNode {
  const MdBlockLatex({required this.tex});

  final String tex;
}

class MdHorizontalRule extends MdNode {
  const MdHorizontalRule();
}

// ---------- Inline-level ----------

class MdText extends MdNode {
  const MdText({required this.text});

  final String text;
}

class MdBold extends MdNode {
  const MdBold({required this.children});

  final List<MdNode> children;
}

class MdItalic extends MdNode {
  const MdItalic({required this.children});

  final List<MdNode> children;
}

class MdStrike extends MdNode {
  const MdStrike({required this.children});

  final List<MdNode> children;
}

class MdUnderline extends MdNode {
  const MdUnderline({required this.children});

  final List<MdNode> children;
}

/// Superscript text: `<sup>`.
class MdSuperscript extends MdNode {
  const MdSuperscript({required this.children});

  final List<MdNode> children;
}

/// Subscript text: `<sub>`.
class MdSubscript extends MdNode {
  const MdSubscript({required this.children});

  final List<MdNode> children;
}

/// Highlighted text: `<mark>`.
class MdHighlight extends MdNode {
  const MdHighlight({required this.children});

  final List<MdNode> children;
}

/// Backtick span (`code`), rendered as highlighted inline code.
class MdInlineCode extends MdNode {
  const MdInlineCode({required this.text});

  final String text;
}

class MdInlineLatex extends MdNode {
  const MdInlineLatex({required this.tex});

  final String tex;
}

class MdLink extends MdNode {
  const MdLink({
    required this.children,
    required this.url,
    this.title,
    this.autolink = false,
  });

  final List<MdNode> children;
  final String url;

  /// The optional title of `[text](url "title")`, or of the reference
  /// definition a `[text][label]` link resolved to.
  final String? title;

  /// Whether this is a CommonMark autolink — `<https://example.com>` or
  /// `<me@example.com>` — whose text is the destination as written. With
  /// `GptMarkdown.autolink` off it renders as that text, brackets included.
  final bool autolink;
}

class MdImage extends MdNode {
  const MdImage({
    required this.url,
    required this.alt,
    this.width,
    this.height,
    this.title,
  });

  final String url;
  final String alt;

  /// The optional title of `![alt](url "title")`.
  final String? title;

  /// Width parsed from an alt of the form `WxH` (e.g. `![100x200](url)`).
  final double? width;
  final double? height;
}

/// A citation marker such as `[1]`.
class MdSourceTag extends MdNode {
  const MdSourceTag({required this.id, this.url});

  final String id;

  /// The URL of a `[1]: https://…` reference definition for this tag, when
  /// the document has one. The tag still renders as a citation chip.
  final String? url;
}

/// A footnote reference such as `[^1]` or `[^note]`, resolved against the
/// document's footnote definitions. An unresolved `[^x]` stays text.
class MdFootnoteReference extends MdNode {
  const MdFootnoteReference({required this.label, required this.number});

  /// The label as written, without `^`.
  final String label;

  /// What the reference displays: the position of its definition among the
  /// document's footnote definitions, from 1.
  final int number;
}

/// One footnote definition, `[^label]: text`.
class MdFootnote {
  const MdFootnote({
    required this.label,
    required this.number,
    required this.children,
  });

  final String label;
  final int number;

  /// The footnote's body, parsed as blocks.
  final List<MdNode> children;
}

/// A run of consecutive footnote definitions, rendered where they were
/// written — in a model's reply, that is the end.
class MdFootnoteDefinitions extends MdNode {
  const MdFootnoteDefinitions({required this.footnotes});

  final List<MdFootnote> footnotes;
}

class MdLineBreak extends MdNode {
  const MdLineBreak();
}

/// An extension's parsed payload. [body] remains raw unless the extension
/// explicitly parses it; [data] should be immutable and independent of Flutter.
class MdCustomBlock extends MdNode {
  const MdCustomBlock({
    required this.type,
    required this.body,
    this.data,
    this.closed = true,
  });
  final String type;
  final String body;
  final Object? data;
  final bool closed;
}
