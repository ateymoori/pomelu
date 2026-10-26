part of '../gpt_markdown.dart';

/// Renders a plusparse [MdDocument] AST into the same `InlineSpan` tree the
/// regex pipeline (`MarkdownComponent.generate`) produces — same custom
/// widgets ([CodeField], [UnorderedListView], [LinkButton], [CustomCb], …),
/// same theme handling, same config builder hooks. Parsing is a single pass
/// over the text instead of recursive combined-regex scanning, which is what
/// makes re-rendering streaming LLM output cheap.
class PlusparseRenderer {
  PlusparseRenderer._();

  /// Parses [text] and renders it to spans. When [inlineOnly] is true (the
  /// old `includeGlobalComponents: false` mode used for nested content such
  /// as table cells), a single-paragraph document is unwrapped to its inline
  /// spans instead of being treated as a block.
  static List<InlineSpan> render(
    BuildContext context,
    String text,
    GptMarkdownConfig config, {
    bool inlineOnly = false,
  }) {
    // The incremental view masks earlier, before it segments; masking again is
    // a no-op because a masked directive no longer holds its own delimiters.
    final directives = config.inlineDirectives;
    if (directives != null && directives.isNotEmpty) {
      text = maskInlineDirectives(
        text,
        directives,
        blockRegistry: config.blockRegistry,
      );
    }
    final patterns = config.inlinePatterns;
    if (patterns != null && patterns.isNotEmpty) {
      text = maskInlinePatterns(
        text,
        patterns,
        blockRegistry: config.blockRegistry,
      );
    }
    return renderDocument(
      context,
      Plusparse.parse(
        text,
        blockRegistry: config.blockRegistry,
        html: config.markdownHtml,
      ),
      config,
      inlineOnly: inlineOnly,
    );
  }

  /// Renders an existing syntax tree without parsing again. The document is
  /// independent of Flutter themes; callers may retain it across style changes.
  /// This does not mask inline extensions or normalize source; use [render]
  /// when starting from raw Markdown with syntax-override patterns/directives.
  static List<InlineSpan> renderDocument(
    BuildContext context,
    MdDocument doc,
    GptMarkdownConfig config, {
    bool inlineOnly = false,
  }) {
    if (inlineOnly &&
        doc.children.length == 1 &&
        doc.children.first is MdParagraph) {
      return _inlineSpans(
        context,
        (doc.children.first as MdParagraph).children,
        config,
      );
    }
    return _blockSpans(context, doc.children, config);
  }

  // ---------------------------------------------------------------------
  // Block level
  // ---------------------------------------------------------------------

  /// Replicates `BlockMd.span`'s wrapping of a block widget.
  static InlineSpan _blockSpan(Widget child) => BlockWidgetSpan(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: MarkdownTextScaling.wrap(child, enabled: false)),
      ],
    ),
    bare: child,
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
  );

  /// A block widget whose inner text the streaming reveal can still reach.
  ///
  /// [content] is the text the block wraps, built once for counting.
  /// [wrap] builds the widget from a transform to apply to that text — the
  /// identity transform for a static render, the reveal while streaming. The
  /// widget is built by the same code either way, so nothing about its
  /// appearance depends on whether a reveal is running.
  static InlineSpan _revealableBlock({
    required List<InlineSpan> content,
    required Widget Function(SpanTransform transform) wrap,
  }) {
    InlineSpan build(SpanTransform transform) => RevealableSpan(
      content: content,
      rebuild: build,
      children: [_blockSpan(wrap(transform))],
    );
    return build(_identity);
  }

  static List<InlineSpan> _identity(List<InlineSpan> spans) => spans;

  static List<InlineSpan> _blockSpans(
    BuildContext context,
    List<MdNode> blocks,
    GptMarkdownConfig config, {
    String separator = "\n\n",
  }) {
    final spans = <InlineSpan>[];
    for (final node in blocks) {
      if (spans.isNotEmpty) {
        spans.add(
          separator == "\n\n"
              ? paragraphBreakSpan(context, config)
              : TextSpan(text: separator, style: config.style),
        );
      }
      spans.addAll(_block(context, node, config));
    }
    return spans;
  }

  static List<InlineSpan> _block(
    BuildContext context,
    MdNode node,
    GptMarkdownConfig config,
  ) {
    switch (node) {
      case MdCustomBlock(:final HtmlElementData data)
          when node.type == htmlElementType:
        return _htmlBlock(context, node, data, config);
      case MdCustomBlock():
        final builder = config.blockRenderers[node.type];
        return [
          _blockSpan(
            builder == null
                ? Text(node.body, style: config.style)
                : builder(context, node, config),
          ),
        ];
      case MdParagraph(:final children):
        return _inlineSpans(context, children, config);
      case MdHeading(:final level, :final children):
        List<InlineSpan>? content;
        InlineSpan heading(SpanTransform transform) {
          final child = headingWidget(
            context,
            config,
            level: level,
            buildChildren: (conf) =>
                transform(content ??= _inlineSpans(context, children, conf)),
          );
          return RevealableSpan(
            content: content!,
            rebuild: heading,
            children: [_blockSpan(child)],
          );
        }
        return [heading(_identity)];
      case MdHorizontalRule():
        return [_blockSpan(hrWidget(context, config))];
      case MdCodeBlock(:final language, :final code, :final closed):
        return [
          _blockSpan(
            codeBlockWidget(
              context,
              config,
              name: language,
              code: code,
              closed: closed,
            ),
          ),
        ];
      case MdBlockLatex(:final tex):
        return [
          _blockSpan(latexWidget(context, config, tex: tex, inline: false)),
        ];
      case MdBlockQuote(:final children, :final alert)
          when alert != null && _rendersAlerts(config):
        Widget quoteContent(GptMarkdownConfig conf) => conf.getRich(
          TextSpan(
            children: _blockSpans(
              context,
              children,
              conf.copyWith(blocksRenderDirectly: false),
            ),
          ),
          ambientScaling: conf.blocksRenderDirectly,
        );
        // Built once, as for a quote below; the title is not part of the
        // reveal, only the body is.
        List<InlineSpan>? content;
        InlineSpan build(SpanTransform transform) {
          final child = alertSpan(
            context,
            config,
            type: alert.type,
            buildContent: (conf) => conf.getRich(
              TextSpan(
                children: transform(
                  content ??= _blockSpans(
                    context,
                    alert.children,
                    conf.copyWith(blocksRenderDirectly: false),
                  ),
                ),
              ),
              ambientScaling: conf.blocksRenderDirectly,
            ),
            buildQuoteContent: quoteContent,
          );
          return RevealableSpan(
            content: content!,
            rebuild: build,
            children: [child],
          );
        }
        return [build(_identity)];
      case MdBlockQuote(:final children):
        // Build once under the actual quote style. Counting an independently
        // rendered copy used to double the work at EVERY nesting level.
        List<InlineSpan>? content;
        InlineSpan quote(SpanTransform transform) {
          final child = blockQuoteSpan(
            context,
            config,
            buildContent: (conf) => conf.getRich(
              TextSpan(
                children: transform(
                  content ??= _blockSpans(
                    context,
                    children,
                    conf.copyWith(blocksRenderDirectly: false),
                  ),
                ),
              ),
              ambientScaling: conf.blocksRenderDirectly,
            ),
          );
          return RevealableSpan(
            content: content!,
            rebuild: quote,
            children: [child],
          );
        }
        return [quote(_identity)];
      case MdCheckbox(:final checked, :final children):
        // Built once and used for both the reveal's character count and the
        // rendered label: `wrap` is handed the same `config` here, so a second
        // build produced an identical list. Headings and block quotes do need
        // two, because their `wrap` re-renders under a different config.
        final labelSpans = _inlineSpans(context, children, config);
        return [
          _revealableBlock(
            content: labelSpans,
            wrap: (transform) => checkboxWidget(
              context,
              config,
              checked: checked,
              label: config.getRich(
                TextSpan(children: transform(labelSpans)),
                ambientScaling: config.blocksRenderDirectly,
              ),
            ),
          ),
        ];
      case MdRadio(:final selected, :final children):
        final labelSpans = _inlineSpans(context, children, config);
        return [
          _revealableBlock(
            content: labelSpans,
            wrap: (transform) => radioWidget(
              context,
              config,
              selected: selected,
              label: config.getRich(
                TextSpan(children: transform(labelSpans)),
                ambientScaling: config.blocksRenderDirectly,
              ),
            ),
          ),
        ];
      case MdUnorderedList(:final items):
        return _list(context, items, config, ordered: false, start: 1);
      case MdOrderedList(:final start, :final items):
        return _list(context, items, config, ordered: true, start: start);
      case MdFootnoteDefinitions(:final footnotes):
        // A numbered list whose numbers are the footnotes' own, so a
        // definition renders under the number its references show.
        return _list(
          context,
          [
            for (final footnote in footnotes)
              MdListItem(
                children: _unwrapLeadingParagraph(footnote.children),
                number: footnote.number,
              ),
          ],
          config,
          ordered: true,
          start: footnotes.first.number,
        );
      case MdTable():
        return [_table(context, node, config)];
      // Inline nodes reaching block position (defensive; parser does not
      // produce this) render as inline content.
      default:
        return _inlineSpans(context, [node], config);
    }
  }

  static List<InlineSpan> _list(
    BuildContext context,
    List<MdListItem> items,
    GptMarkdownConfig config, {
    required bool ordered,
    required int start,
  }) {
    final spans = <InlineSpan>[];
    for (var i = 0; i < items.length; i++) {
      if (spans.isNotEmpty) {
        spans.add(TextSpan(text: "\n", style: config.style));
      }
      // An item's children are its inline content followed by any nested
      // blocks (e.g. a nested list); render them into one rich child.
      final item = items[i];
      final inline = <MdNode>[];
      final nested = <MdNode>[];
      for (final n in item.children) {
        (_isInline(n) && nested.isEmpty ? inline : nested).add(n);
      }
      List<InlineSpan> body(GptMarkdownConfig conf) => [
        ..._inlineSpans(context, inline, conf),
        if (nested.isNotEmpty) ...[
          // Only when there is something to separate. A task list item is a
          // block node (the checkbox) with no inline content at all, and an
          // unconditional break put it on the line below its own bullet.
          if (inline.isNotEmpty) TextSpan(text: "\n", style: conf.style),
          // These blocks remain placeholders in the item paragraph; only
          // the outer item was lifted into the widget tree.
          ..._blockSpans(
            context,
            nested,
            conf.copyWith(blocksRenderDirectly: false),
            separator: "\n",
          ),
        ],
      ];

      final number = ordered ? "${item.number ?? (start + i)}" : null;
      // Same config both times, so build the item body once.
      final itemBody = body(config);
      spans.add(
        _revealableBlock(
          content: itemBody,
          wrap: (transform) {
            final itemChild = config.getRich(
              TextSpan(children: transform(itemBody)),
              ambientScaling: config.blocksRenderDirectly,
            );
            return number == null
                ? unorderedListItem(context, config, itemChild)
                : orderedListItem(context, config, number, itemChild);
          },
        ),
      );
    }
    return spans;
  }

  /// [blocks] with a leading paragraph's inline content lifted out, which is
  /// the shape a list item's children take: inline content, then blocks.
  static List<MdNode> _unwrapLeadingParagraph(List<MdNode> blocks) {
    if (blocks.isNotEmpty && blocks.first is MdParagraph) {
      return [...(blocks.first as MdParagraph).children, ...blocks.skip(1)];
    }
    return blocks;
  }

  static bool _isInline(MdNode n) => switch (n) {
    MdText() ||
    MdFootnoteReference() ||
    MdBold() ||
    MdItalic() ||
    MdStrike() ||
    MdUnderline() ||
    MdInlineCode() ||
    MdInlineLatex() ||
    MdLink() ||
    MdImage() ||
    MdSourceTag() ||
    MdLineBreak() => true,
    MdSuperscript() || MdSubscript() || MdHighlight() => true,
    MdCustomBlock(:final HtmlElementData data) => !data.block,
    _ => false,
  };

  static InlineSpan _table(
    BuildContext context,
    MdTable node,
    GptMarkdownConfig config,
  ) {
    final rows = [node.header, ...node.rows];
    var maxCol = 0;
    for (final row in rows) {
      maxCol = max(maxCol, row.cells.length);
    }
    if (maxCol == 0) {
      return TextSpan(text: "", style: config.style);
    }

    final columnAlignments = List<TextAlign>.generate(maxCol, (i) {
      final align = i < node.aligns.length ? node.aligns[i] : MdAlign.none;
      return switch (align) {
        MdAlign.center => TextAlign.center,
        MdAlign.right => TextAlign.right,
        _ => TextAlign.left,
      };
    });

    // A left-aligned cell no longer sits in an alignment box, so its text
    // fills the column and its own `textAlign` is what places it. An unset
    // `textAlign` already starts at the leading edge, which is exactly what
    // that column wants — so only a caller who set one needs overriding, and
    // the common table allocates nothing here. A centred or right-aligned
    // column keeps its box and shrink-wraps inside it, where `textAlign` has
    // nothing left to do.
    final ambientAlign = config.textAlign;
    final leftConfig =
        (ambientAlign == null ||
            ambientAlign == TextAlign.left ||
            ambientAlign == TextAlign.start)
        ? config
        : config.copyWith(textAlign: TextAlign.left);

    final tableBuilder = config.tableBuilder;
    if (tableBuilder != null) {
      final customTable = List<CustomTableRow>.generate(rows.length, (index) {
        final row = rows[index];
        final fields = List<CustomTableField>.generate(maxCol, (col) {
          return CustomTableField(
            data: col < row.cells.length
                ? _plainText(row.cells[col].content)
                : "",
            alignment: columnAlignments[col],
          );
        });
        return CustomTableRow(isHeader: index == 0, fields: fields);
      });
      return _blockSpan(
        tableBuilder(
          context,
          customTable,
          config.style ?? const TextStyle(),
          config,
        ),
      );
    }

    final tableStyle =
        (resolvedStyleSheet(context, config).table ?? const TableStyle())
            .resolve(Theme.of(context).colorScheme);
    final tableRadius = tableStyle.borderRadius;
    return _blockSpan(
      _TableViewport(
        overflow: tableStyle.overflow ?? TableOverflow.scroll,
        // Pomelu patch: row fills are clipped to the rounded border.
        child: _clipTable(tableRadius, Table(
          textDirection: config.textDirection,
          defaultColumnWidth:
              tableStyle.columnWidth ??
              _defaultTableColumnWidth(tableStyle.overflow, maxCol),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.all(
            width: tableStyle.borderWidth ?? 1,
            color:
                tableStyle.borderColor ??
                Theme.of(context).colorScheme.onSurface,
            borderRadius: tableRadius == null
                ? BorderRadius.zero
                : BorderRadius.all(tableRadius),
          ),
          children: List<TableRow>.generate(rows.length, (index) {
            final row = rows[index];
            final isHeader = index == 0;
            // Stripes count data rows, so the header never takes one and the
            // first row under it is always unstriped.
            final stripe = tableStyle.rowStripeColor;
            return TableRow(
              decoration: isHeader
                  ? BoxDecoration(
                      color:
                          tableStyle.headerBackground ??
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    )
                  : (stripe != null && index.isEven)
                  ? BoxDecoration(color: stripe)
                  : null,
              children: List<Widget>.generate(maxCol, (col) {
                final cell = col < row.cells.length ? row.cells[col] : null;
                if (cell == null || cell.content.isEmpty) {
                  return const SizedBox();
                }
                var cellConfig = columnAlignments[col] == TextAlign.left
                    ? leftConfig
                    : config;
                // Pomelu patch: the spans carry `config.style`, which beats
                // the inherited header style below; merge it in here too.
                final header = tableStyle.headerTextStyle;
                if (isHeader && header != null) {
                  cellConfig = cellConfig.copyWith(
                    style: (cellConfig.style ?? const TextStyle()).merge(header),
                  );
                }
                Widget content = Padding(
                  padding:
                      tableStyle.cellPadding ??
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: cellConfig.getRich(
                    ambientScaling: config.blocksRenderDirectly,
                    TextSpan(
                      children: _inlineSpans(context, cell.content, cellConfig),
                    ),
                  ),
                );
                // Merged into the ambient style rather than replacing it, so
                // setting only `fontWeight` keeps the document's family, size
                // and colour. `getRich` renders the span as given and does not
                // apply `config.style`, so the header style has to arrive as
                // an inherited default rather than through the config.
                final headerStyle = tableStyle.headerTextStyle;
                if (isHeader && headerStyle != null) {
                  content = DefaultTextStyle.merge(
                    style: headerStyle,
                    child: content,
                  );
                }
                // Only a column that pulls its content off the leading edge
                // needs an alignment box. A left-aligned cell is already
                // flush left. The box is not free: content-sized columns lay
                // every cell out twice, once to measure and once for real, so
                // a redundant wrapper is two extra layouts per cell on top of
                // one more render object for paint to walk.
                switch (columnAlignments[col]) {
                  case TextAlign.center:
                    content = Center(child: content);
                    break;
                  case TextAlign.right:
                    content = Align(
                      alignment: Alignment.centerRight,
                      child: content,
                    );
                    break;
                  default:
                    break;
                }
                return content;
              }),
            );
          }),
        )),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Inline level
  // ---------------------------------------------------------------------

  /// [linkTap] is set while rendering a link's label: the tap the link
  /// follows, which an image in the label takes as its own.
  static List<InlineSpan> _inlineSpans(
    BuildContext context,
    List<MdNode> nodes,
    GptMarkdownConfig config, {
    VoidCallback? linkTap,
  }) {
    final spans = <InlineSpan>[];
    for (final node in nodes) {
      spans.add(_inline(context, node, config, linkTap: linkTap));
    }
    return spans;
  }

  /// Runs a run of plain text through the consumer-facing inline syntaxes:
  /// [GptMarkdownConfig.inlinePatterns] first, then autolinking.
  ///
  /// Patterns are regex components, so they are dispatched by
  /// [MarkdownComponent.generate] with a component list holding nothing else —
  /// which is what keeps their scope filtering, boundary rules and precedence
  /// identical to the regex pipeline instead of reimplemented here. Autolinks
  /// used to go the same way and no longer do; see [_plainTextSpans].
  static List<InlineSpan> _textSpans(
    BuildContext context,
    String text,
    GptMarkdownConfig config,
  ) {
    // A masked directive is inert text to everything upstream; this is where
    // it becomes a span again. Done first so the host's builder receives the
    // payload before inline patterns or autolinking can touch it.
    List<InlineSpan> withPatterns(String rest) {
      // Patterns were lifted out before parsing so they could beat the
      // built-in interpretation of the same text; this puts them back.
      final patterns = config.inlinePatterns;
      if (patterns == null || patterns.isEmpty) {
        return _plainTextSpans(context, rest, config);
      }
      return expandInlinePatterns(
        context,
        rest,
        patterns,
        config,
        (plain) => _plainTextSpans(context, plain, config),
      );
    }

    final directives = config.inlineDirectives;
    if (directives != null && directives.isNotEmpty) {
      return expandInlineDirectives(
        context,
        text,
        directives,
        config.style ?? const TextStyle(),
        withPatterns,
      );
    }
    return withPatterns(text);
  }

  /// Autolinks one run of plain text, and claims any inline pattern masking
  /// could not reach.
  ///
  /// Masked pattern matches have already been expanded by the caller. What is
  /// left is autolinking, plus a pattern that only matches the parsed run and
  /// never the source — see the comment in the body.
  ///
  /// This was the last thing on the plusparse path that ran the legacy
  /// combined regex, and it was the most expensive: the autolink pattern is a
  /// six-way alternation, so proving that a paragraph of ordinary prose holds
  /// no link meant backtracking at every word. [autolinkSpans] finds the same
  /// candidates with a character scan and hands each one to the same
  /// [AutolinkMd] resolution code; `test/regression/autolink_parity_test.dart`
  /// holds the two paths against each other.
  static List<InlineSpan> _plainTextSpans(
    BuildContext context,
    String text,
    GptMarkdownConfig config,
  ) {
    final patterns = config.inlinePatterns;
    if (patterns != null && patterns.isNotEmpty) {
      // Not the scanner: a pattern and an autolink decide precedence between
      // them through one combined regex — patterns are listed first, so the
      // earliest match wins and a tie goes to the pattern — and splitting the
      // dispatch in two would decide it by which half ran first instead.
      //
      // This is also the only place a pattern can still be claimed at all.
      // Masking lifts pattern matches out of the *source* before parsing, but
      // a run is not always a substring of it: `RegExp(r'^b$')` matches the
      // `b` that `a**b**c` parses to and never matches the source, so this
      // dispatch is what renders it. `test/regression/autolink_parity_test`
      // pins that case.
      //
      // So it runs whether or not autolinking is on. It used to sit behind
      // the `autolink` check, and with `autolink: false` a mention inside
      // bold — `**@alice**` — stayed raw text.
      return MarkdownComponent.generate(
        context,
        text,
        config.copyWith(
          inlineComponents: config.autolink ? [AutolinkMd()] : const [],
        ),
        false,
      );
    }
    if (!config.autolink) {
      return [TextSpan(text: text, style: config.style)];
    }
    return autolinkSpans(context, text, config);
  }

  static InlineSpan _inline(
    BuildContext context,
    MdNode node,
    GptMarkdownConfig config, {
    VoidCallback? linkTap,
  }) {
    if (config.scope == MarkdownScope.linkLabel) {
      switch (node) {
        // `[![badge](src)](url)`: the image renders, and tapping it follows
        // the link. A link label is styled text, so the image is one ordinary
        // placeholder in it.
        //
        // Except under the deprecated `linkBuilder`, which still draws the
        // whole link as a widget: a placeholder nested inside that one does
        // not paint on iOS, so the image stays its source text there.
        // ignore: deprecated_member_use_from_same_package
        case MdImage(:final alt, :final url) when config.linkBuilder != null:
          return TextSpan(text: '![$alt]($url)', style: config.style);
        case MdImage(:final url, :final width, :final height):
          return imageSpan(
            context,
            config,
            url: url,
            width: width,
            height: height,
            onTap: linkTap,
          );
        case MdLink(:final children):
          // CommonMark forbids a link inside a link label; render the label's
          // own content and drop the nested link.
          return TextSpan(
            children: _inlineSpans(context, children, config, linkTap: linkTap),
            style: config.style,
          );
        default:
          break;
      }
    }

    switch (node) {
      case MdText(:final text):
        return TextSpan(
          children: _textSpans(context, text, config),
          style: config.style,
        );
      case MdLineBreak():
        return TextSpan(text: "\n", style: config.style);
      case MdBold(:final children):
        final conf = config.copyWith(
          style:
              config.style?.copyWith(fontWeight: FontWeight.bold) ??
              const TextStyle(fontWeight: FontWeight.bold),
        );
        return TextSpan(
          children: _inlineSpans(context, children, conf, linkTap: linkTap),
          style: conf.style,
        );
      case MdItalic(:final children):
        final conf = config.copyWith(
          style: (config.style ?? const TextStyle()).copyWith(
            fontStyle: FontStyle.italic,
          ),
        );
        return TextSpan(
          children: _inlineSpans(context, children, conf, linkTap: linkTap),
          style: conf.style,
        );
      case MdStrike(:final children):
        final conf = config.copyWith(
          style:
              config.style?.copyWith(
                decoration: TextDecoration.lineThrough,
                decorationColor: config.style?.color,
              ) ??
              const TextStyle(decoration: TextDecoration.lineThrough),
        );
        return TextSpan(
          children: _inlineSpans(context, children, conf, linkTap: linkTap),
          style: conf.style,
        );
      case MdUnderline(:final children):
        final conf = config.copyWith(
          style: (config.style ?? const TextStyle()).copyWith(
            decoration: TextDecoration.underline,
            decorationColor: config.style?.color,
          ),
        );
        return TextSpan(
          children: _inlineSpans(context, children, conf, linkTap: linkTap),
          style: conf.style,
        );
      case MdInlineCode(:final text):
        return inlineCodeSpan(context, text, config);
      case MdInlineLatex(:final tex):
        return _latexSpan(
          context,
          config,
          tex: tex,
          placeholder: (child) => WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: child,
          ),
        );
      case MdLink(autolink: true, :final children) when !config.autolink:
        // `autolink: false` turns `<https://…>` off too: it reads as written.
        return TextSpan(
          children: _textSpans(context, '<${_plainText(children)}>', config),
          style: config.style,
        );
      case MdLink(:final children, :final url):
        return _link(context, children, url, config);
      case MdImage(:final url, :final width, :final height):
        return imageSpan(
          context,
          config,
          url: url,
          width: width,
          height: height,
        );
      case MdSourceTag(:final id, :final url):
        return sourceTagSpan(context, id, config, url: url);
      case MdFootnoteReference(:final number):
        return _footnoteReference(context, number, config);
      case MdSuperscript(:final children):
        return _script(context, children, config, raised: true);
      case MdSubscript(:final children):
        return _script(context, children, config, raised: false);
      case MdHighlight(:final children):
        final highlight =
            (resolvedStyleSheet(context, config).highlight ??
                    const HighlightStyle())
                .resolve(Theme.of(context).colorScheme);
        final conf = config.copyWith(
          style: (config.style ?? const TextStyle()).copyWith(
            backgroundColor: highlight.backgroundColor,
            color: highlight.color,
          ),
        );
        return TextSpan(
          children: _inlineSpans(context, children, conf, linkTap: linkTap),
          style: conf.style,
        );
      case MdCustomBlock(:final HtmlElementData data)
          when node.type == htmlElementType:
        return _htmlInline(context, node, data, config);
      // Block nodes in inline position (nested content) fall back to their
      // block rendering.
      default:
        final blocks = _block(context, node, config);
        return blocks.length == 1 ? blocks.first : TextSpan(children: blocks);
    }
  }

  /// Superscript ([raised]) or subscript text: smaller, and set above or
  /// below the line, as [ScriptStyle] says.
  static InlineSpan _script(
    BuildContext context,
    List<MdNode> children,
    GptMarkdownConfig config, {
    required bool raised,
  }) {
    final script =
        resolvedStyleSheet(context, config).script ?? const ScriptStyle();
    final style = config.style ?? const TextStyle();
    final conf = config.copyWith(
      style: style.copyWith(
        fontSize:
            (style.fontSize ?? 14) * (script.scale ?? ScriptStyle.defaultScale),
        color: script.color ?? style.color,
      ),
    );
    return scaledWidgetSpan(
      config: config,
      alignment: raised
          ? PlaceholderAlignment.top
          : PlaceholderAlignment.bottom,
      baseline: null,
      child: conf.getRich(
        TextSpan(
          children: _inlineSpans(context, children, conf),
          style: conf.style,
        ),
      ),
    );
  }

  /// A footnote reference: its number, small and raised, in the link colour.
  static InlineSpan _footnoteReference(
    BuildContext context,
    int number,
    GptMarkdownConfig config,
  ) {
    final style = config.style ?? const TextStyle();
    return scaledWidgetSpan(
      config: config,
      alignment: PlaceholderAlignment.top,
      baseline: null,
      child: Text(
        '$number',
        style: style.copyWith(
          fontSize: (style.fontSize ?? 14) * 0.75,
          color: Theme.of(context).colorScheme.primary,
        ),
        textDirection: config.textDirection,
      ),
    );
  }

  static InlineSpan _link(
    BuildContext context,
    List<MdNode> children,
    String url,
    GptMarkdownConfig config,
  ) {
    final label = _plainText(children);
    final onLinkTap = config.onLinkTap;
    return buildLinkSpan(
      context,
      config,
      url: url,
      label: label,
      buildLabelSpans: (conf) => _inlineSpans(
        context,
        children,
        conf,
        // The same call the link's own text makes when tapped.
        linkTap: onLinkTap == null ? null : () => onLinkTap(url, label),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // HTML elements
  // ---------------------------------------------------------------------

  static HtmlElementDetails _htmlDetails(
    BuildContext context,
    MdCustomBlock node,
    HtmlElementData data,
    GptMarkdownConfig config,
  ) => HtmlElementDetails(
    node: node,
    data: data,
    style: config.style ?? DefaultTextStyle.of(context).style,
    config: config,
    buildInline: (nodes) => _anySpans(context, nodes, config),
    buildBlocks: (nodes) => config.getRich(
      TextSpan(
        children: _anySpans(
          context,
          nodes,
          config.copyWith(blocksRenderDirectly: false),
        ),
      ),
      ambientScaling: config.blocksRenderDirectly,
    ),
  );

  /// [nodes] as spans, whether they are blocks or inline content.
  static List<InlineSpan> _anySpans(
    BuildContext context,
    List<MdNode> nodes,
    GptMarkdownConfig config,
  ) => nodes.isNotEmpty && nodes.every(_isInline)
      ? _inlineSpans(context, nodes, config)
      : _blockSpans(context, nodes, config);

  /// An element inside a line: its inline builder, else its block builder's
  /// widget in the line, else its content in place.
  static InlineSpan _htmlInline(
    BuildContext context,
    MdCustomBlock node,
    HtmlElementData data,
    GptMarkdownConfig config,
  ) {
    final tag = config.htmlTags?[data.name];
    final inline = tag?.inlineBuilder;
    if (inline != null) {
      return inline(context, _htmlDetails(context, node, data, config));
    }
    final block = tag?.blockBuilder;
    if (block != null) {
      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: block(context, _htmlDetails(context, node, data, config)),
      );
    }
    if (config.markdownHtml[data.name]?.kind == HtmlTagKind.svg) {
      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: _svg(context, node, data, config),
      );
    }
    if (data.children.isEmpty) {
      return TextSpan(text: data.source, style: config.style);
    }
    return TextSpan(
      children: _inlineSpans(context, data.children, config),
      style: config.style,
    );
  }

  /// An `<svg>` element drawn as a picture, its `currentColor` the text's.
  static Widget _svg(
    BuildContext context,
    MdCustomBlock node,
    HtmlElementData data,
    GptMarkdownConfig config,
  ) => inlineSvg(
    attributes: data.attributes,
    markup: data.source,
    closed: node.closed,
    currentColor:
        config.style?.color ?? DefaultTextStyle.of(context).style.color,
    error: (context) => const CustomImageError(),
  );

  /// An element standing as a block: its block builder, else its content in
  /// place.
  static List<InlineSpan> _htmlBlock(
    BuildContext context,
    MdCustomBlock node,
    HtmlElementData data,
    GptMarkdownConfig config,
  ) {
    final builder = config.htmlTags?[data.name]?.blockBuilder;
    if (builder != null) {
      return [
        _blockSpan(builder(context, _htmlDetails(context, node, data, config))),
      ];
    }
    switch (config.markdownHtml[data.name]?.kind) {
      case HtmlTagKind.table:
        return _htmlTableSpans(context, data, config);
      case HtmlTagKind.svg:
        return [_blockSpan(_svg(context, node, data, config))];
      default:
        break;
    }
    if (data.children.isEmpty) {
      return data.source.trim().isEmpty
          ? const []
          : [TextSpan(text: data.source, style: config.style)];
    }
    return _blockSpans(context, data.children, config);
  }

  static String _plainText(List<MdNode> nodes) {
    final out = StringBuffer();
    for (final n in nodes) {
      switch (n) {
        case MdText(:final text):
          out.write(text);
        case MdInlineCode(:final text):
          out.write(text);
        case MdInlineLatex(:final tex):
          out.write(tex);
        case MdSourceTag(:final id):
          out.write(id);
        // An image's text is its alt, as a browser reads it — so a badge link
        // reports `build passing`, not an empty label.
        case MdImage(:final alt):
          out.write(alt);
        case MdFootnoteReference(:final number):
          out.write(number);
        case MdBold(:final children):
        case MdItalic(:final children):
        case MdStrike(:final children):
        case MdUnderline(:final children):
        case MdLink(:final children, url: _):
        case MdSuperscript(:final children):
        case MdSubscript(:final children):
        case MdHighlight(:final children):
          out.write(_plainText(children));
        case MdCustomBlock(:final HtmlElementData data):
          out.write(
            data.children.isEmpty ? data.source : _plainText(data.children),
          );
        default:
          break;
      }
    }
    return out.toString();
  }
}
