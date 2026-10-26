/// Block parser: walks the document line-by-line and produces block-level
/// [MdNode]s, recursing into the inline parser for text content and into
/// itself for the content of containers (list items, block quotes).
/// Error-tolerant: it never throws on malformed or partial (streaming) input.
///
/// Containers follow CommonMark: a list item owns the lines indented to its
/// content column, a block quote the lines carrying its `>`, and either one
/// also takes a "lazy" line — an unmarked line that only continues the
/// paragraph left open inside it. The same pass, run without the inline
/// parser, collects the document's link and footnote definitions
/// ([collectDefinitions]), so a definition counts exactly where the parser
/// accepts one.
library;

import 'ast.dart';
import 'block_syntax.dart';
import 'definitions.dart';
import 'entities.dart';
import 'html_tags.dart';
import 'inline_parser.dart';
import 'scanner.dart';

/// Parses [src]. Link and footnote definitions are collected from [src]
/// itself unless [definitions] is given — the incremental view passes the
/// whole document's, because it parses one segment at a time.
MdDocument parseDocument(
  String src,
  bool useDollar, [
  MarkdownBlockRegistry? registry,
  MarkdownDefinitions? definitions,
  MarkdownHtml? html,
]) {
  final lines = documentLines(src);
  final defs =
      definitions ??
      MarkdownDefinitions.collectLines(
        lines,
        blockRegistry: registry,
        html: html,
      );
  return MdDocument(
    children: parseBlocks(lines, useDollar, registry, defs, html),
  );
}

/// [src] split into lines: line endings normalised, and the empty line after
/// a final line ending dropped — it is the end of the last line, not a line.
List<String> documentLines(String src) {
  // Two full rewrites of the source, for a character most sources do not
  // contain. Checking first is one scan that usually ends in none.
  var normalized = src.contains('\r')
      ? src.replaceAll('\r\n', '\n').replaceAll('\r', '\n')
      : src;
  // CommonMark: U+0000 is replaced, for safety.
  if (normalized.contains('\u0000')) {
    normalized = normalized.replaceAll('\u0000', '�');
  }
  final lines = normalized.split('\n');
  if (lines.length > 1 && lines.last.isEmpty) {
    lines.removeLast();
  }
  return lines;
}

List<MdNode> parseBlocks(
  List<String> lines,
  bool useDollar, [
  MarkdownBlockRegistry? registry,
  MarkdownDefinitions defs = MarkdownDefinitions.empty,
  MarkdownHtml? html,
]) => _BlockParser(
  useDollar,
  registry,
  defs,
  null,
  html ?? MarkdownHtml.defaults,
).blocks(lines);

/// The definitions in [lines], found by the block pass itself: what it
/// accepts as a definition, and every `[^label]` reference in the text it
/// would hand to the inline parser, in reading order.
DefinitionSink collectDefinitions(
  List<String> lines,
  MarkdownBlockRegistry? registry, [
  MarkdownHtml? html,
]) {
  final sink = DefinitionSink();
  _BlockParser(
    false,
    registry,
    MarkdownDefinitions.empty,
    sink,
    html ?? MarkdownHtml.defaults,
  ).blocks(lines);
  return sink;
}

/// What [collectDefinitions] found.
class DefinitionSink {
  final links = <String, MdLinkDefinition>{};
  final footnoteDefinitions = <String>{};

  /// Footnote labels in the order they are first referenced.
  final referenced = <String>{};
}

/// One block pass. With a [sink] it only collects definitions: no inline
/// content is parsed, and the nodes it returns are placeholders.
class _BlockParser {
  _BlockParser(this.useDollar, this.registry, this.defs, this.sink, this.html);

  final bool useDollar;
  final MarkdownHtml html;
  final MarkdownBlockRegistry? registry;
  final MarkdownDefinitions defs;
  final DefinitionSink? sink;

  /// Whether the last [blocks] call put a blank line between two of the
  /// blocks it returned — what makes a list item loose.
  bool _blankBetween = false;

  List<MdNode> inline(String text) {
    final collecting = sink;
    if (collecting != null) {
      scanFootnoteReferences(text, collecting.referenced);
      return const [];
    }
    return parseInline(text, useDollar, defs, html);
  }

  List<MdNode> blocks(List<String> source) {
    // Copied before the first line is rewritten — see the HTML wrappers below
    // — because [source] may be a caller's list.
    var lines = source;
    final out = <MdNode>[];
    final n = lines.length;
    var i = 0;
    var blankPending = false;
    var blankBetween = false;
    // Where the last comment scanned for closed. A later `<!--` line before
    // that point closes there too, so it is not scanned again — each paragraph
    // starting `<!--` with the `-->` far below would otherwise rescan to it.
    ({int next, String trailing})? commentEnd;
    var commentFrom = -1;
    // The first line from which no `\]` follows, once a search has failed:
    // a later search from there fails too.
    var noMathCloserFrom = n;

    // Blocks met so far, counting the ones that render nothing — a
    // definition between two blank lines still makes a list item loose.
    var seen = 0;
    void see() {
      if (blankPending && seen > 0) {
        blankBetween = true;
      }
      blankPending = false;
      seen += 1;
    }

    void add(MdNode node) {
      see();
      out.add(node);
    }

    while (i < n) {
      final raw = lines[i];
      if (isBlank(raw)) {
        blankPending = true;
        i += 1;
        continue;
      }
      final indent = indentWidth(raw);
      final trimmed = raw.trimLeft();

      final custom = registry?.match(lines, i);
      if (custom != null) {
        add(custom.node);
        i = custom.endLine;
        continue;
      }

      // Fenced code block ```lang ... ``` or ~~~lang ... ~~~. It closes on a
      // run of the same character at least as long as the opener, so a ````
      // fence can show a ``` fence inside it. The opener's indentation is
      // removed from each line of the body.
      final fence = fenceOpen(trimmed);
      if (fence != null) {
        i += 1;
        final code = <String>[];
        var closed = false;
        final closerIndent = indent > 3 ? indent : 3;
        while (i < n) {
          final line = lines[i];
          if (indentWidth(line) <= closerIndent && isFenceClose(line, fence)) {
            closed = true;
            i += 1;
            break;
          }
          code.add(indent == 0 ? line : stripIndent(line, indent));
          i += 1;
        }
        add(
          MdCodeBlock(
            language: decodeEntities(unescapeBackslashes(fence.info)),
            code: code.join('\n'),
            closed: closed,
          ),
        );
        continue;
      }

      // <!-- comment --> on lines of its own — hidden, blank lines and all.
      // Unclosed, it runs to the end, as an HTML block does: a comment still
      // streaming in stays hidden.
      if (startsHtmlComment(trimmed)) {
        final cached = commentEnd;
        final ({int next, String trailing}) end;
        if (cached != null &&
            i > commentFrom &&
            i < cached.next - 1 &&
            !lines[i].contains('-->', lines[i].indexOf('<!--') + 4)) {
          end = cached;
        } else {
          end = htmlCommentEnd(lines, i);
          commentEnd = end;
          commentFrom = i;
        }
        if (end.trailing.trim().isEmpty) {
          i = end.next;
          continue;
        }
      }

      // HTML that starts a block — see [_htmlBlock].
      if (trimmed.startsWith('<') && !startsHtmlComment(trimmed)) {
        final block = _htmlBlock(lines, i, trimmed);
        if (block != null) {
          if (block.node case final node?) {
            add(node);
          }
          final rest = block.rest;
          if (rest != null) {
            // Text after the tag on its last line is a block of its own.
            if (identical(lines, source)) {
              lines = [...source];
            }
            lines[block.next - 1] = rest;
            i = block.next - 1;
          } else {
            i = block.next;
          }
          continue;
        }
      }

      // [label]: url "title" — consumed; the references resolve to it. One
      // can span lines, and several can follow each other.
      if (indent <= 3 && trimmed.startsWith('[')) {
        final definition = linkDefinitionIn(lines, i);
        if (definition != null) {
          sink?.links.putIfAbsent(
            normalizeLabel(definition.label),
            () => definition.definition,
          );
          see();
          i = definition.next;
          continue;
        }
      }

      // [^label]: text — consecutive definitions render as one list.
      if (indent <= 3 && trimmed.startsWith('[^')) {
        final footnotes = _footnotes(lines, i);
        if (footnotes != null) {
          // Definitions nothing refers to are consumed and not shown.
          if (footnotes.footnotes.isNotEmpty) {
            add(MdFootnoteDefinitions(footnotes: footnotes.footnotes));
          }
          i = footnotes.next;
          continue;
        }
      }

      // Block LaTeX \[ ... \], when it closes. An unclosed `\[` is text: it
      // used to run to the end of the document, swallowing everything after
      // a stray `\[`. A formula still streaming in is closed for the parser
      // by the streaming view, so it renders as it arrives regardless.
      if (trimmed.startsWith(r'\[') && i < noMathCloserFrom) {
        final latex = _blockLatex(lines, i, trimmed);
        if (latex == null) {
          noMathCloserFrom = i;
        } else if (latex.tex != null) {
          add(MdBlockLatex(tex: latex.tex!));
          i = latex.next;
          continue;
        }
      }

      // Heading
      final heading = isHeading(trimmed);
      if (heading != null) {
        add(MdHeading(level: heading.level, children: inline(heading.content)));
        i += 1;
        continue;
      }

      // Horizontal rule
      if (isHr(trimmed)) {
        add(const MdHorizontalRule());
        i += 1;
        continue;
      }

      // Blockquote
      if (trimmed.startsWith('>')) {
        final quote = _blockQuote(lines, i);
        add(quote.node);
        i = quote.next;
        continue;
      }

      // Table
      final table = _tryTable(lines, i);
      if (table != null) {
        add(table.node);
        i = table.next;
        continue;
      }

      // Checkbox / radio
      final checkbox = checkboxMarker(trimmed);
      if (checkbox != null) {
        add(
          MdCheckbox(
            checked: checkbox.checked,
            children: inline(checkbox.content),
          ),
        );
        i += 1;
        continue;
      }
      final radio = radioMarker(trimmed);
      if (radio != null) {
        add(MdRadio(selected: radio.selected, children: inline(radio.content)));
        i += 1;
        continue;
      }

      // Lists
      final marker = listMarkerAt(raw);
      if (marker != null) {
        final list = _list(lines, i, marker);
        add(list.node);
        i = list.next;
        continue;
      }

      // Paragraph: gather the lines that continue it. A `===` or `---` line
      // under it makes it a setext heading instead.
      final para = <String>[trimmed];
      int? setextLevel;
      i += 1;
      while (i < n) {
        final line = lines[i];
        if (isBlank(line)) {
          break;
        }
        // A line indented four or more is always a continuation: it can
        // neither start a block nor underline a heading.
        if (indentWidth(line) < 4) {
          setextLevel = setextUnderlineLevel(line);
          if (setextLevel != null) {
            i += 1;
            break;
          }
          if (_startsBlock(lines, i, interrupting: true)) {
            break;
          }
        }
        para.add(line.trimLeft());
        i += 1;
      }
      // Joined on the newline, not on a space. CommonMark folds a single
      // newline inside a paragraph into a space, and this package has never
      // done that: a model writes a list of bullet glyphs, or a run of short
      // lines, and folding them produced one long wrapped line.
      final text = para.join('\n');
      final content = inline(setextLevel != null ? text.trimRight() : text);
      add(
        setextLevel != null
            ? MdHeading(level: setextLevel, children: content)
            : MdParagraph(children: content),
      );
    }

    _blankBetween = blankBetween;
    return out;
  }

  /// Whether the line at [i] — not blank, indented less than four — starts a
  /// block.
  ///
  /// [interrupting] asks on behalf of a paragraph the line would otherwise
  /// continue. Then a list item only counts when it is not empty, and an
  /// ordered one only when it starts at 1, so prose that wraps onto a line
  /// starting "14. " stays prose. Without it, the question is whether a line
  /// outside a container can be taken into it lazily: any block start ends
  /// the container instead.
  bool _startsBlock(List<String> lines, int i, {required bool interrupting}) {
    final line = lines[i];
    final first = firstNonSpace(line);
    if (first == -1 || indentWidth(line) >= 4) {
      return false;
    }
    if (!_mayStartBlock(line.codeUnitAt(first))) {
      return registry?.match(lines, i) != null;
    }
    final t = line.substring(first);
    switch (t.codeUnitAt(0)) {
      case 0x60 /* ` */ || 0x7E /* ~ */ :
        if (fenceOpen(t) != null) {
          return true;
        }
      case 0x23 /* # */ :
        if (isHeading(t) != null) {
          return true;
        }
      case 0x3E /* > */ :
        return true;
      case 0x5C /* \ */ :
        if (t.startsWith(r'\[') && _blockLatex(lines, i, t)?.tex != null) {
          return true;
        }
      case 0x5B /* [ */ || 0x28 /* ( */ :
        if (checkboxMarker(t) != null || radioMarker(t) != null) {
          return true;
        }
      case 0x3C /* < */ :
        final tag = htmlTagAt(t, 0);
        final kind = tag == null ? null : html[tag.name]?.kind;
        if (kind == HtmlTagKind.checkbox &&
            !tag!.closing &&
            (tag.attributes['type'] ?? '').toLowerCase() == 'checkbox') {
          return true;
        }
        if (kind != null &&
            (kind == HtmlTagKind.blockContent ||
                (!tag!.closing &&
                    (kind == HtmlTagKind.rule ||
                        kind == HtmlTagKind.hidden ||
                        html[tag.name]!.spansLines)))) {
          return true;
        }
    }
    if (isHr(t)) {
      return true;
    }
    final marker = listMarkerAt(line);
    if (marker != null &&
        (!interrupting ||
            (!marker.blank && (!marker.ordered || marker.number == 1)))) {
      return true;
    }
    return registry?.match(lines, i) != null;
  }

  /// What the HTML tag opening line [i] ([t], left-trimmed) makes of the
  /// lines it covers, as a block — or null when it is not a block, and the
  /// line is parsed like any other.
  ///
  /// [node] is what to add, if anything. [next] is the line after the ones
  /// consumed, and [rest] the text left after the closing tag on the last of
  /// them, which is parsed again in its place.
  ///
  /// * `<hr>` alone on its line is a rule; `<br>` alone is nothing.
  /// * A closed `<script>` or `<style>` is hidden. An unclosed one is text: a
  ///   stray `<style>` hiding the rest of the reply would be worse than
  ///   showing it.
  /// * Wrapper tags — `<div align="center">`, `<details>` — are dropped, so
  ///   the Markdown inside renders.
  /// * `<h2>`, `<blockquote>`, `<pre>` and the app's block elements take the
  ///   lines up to their closing tag; unclosed, the rest of the document,
  ///   so they render while they stream in.
  ({MdNode? node, int next, String? rest})? _htmlBlock(
    List<String> lines,
    int i,
    String t,
  ) {
    final tag = htmlTagAt(t, 0);
    if (tag == null) {
      return null;
    }
    final syntax = html[tag.name];
    if (syntax == null) {
      return null;
    }
    final alone = tag.end == t.trimRight().length;
    switch (syntax.kind) {
      case HtmlTagKind.blockContent:
        final unwrapped = stripBlockTags(t, html);
        if (unwrapped == null) {
          return null;
        }
        return (
          node: null,
          next: i + 1,
          rest: unwrapped.isEmpty ? null : unwrapped,
        );
      case _ when tag.closing:
        return null;
      case HtmlTagKind.rule:
        return alone
            ? (node: const MdHorizontalRule(), next: i + 1, rest: null)
            : null;
      case HtmlTagKind.lineBreak:
        return alone ? (node: null, next: i + 1, rest: null) : null;
      case HtmlTagKind.checkbox:
        if ((tag.attributes['type'] ?? '').toLowerCase() != 'checkbox') {
          return null;
        }
        return (
          node: MdCheckbox(
            checked: tag.attributes.containsKey('checked'),
            children: inline(t.substring(tag.end).trim()),
          ),
          next: i + 1,
          rest: null,
        );
      case HtmlTagKind.hidden:
        if (tag.isVoid) {
          return alone ? (node: null, next: i + 1, rest: null) : null;
        }
        final content = _htmlContent(lines, i, t, tag, nested: false);
        if (!content.closed) {
          return null;
        }
        return (node: null, next: content.next, rest: content.rest);
      case HtmlTagKind.heading ||
          HtmlTagKind.quote ||
          HtmlTagKind.codeBlock ||
          HtmlTagKind.table ||
          HtmlTagKind.unorderedList ||
          HtmlTagKind.orderedList ||
          HtmlTagKind.svg ||
          HtmlTagKind.blockElement:
        if (tag.isVoid) {
          if (syntax.kind != HtmlTagKind.blockElement) {
            return null;
          }
          final trailing = t.substring(tag.end).trim();
          return (
            node: _element(tag, syntax, const [], closed: true),
            next: i + 1,
            rest: trailing.isEmpty ? null : trailing,
          );
        }
        final content = _htmlContent(
          lines,
          i,
          t,
          tag,
          nested: syntax.kind != HtmlTagKind.codeBlock && !syntax.rawContent,
        );
        return (
          node: _htmlBlockNode(tag, syntax, content.lines, content.closed),
          next: content.next,
          rest: content.rest,
        );
      default:
        return null;
    }
  }

  MdNode _htmlBlockNode(
    ParsedHtmlTag tag,
    HtmlTagSyntax syntax,
    List<String> content,
    bool closed,
  ) {
    switch (syntax.kind) {
      case HtmlTagKind.heading:
        final digit = tag.name.length == 2
            ? int.tryParse(tag.name.substring(1))
            : null;
        return MdHeading(
          level: digit != null && digit >= 1 && digit <= 6 ? digit : 1,
          children: inline(content.join('\n').trim()),
        );
      case HtmlTagKind.quote:
        return MdBlockQuote(children: blocks(content));
      case HtmlTagKind.codeBlock:
        return _htmlCodeBlock(content.join('\n'), closed);
      case HtmlTagKind.table:
        return _htmlTable(tag, content.join('\n'), closed: closed);
      case HtmlTagKind.unorderedList:
        return MdUnorderedList(items: _htmlListItems(content.join('\n')));
      case HtmlTagKind.orderedList:
        final items = _htmlListItems(content.join('\n'));
        final start = int.tryParse(tag.attributes['start'] ?? '') ?? 1;
        return MdOrderedList(
          start: start,
          items: [
            for (var k = 0; k < items.length; k++)
              MdListItem(children: items[k].children, number: start + k),
          ],
        );
      default:
        return _element(tag, syntax, content, closed: closed);
    }
  }

  MdCustomBlock _element(
    ParsedHtmlTag tag,
    HtmlTagSyntax syntax,
    List<String> content, {
    required bool closed,
  }) {
    final source = content.join('\n');
    return MdCustomBlock(
      type: htmlElementType,
      body: source,
      closed: closed,
      data: HtmlElementData(
        name: tag.name,
        attributes: {
          for (final entry in tag.attributes.entries)
            entry.key: decodeEntities(entry.value),
        },
        children: syntax.rawContent ? const [] : blocks(content),
        source: source,
        block: true,
      ),
    );
  }

  /// The `<table>` [tag] opens, as an element whose content is its
  /// structure: `<caption>`, `<thead>`, `<tbody>` and `<tfoot>` sections,
  /// `<tr>` rows (inside a section or directly in the table) and `<th>` and
  /// `<td>` cells, each an [HtmlElementData] keeping its attributes —
  /// `colspan`, `rowspan`, `align`, `style` — for the renderer to lay out.
  ///
  /// A cell holds inline content. A cell outside any `<tr>` starts a row of
  /// its own, and a row or section with no cells is dropped. Tags are read
  /// flat, so the cells of a table nested in a cell join the outer table.
  MdCustomBlock _htmlTable(
    ParsedHtmlTag tag,
    String raw, {
    required bool closed,
  }) {
    final children = <MdNode>[];
    // The open section, row and cell (or caption), innermost last.
    ({ParsedHtmlTag tag, int start, List<MdNode> rows})? section;
    ({ParsedHtmlTag? tag, int start, List<MdNode> cells})? row;
    ({ParsedHtmlTag tag, int start})? cell;

    MdCustomBlock element(
      ParsedHtmlTag? tag,
      String name,
      String source,
      List<MdNode> children, {
      required bool block,
    }) => MdCustomBlock(
      type: htmlElementType,
      body: source,
      closed: true,
      data: HtmlElementData(
        name: name,
        attributes: {
          if (tag != null)
            for (final entry in tag.attributes.entries)
              entry.key: decodeEntities(entry.value),
        },
        children: children,
        source: source,
        block: block,
      ),
    );

    void closeCell(int end) {
      final open = cell;
      if (open == null) {
        return;
      }
      cell = null;
      final source = raw.substring(open.start, end);
      final node = element(
        open.tag,
        open.tag.name,
        source,
        inline(source.replaceAll(_htmlSpace, ' ').trim()),
        block: false,
      );
      if (open.tag.name == 'caption') {
        children.add(node);
        return;
      }
      (row ??= (tag: null, start: open.start, cells: [])).cells.add(node);
    }

    void closeRow(int end) {
      closeCell(end);
      final open = row;
      if (open == null) {
        return;
      }
      row = null;
      if (open.cells.isEmpty) {
        return;
      }
      final node = element(
        open.tag,
        'tr',
        raw.substring(open.start, end),
        open.cells,
        block: true,
      );
      (section?.rows ?? children).add(node);
    }

    void closeSection(int end) {
      closeRow(end);
      final open = section;
      if (open == null) {
        return;
      }
      section = null;
      if (open.rows.isEmpty) {
        return;
      }
      children.add(
        element(
          open.tag,
          open.tag.name,
          raw.substring(open.start, end),
          open.rows,
          block: true,
        ),
      );
    }

    var p = raw.indexOf('<');
    while (p != -1) {
      final inner = htmlTagAt(raw, p);
      switch (inner?.name) {
        case 'thead' || 'tbody' || 'tfoot':
          closeSection(p);
          if (!inner!.closing) {
            section = (tag: inner, start: inner.end, rows: []);
          }
        case 'tr':
          closeRow(p);
          if (!inner!.closing) {
            row = (tag: inner, start: inner.end, cells: []);
          }
        case 'th' || 'td':
          closeCell(p);
          if (!inner!.closing) {
            cell = (tag: inner, start: inner.end);
          }
        case 'caption':
          if (section == null && row == null) {
            closeCell(p);
            if (!inner!.closing) {
              cell = (tag: inner, start: inner.end);
            }
          }
      }
      p = raw.indexOf('<', p + 1);
    }
    closeSection(raw.length);

    return MdCustomBlock(
      type: htmlElementType,
      body: raw,
      closed: closed,
      data: HtmlElementData(
        name: tag.name,
        attributes: {
          for (final entry in tag.attributes.entries)
            entry.key: decodeEntities(entry.value),
        },
        children: children,
        source: raw,
        block: true,
      ),
    );
  }

  /// The `<li>` items in [raw] — nested lists stay inside their item — each
  /// parsed as Markdown blocks, the way a Markdown list item is.
  List<MdListItem> _htmlListItems(String raw) {
    final items = <MdListItem>[];
    var depth = 0;
    int? itemStart;

    void closeItem(int end) {
      final start = itemStart;
      if (start == null) {
        return;
      }
      itemStart = null;
      // A nested list goes on lines of its own, so it starts a block.
      final text = raw
          .substring(start, end)
          .replaceAllMapped(_nestedListOpen, (m) => '\n${m[0]}')
          .replaceAllMapped(_nestedListClose, (m) => '${m[0]}\n');
      final blocks = this.blocks([
        for (final line in text.split('\n'))
          if (line.trim().isNotEmpty) line.trimLeft(),
      ]);
      items.add(
        MdListItem(
          children: blocks.isNotEmpty && blocks.first is MdParagraph
              ? [...(blocks.first as MdParagraph).children, ...blocks.skip(1)]
              : blocks,
        ),
      );
    }

    var p = raw.indexOf('<');
    while (p != -1) {
      final tag = htmlTagAt(raw, p);
      switch (tag?.name) {
        case 'ul' || 'ol':
          depth += tag!.closing ? -1 : 1;
        case 'li' when depth == 0:
          closeItem(p);
          if (!tag!.closing) {
            itemStart = tag.end;
          }
      }
      p = raw.indexOf('<', p + 1);
    }
    closeItem(raw.length);
    return items;
  }

  /// `<pre>` content as a code block: an inner `<code class="language-x">`
  /// names the language and is unwrapped, and references are decoded.
  MdCodeBlock _htmlCodeBlock(String raw, bool closed) {
    var code = raw;
    var language = '';
    final start = firstNonSpace(code);
    if (start != -1 && code.startsWith('<code', start)) {
      final open = htmlTagAt(code, start);
      if (open != null && open.name == 'code' && !open.closing) {
        final classes = (open.attributes['class'] ?? '').split(' ');
        for (final c in classes) {
          if (c.startsWith('language-')) {
            language = c.substring(9);
          } else if (c.startsWith('lang-')) {
            language = c.substring(5);
          }
        }
        final close = code.lastIndexOf('</code>');
        code = code.substring(
          open.end,
          close >= open.end ? close : code.length,
        );
      }
    }
    if (code.startsWith('\n')) {
      code = code.substring(1);
    }
    if (code.endsWith('\n')) {
      code = code.substring(0, code.length - 1);
    }
    return MdCodeBlock(
      language: decodeEntities(language),
      code: decodeEntities(code),
      closed: closed,
    );
  }

  /// The lines inside the element [tag] opens at line [i] ([t]), up to its
  /// matching closing tag — nested tags of the same name counted, when
  /// [nested] — or to the end of [lines].
  ///
  /// Raw content (`<pre>`, `<script>`) is not nested: as in HTML, it ends at
  /// the first closing tag, so a `<pre>` quoted inside code cannot hold the
  /// element open.
  ({List<String> lines, int next, String? rest, bool closed}) _htmlContent(
    List<String> lines,
    int i,
    String t,
    ParsedHtmlTag tag, {
    required bool nested,
  }) {
    final content = <String>[];
    var depth = 1;
    for (var k = i; k < lines.length; k++) {
      final line = k == i ? t : lines[k];
      var from = k == i ? tag.end : 0;
      final contentStart = from;
      var p = line.indexOf('<', from);
      while (p != -1) {
        final inner = htmlTagAt(line, p);
        if (inner != null &&
            inner.name == tag.name &&
            !inner.selfClosing &&
            (nested || inner.closing)) {
          depth += inner.closing ? -1 : 1;
          if (depth == 0) {
            final before = line.substring(contentStart, p);
            if (k > i || before.trim().isNotEmpty) {
              content.add(before);
            }
            final after = line.substring(inner.end).trim();
            return (
              lines: _trimBlankEnds(content),
              next: k + 1,
              rest: after.isEmpty ? null : after,
              closed: true,
            );
          }
        }
        from = p + 1;
        p = line.indexOf('<', from);
      }
      final part = line.substring(contentStart);
      if (k > i || part.trim().isNotEmpty) {
        content.add(part);
      }
    }
    return (
      lines: _trimBlankEnds(content),
      next: lines.length,
      rest: null,
      closed: false,
    );
  }

  /// Block maths opening at line [i] ([t] is the line, left-trimmed).
  ///
  /// Null when no `\]` follows at all. [tex] is null when there is one but the
  /// lines are not a block formula after all: an empty one, one followed by
  /// more text on its closing line (left to the inline parser, which keeps
  /// the text), or one that is only punctuation — `\[\]` is two escaped
  /// brackets.
  ({String? tex, int next})? _blockLatex(List<String> lines, int i, String t) {
    var first = t;
    while (first.startsWith(r'\[')) {
      first = first.substring(2);
    }
    final end = first.indexOf(r'\]');
    if (end != -1) {
      final tex = first.substring(0, end).trim();
      final rest = first.substring(end + 2).trim();
      if (rest.isNotEmpty || !isMathBody(tex)) {
        return (tex: null, next: i + 1);
      }
      return (tex: tex, next: i + 1);
    }
    final content = <String>[];
    if (first.trim().isNotEmpty) {
      content.add(first);
    }
    var k = i + 1;
    while (k < lines.length) {
      final lineEnd = lines[k].indexOf(r'\]');
      if (lineEnd != -1) {
        final pre = lines[k].substring(0, lineEnd);
        if (pre.trim().isNotEmpty) {
          content.add(pre);
        }
        final tex = content.join('\n').trim();
        return (tex: isMathBody(tex) ? tex : null, next: k + 1);
      }
      content.add(lines[k]);
      k += 1;
    }
    return null;
  }

  ({MdBlockQuote node, int next}) _blockQuote(List<String> lines, int start) {
    final inner = <String>[];
    final fences = _FenceTracker();
    // A lazy line leaves the paragraph it continued open, so the next one
    // need not ask again.
    var lazyBefore = false;
    var i = start;
    while (i < lines.length) {
      final line = lines[i];
      if (isBlank(line)) {
        break;
      }
      final t = line.trimLeft();
      if (t.startsWith('>')) {
        var stripped = t.substring(1);
        if (stripped.startsWith(' ') || stripped.startsWith('\t')) {
          stripped = stripped.substring(1);
        }
        inner.add(stripped);
        fences.add(stripped);
        lazyBefore = false;
        i += 1;
        continue;
      }
      // A lazy line continues the paragraph left open inside the quote.
      if (fences.open == null &&
          (lazyBefore || _endsInParagraph(inner)) &&
          (indentWidth(line) >= 4 ||
              !_startsBlock(lines, i, interrupting: false))) {
        inner.add(_lazy(t));
        lazyBefore = true;
        i += 1;
        continue;
      }
      break;
    }
    final alertType = inner.isEmpty
        ? null
        : MarkdownAlertType.fromMarker(inner.first);
    return (
      node: MdBlockQuote(
        children: blocks(inner),
        alert: alertType == null
            ? null
            : MdAlert(type: alertType, children: blocks(inner.sublist(1))),
      ),
      next: i,
    );
  }

  /// A list starting with [first], the marker of line [start].
  ({MdNode node, int next}) _list(
    List<String> lines,
    int start,
    ListMarker first,
  ) {
    final n = lines.length;
    final items = <MdListItem>[];
    var loose = false;
    // How far in a sibling's marker may be.
    final siblingIndent = first.indent > 3 ? first.indent : 3;
    var i = start;
    var next = start;
    ListMarker? marker = first;

    while (marker != null) {
      final contentCol = marker.contentCol;
      final itemLines = <String>[];
      final fences = _FenceTracker();
      if (!marker.blank) {
        itemLines.add(marker.content);
        fences.add(marker.content);
      }
      var k = i + 1;
      var lazyBefore = false;
      // Where a sub-list nested by the leniency below starts: lines indented
      // at least as far belong to it, and so to this item.
      int? lenientFloor;

      // Block maths opened on the marker line — `1. \[` with the body on the
      // lines below, not indented under the marker. The body is opaque, like
      // a fence, so it is claimed here whatever its indentation.
      final latexStart = marker.content;
      if (latexStart.startsWith(r'\[') && !latexStart.contains(r'\]')) {
        final latex = _blockLatex(lines, i, latexStart);
        if (latex != null && latex.tex != null) {
          for (var j = i + 1; j < latex.next; j++) {
            itemLines.add(stripIndent(lines[j], contentCol));
          }
          k = latex.next;
        }
      }

      while (k < n) {
        final line = lines[k];
        if (isBlank(line)) {
          // An item that starts with a blank line ends at a second one.
          if (itemLines.isEmpty) {
            break;
          }
          itemLines.add('');
          fences.add('');
          k += 1;
          continue;
        }
        final indent = indentWidth(line);
        if (indent < contentCol &&
            itemLines.isNotEmpty &&
            (lenientFloor != null
                ? indent >= lenientFloor
                : _nestsLeniently(line, marker))) {
          lenientFloor ??= indent;
        }
        if (indent >= contentCol ||
            (lenientFloor != null && indent >= lenientFloor)) {
          final content = stripIndent(line, contentCol);
          itemLines.add(content);
          fences.add(content);
          lazyBefore = false;
          k += 1;
          continue;
        }
        // A marker as far in as this list's own ends the item — a sibling,
        // or a new list. Asked before laziness: a list that itself started
        // indented four or more (leniently) has siblings indented as far, and
        // the "four or more is a continuation" rule would take them as text.
        if (indent <= siblingIndent && listMarkerAt(line) != null) {
          break;
        }
        // A lazy line continues the paragraph left open inside the item.
        if (itemLines.isNotEmpty &&
            itemLines.last.isNotEmpty &&
            fences.open == null &&
            (lazyBefore || _endsInParagraph(itemLines)) &&
            !_startsBlock(lines, k, interrupting: false)) {
          itemLines.add(_lazy(line.trimLeft()));
          lazyBefore = true;
          k += 1;
          continue;
        }
        break;
      }

      // Trailing blank lines are not the item's; they separate it from what
      // follows.
      while (itemLines.isNotEmpty && itemLines.last.isEmpty) {
        itemLines.removeLast();
      }
      var end = k;
      while (end > i + 1 && isBlank(lines[end - 1])) {
        end -= 1;
      }
      next = end;

      // An item of one plain line — most of them — is that line's inline
      // content; only an item that may hold blocks goes through a block pass.
      final List<MdNode> children;
      if (itemLines.length == 1 &&
          registry == null &&
          _plainLine(itemLines[0])) {
        children = [MdParagraph(children: inline(itemLines[0].trimLeft()))];
      } else {
        children = blocks(itemLines);
        if (_blankBetween) {
          loose = true;
        }
      }
      items.add(
        MdListItem(
          children: children.isNotEmpty && children.first is MdParagraph
              ? [
                  ...(children.first as MdParagraph).children,
                  ...children.skip(1),
                ]
              : children,
          number: first.ordered ? marker.number : null,
        ),
      );

      // The next item: the next non-blank line, when it is a marker of the
      // same kind and not a thematic break.
      var j = k;
      while (j < n && isBlank(lines[j])) {
        j += 1;
      }
      ListMarker? following;
      if (j < n && !isHr(lines[j])) {
        final candidate = listMarkerAt(lines[j]);
        if (candidate != null &&
            candidate.sameKind(first) &&
            candidate.indent <= siblingIndent) {
          following = candidate;
        }
      }
      if (following != null && j > end) {
        loose = true;
      }
      marker = following;
      i = j;
    }

    return (
      node: first.ordered
          ? MdOrderedList(start: first.number, items: items, loose: loose)
          : MdUnorderedList(items: items, loose: loose),
      next: next,
    );
  }

  /// Whether [line], indented less than [marker]'s content, starts a list
  /// nested in its item.
  ///
  /// One leniency over CommonMark: under a numbered item, a bullet indented
  /// two or more — or a numbered list starting again at 1 — nests. Models
  /// write `1. Step` then `  - detail` constantly, and CommonMark would end
  /// the numbered list there and start a separate one. A `  2.` stays a
  /// sibling, as CommonMark has it.
  bool _nestsLeniently(String line, ListMarker marker) {
    if (!marker.ordered || indentWidth(line) < marker.indent + 2) {
      return false;
    }
    final nested = listMarkerAt(line);
    return nested != null &&
        !nested.blank &&
        (!nested.ordered || nested.number == 1);
  }

  /// Consecutive footnote definitions starting at line [start] — blank lines
  /// between them allowed — or null when [start] does not open one the
  /// document defines.
  ({List<MdFootnote> footnotes, int next})? _footnotes(
    List<String> lines,
    int start,
  ) {
    final footnotes = <MdFootnote>[];
    final collecting = sink;
    var i = start;
    var next = start;
    while (i < lines.length) {
      final definition = footnoteDefinitionAt(lines, i);
      if (definition == null) {
        break;
      }
      if (collecting != null) {
        collecting.footnoteDefinitions.add(normalizeLabel(definition.label));
        // A footnote can cite another one, and those are numbered too.
        blocks(definition.lines);
      } else {
        if (!defs.definesFootnote(definition.label)) {
          break;
        }
        final number = defs.footnote(definition.label);
        if (number != null) {
          footnotes.add(
            MdFootnote(
              label: definition.label,
              number: number,
              children: blocks(definition.lines),
            ),
          );
        }
      }
      next = definition.next;
      i = next;
      while (i < lines.length && isBlank(lines[i])) {
        i += 1;
      }
    }
    if (next == start) {
      return null;
    }
    // In number order, so a list of definitions written in any order reads
    // 1, 2, 3 — the order the references point at them.
    footnotes.sort((a, b) => a.number.compareTo(b.number));
    return (footnotes: footnotes, next: next);
  }

  /// Detect and parse a pipe table starting at [i] (header row + `:---:`
  /// separator + body rows).
  ({MdTable node, int next})? _tryTable(List<String> lines, int i) {
    final n = lines.length;
    final headerLine = lines[i].trim();
    if (!headerLine.contains('|') || i + 1 >= n) {
      return null;
    }
    final sepLine = lines[i + 1].trim();
    if (!_isTableSeparator(sepLine)) {
      return null;
    }
    final aligns = _parseAligns(sepLine);
    final header = MdTableRow(cells: _tableRow(headerLine));
    final rows = <MdTableRow>[];
    var k = i + 2;
    while (k < n) {
      final l = lines[k].trim();
      if (l.isEmpty || !l.contains('|')) {
        break;
      }
      rows.add(MdTableRow(cells: _tableRow(l)));
      k += 1;
    }
    return (node: MdTable(aligns: aligns, header: header, rows: rows), next: k);
  }

  List<MdTableCell> _tableRow(String line) => _splitPipes(
    line,
    useDollar,
  ).map((c) => MdTableCell(content: inline(c.trim()))).toList();
}

/// [t] without the wrapper tags at its start and end — `<div …>`, `</p>`,
/// `<details>`, `<summary>` — or null when it has none. Empty when the line
/// was nothing but such tags.
String? stripBlockTags(String t, MarkdownHtml html) {
  var text = t.trim();
  var stripped = false;
  while (text.startsWith('<')) {
    final tag = htmlTagAt(text, 0);
    if (tag == null || html[tag.name]?.kind != HtmlTagKind.blockContent) {
      break;
    }
    text = text.substring(tag.end).trimLeft();
    stripped = true;
  }
  while (text.endsWith('>')) {
    final open = text.lastIndexOf('<');
    if (open == -1) {
      break;
    }
    final tag = htmlTagAt(text, open);
    if (tag == null ||
        tag.end != text.length ||
        html[tag.name]?.kind != HtmlTagKind.blockContent) {
      break;
    }
    text = text.substring(0, open).trimRight();
    stripped = true;
  }
  return stripped ? text : null;
}

final RegExp _htmlSpace = RegExp(r'\s*\n\s*');
final RegExp _nestedListOpen = RegExp(r'<(?:ul|ol)\b', caseSensitive: false);
final RegExp _nestedListClose = RegExp(
  r'</(?:ul|ol)\s*>',
  caseSensitive: false,
);

List<String> _trimBlankEnds(List<String> lines) {
  var start = 0;
  var end = lines.length;
  while (start < end && lines[start].trim().isEmpty) {
    start += 1;
  }
  while (end > start && lines[end - 1].trim().isEmpty) {
    end -= 1;
  }
  return start == 0 && end == lines.length ? lines : lines.sublist(start, end);
}

/// Whether [line] can only be a paragraph: it starts with nothing that could
/// open a block.
bool _plainLine(String line) {
  final first = firstNonSpace(line);
  return first != -1 &&
      first < 4 &&
      !_mayStartBlock(line.codeUnitAt(first)) &&
      !line.contains('|');
}

/// A lazy continuation line, made safe to hand to the container's own parse.
///
/// It is only ever paragraph text — that is what made it lazy — but parsed
/// again inside the container, a `===` would underline the paragraph into a
/// heading. Indented four, it can only continue the paragraph.
String _lazy(String t) => '    $t';

/// Whether the content gathered for a container so far ends inside a
/// paragraph, which a lazy line could continue.
///
/// Looks through the containers nested at the end — `> - text` ends in the
/// list item's paragraph — at the last line itself.
bool _endsInParagraph(List<String> lines) {
  if (lines.isEmpty) {
    return false;
  }
  var t = lines.last.trimLeft();
  while (true) {
    if (t.startsWith('>')) {
      t = t.substring(1).trimLeft();
      continue;
    }
    final marker = listMarkerAt(t);
    if (marker != null && !marker.blank) {
      t = marker.content.trimLeft();
      continue;
    }
    break;
  }
  if (t.isEmpty) {
    return false;
  }
  return fenceOpen(t) == null &&
      isHeading(t) == null &&
      !isHr(t) &&
      setextUnderlineLevel(t) == null &&
      !(t.startsWith('|') && t.endsWith('|'));
}

/// Tracks whether a fence is open after each line added to a container's
/// content, so the container knows not to take a lazy line into it.
class _FenceTracker {
  FenceOpen? open;
  int _depth = 0;

  void add(String line) {
    final current = open;
    final first = firstNonSpace(line);
    if (first == -1) {
      return;
    }
    // Most lines cannot open, close or nest a fence: they start with none of
    // a fence character, a quote marker or a list marker.
    if ((current == null || _depth == 0) &&
        !_mayAffectFence(line.codeUnitAt(first))) {
      return;
    }
    final depth = quoteDepth(line);
    if (current != null && depth >= _depth) {
      if (isFenceClose(unquoted(line), current)) {
        open = null;
      }
      return;
    }
    var t = unquoted(line);
    _depth = depth;
    if (t.isEmpty ||
        !(t.codeUnitAt(0) == 0x60 ||
            t.codeUnitAt(0) == 0x7E ||
            _isListMarkerStart(t.codeUnitAt(0)))) {
      open = null;
      return;
    }
    final marker = listMarkerAt(t);
    if (marker != null && !marker.blank) {
      t = marker.content.trimLeft();
    }
    open = fenceOpen(t);
  }
}

bool _mayAffectFence(int c) =>
    c == 0x60 /* ` */ ||
    c == 0x7E /* ~ */ ||
    c == 0x3E /* > */ ||
    _isListMarkerStart(c);

bool _isListMarkerStart(int c) =>
    c == 0x2D /* - */ ||
    c == 0x2A /* * */ ||
    c == 0x2B /* + */ ||
    (c >= 0x30 && c <= 0x39);

/// Whether a line starting with [c] (its first non-space character) can
/// start any block at all — the cheap test before the real ones.
bool _mayStartBlock(int c) => c < 0x80
    ? _mayAffectFence(c) ||
          c == 0x23 /* # */ ||
          c == 0x5F /* _ */ ||
          c == 0x5C /* \ */ ||
          c == 0x5B /* [ */ ||
          c == 0x28 /* ( */ ||
          c == 0x3C /* < */ ||
          c == 0x7C /* | */ ||
          c == 0x3D /* = */
    : c == 0x2E3B /* ⸻ */;

bool _isTableSeparator(String line) {
  final t = line.trim();
  if (!t.contains('-') || !t.contains('|')) {
    return false;
  }
  // A separator cell is only `-` and `:`, so the escape/math rules cannot
  // change the outcome here; useDollar is false to keep the fast path.
  final cells = _splitPipes(t, false);
  if (cells.isEmpty) {
    return false;
  }
  for (final cell in cells) {
    final c = cell.trim();
    if (c.isEmpty || !c.contains('-')) {
      return false;
    }
    for (var idx = 0; idx < c.length; idx++) {
      final ch = c[idx];
      if (ch != '-' && ch != ':') {
        return false;
      }
    }
  }
  return true;
}

List<MdAlign> _parseAligns(String line) {
  return _splitPipes(line, false).map((cell) {
    final c = cell.trim();
    final left = c.startsWith(':');
    final right = c.endsWith(':');
    if (left && right) {
      return MdAlign.center;
    }
    if (right) {
      return MdAlign.right;
    }
    if (left) {
      return MdAlign.left;
    }
    return MdAlign.none;
  }).toList();
}

List<String> _splitPipes(String line, bool useDollar) {
  var t = line.trim();
  if (t.startsWith('|')) {
    t = t.substring(1);
  }
  if (t.endsWith('|')) {
    t = t.substring(0, t.length - 1);
  }
  // Fast path: no construct can hide a pipe, so the native split is correct.
  if (!t.contains('\\') &&
      !t.contains('`') &&
      !(useDollar && t.contains(r'$'))) {
    return t.split('|');
  }
  return _splitPipesScanning(t, useDollar);
}

/// Splits on `|` at depth zero only. Pipes inside code spans, `\(…\)` and
/// (when enabled) `$…$` math, or escaped as `\|`, stay inside their cell.
///
/// The skip rules mirror [parseInline] exactly — same terminators, same
/// fallbacks — so a span that survives the split is the same span the inline
/// parser will later recognise.
List<String> _splitPipesScanning(String t, bool useDollar) {
  const backslash = 0x5C;
  const backtick = 0x60;
  const dollar = 0x24;
  const pipe = 0x7C;
  const openParen = 0x28;

  final cells = <String>[];
  final buf = StringBuffer();
  final n = t.length;
  var i = 0;
  DollarMathCloser? dollars;

  while (i < n) {
    final c = t.codeUnitAt(i);

    // `code span` — a run of N backticks to the next run of exactly N, as
    // parseInline matches it. An unclosed run is literal, all of it.
    if (c == backtick) {
      final span = codeSpanAt(t, i);
      final end = span != null
          ? span.close + span.run
          : i + backtickRunAt(t, i);
      buf.write(t.substring(i, end));
      i = end;
      continue;
    }

    if (c == backslash && i + 1 < n) {
      // \( inline latex \)
      if (t.codeUnitAt(i + 1) == openParen) {
        final end = t.indexOf('\\)', i + 2);
        if (end != -1) {
          buf.write(t.substring(i, end + 2));
          i = end + 2;
          continue;
        }
      }
      // Any other \X escapes X — including \| — and is kept verbatim for the
      // inline parser to unescape.
      buf.write(t.substring(i, i + 2));
      i += 2;
      continue;
    }

    if (useDollar && c == dollar) {
      var matched = false;
      if (i + 1 < n && t.codeUnitAt(i + 1) == dollar) {
        final end = t.indexOf(r'$$', i + 2);
        if (end != -1) {
          buf.write(t.substring(i, end + 2));
          i = end + 2;
          matched = true;
        }
      }
      if (!matched) {
        final end = (dollars ??= DollarMathCloser(t)).find(i);
        if (end != -1) {
          buf.write(t.substring(i, end + 1));
          i = end + 1;
          matched = true;
        }
      }
      if (matched) {
        continue;
      }
    }

    if (c == pipe) {
      cells.add(buf.toString());
      buf.clear();
      i += 1;
      continue;
    }

    buf.writeCharCode(c);
    i += 1;
  }

  cells.add(buf.toString());
  return cells;
}
