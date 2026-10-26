import 'package:flutter/widgets.dart';

import '../plusparse/ast.dart';
import '../plusparse/html_tags.dart';
import 'markdown_config.dart';

/// Builds an HTML element that sits inside a line of text — what
/// [HtmlTag.inline] renders with.
///
/// Return any span: a [TextSpan] around [HtmlElementDetails.children] to
/// restyle the content, or a [WidgetSpan] for a widget of your own.
typedef HtmlInlineBuilder =
    InlineSpan Function(BuildContext context, HtmlElementDetails element);

/// Builds an HTML element that stands as a block of its own — what
/// [HtmlTag.block] renders with. [HtmlElementDetails.child] is the Markdown
/// inside it, rendered.
typedef HtmlBlockBuilder =
    Widget Function(BuildContext context, HtmlElementDetails element);

/// What `GptMarkdown` does with one HTML tag.
///
/// Out of the box, common tags map onto Markdown — `<b>` is bold, `<br>` a
/// line break, `<a href>` a link — and the rest stay text (the full table is
/// [MarkdownHtml.defaults]). Override any of them, or add your own, with
/// `GptMarkdown.htmlTags`:
///
/// ```dart
/// GptMarkdown(
///   reply,
///   htmlTags: {
///     // A tag of your own, rendered by you.
///     'sup': HtmlTag.inline(
///       (context, element) => WidgetSpan(
///         alignment: PlaceholderAlignment.top,
///         child: Text.rich(
///           TextSpan(children: element.children),
///           textScaler: const TextScaler.linear(0.7),
///         ),
///       ),
///     ),
///     // A block of your own, wrapping the Markdown inside it.
///     'details': HtmlTag.block(
///       (context, element) => ExpansionTile(
///         title: Text(element['title'] ?? 'Details'),
///         children: [element.child],
///       ),
///     ),
///     // A built-in meaning for another tag.
///     'mark': HtmlTag.bold,
///     // Shown as written.
///     'u': null,
///   },
/// )
/// ```
class HtmlTag {
  const HtmlTag._(this.syntax) : inlineBuilder = null, blockBuilder = null;

  /// An element kept in the tree and rendered by [builder] wherever it
  /// appears inside a line. Without a builder its content renders in place.
  ///
  /// With [rawContent] the content is not parsed as Markdown: the builder
  /// reads it from [HtmlElementDetails.source].
  const HtmlTag.inline([HtmlInlineBuilder? builder, bool rawContent = false])
    : syntax = rawContent
          ? const HtmlTagSyntax(HtmlTagKind.inlineElement, rawContent: true)
          : HtmlTagSyntax.inlineElement,
      inlineBuilder = builder,
      blockBuilder = null;

  /// An element kept in the tree. When its opening tag starts a block, the
  /// lines up to its closing tag are its content, rendered by [builder];
  /// inside a line of text it is rendered by [inline] when given, and as
  /// [builder]'s widget otherwise. Without a builder its content renders in
  /// place.
  ///
  /// While a reply streams, a block element renders before its closing tag
  /// arrives; [HtmlElementDetails.closed] tells you which.
  const HtmlTag.block([
    HtmlBlockBuilder? builder,
    HtmlInlineBuilder? inline,
    bool rawContent = false,
  ]) : syntax = rawContent
           ? const HtmlTagSyntax(HtmlTagKind.blockElement, rawContent: true)
           : HtmlTagSyntax.blockElement,
       blockBuilder = builder,
       inlineBuilder = inline;

  /// The parser's rule for the tag.
  final HtmlTagSyntax syntax;

  /// Renders the element inside a line of text.
  final HtmlInlineBuilder? inlineBuilder;

  /// Renders the element as a block.
  final HtmlBlockBuilder? blockBuilder;

  /// Bold content: `<b>`, `<strong>`.
  static const bold = HtmlTag._(HtmlTagSyntax.bold);

  /// Italic content: `<i>`, `<em>`.
  static const italic = HtmlTag._(HtmlTagSyntax.italic);

  /// Struck-through content: `<s>`, `<del>`.
  static const strike = HtmlTag._(HtmlTagSyntax.strike);

  /// Underlined content: `<u>`, `<ins>`.
  static const underline = HtmlTag._(HtmlTagSyntax.underline);

  /// Inline code of the raw content: `<code>`, `<kbd>`.
  static const code = HtmlTag._(HtmlTagSyntax.code);

  /// Superscript: `<sup>`.
  static const superscript = HtmlTag._(HtmlTagSyntax.superscript);

  /// Subscript: `<sub>`.
  static const subscript = HtmlTag._(HtmlTagSyntax.subscript);

  /// Highlighted: `<mark>`.
  static const highlight = HtmlTag._(HtmlTagSyntax.highlight);

  /// A table from `<tr>`, `<th>`, `<td>` — `colspan` and `rowspan` merge
  /// cells: `<table>`.
  static const table = HtmlTag._(HtmlTagSyntax.table);

  /// A bulleted list of `<li>` items: `<ul>`.
  static const unorderedList = HtmlTag._(HtmlTagSyntax.unorderedList);

  /// A numbered list of `<li>` items: `<ol>`.
  static const orderedList = HtmlTag._(HtmlTagSyntax.orderedList);

  /// A checkbox: `<input type="checkbox">`.
  static const checkbox = HtmlTag._(HtmlTagSyntax.checkbox);

  /// A line break: `<br>`.
  static const lineBreak = HtmlTag._(HtmlTagSyntax.lineBreak);

  /// An image from `src`, `alt`, `title`, `width`, `height`: `<img>`.
  static const image = HtmlTag._(HtmlTagSyntax.image);

  /// A link from `href` and `title`: `<a>`.
  static const link = HtmlTag._(HtmlTagSyntax.link);

  /// A horizontal rule, on a line of its own: `<hr>`.
  static const rule = HtmlTag._(HtmlTagSyntax.rule);

  /// A heading, its level the digit in the name: `<h1>`…`<h6>`.
  static const heading = HtmlTag._(HtmlTagSyntax.heading);

  /// A block quote of the Markdown inside: `<blockquote>`.
  static const quote = HtmlTag._(HtmlTagSyntax.quote);

  /// An SVG drawing of the raw markup: `<svg>`.
  static const svg = HtmlTag._(HtmlTagSyntax.svg);

  /// A code block of the raw content: `<pre>`.
  static const codeBlock = HtmlTag._(HtmlTagSyntax.codeBlock);

  /// Hidden with its content, when closed: `<script>`, `<style>`.
  static const hidden = HtmlTag._(HtmlTagSyntax.hidden);

  /// The tag is dropped and its content renders in place: `<span>`.
  static const content = HtmlTag._(HtmlTagSyntax.inlineContent);

  /// On lines of its own the tag is dropped, so the Markdown inside renders:
  /// `<div>`, `<details>`.
  static const wrapper = HtmlTag._(HtmlTagSyntax.blockContent);
}

/// One HTML element, handed to an [HtmlInlineBuilder] or [HtmlBlockBuilder].
class HtmlElementDetails {
  HtmlElementDetails({
    required this.node,
    required this.data,
    required this.style,
    required this.config,
    required this._buildInline,
    required this._buildBlocks,
  });

  /// The node as parsed.
  final MdCustomBlock node;

  /// The element's tag, attributes and parsed content.
  final HtmlElementData data;

  /// The text style where the element sits.
  final TextStyle style;

  /// The configuration it renders under.
  final GptMarkdownConfig config;

  final List<InlineSpan> Function(List<MdNode> nodes) _buildInline;
  final Widget Function(List<MdNode> nodes) _buildBlocks;

  /// The tag's name, lower case.
  String get name => data.name;

  /// Attribute names (lower case) to values, references decoded.
  Map<String, String> get attributes => data.attributes;

  /// The value of [attribute], or null.
  String? operator [](String attribute) => data.attributes[attribute];

  /// The content as written, between the tags.
  String get source => data.source;

  /// Whether the element stands as a block of its own.
  bool get block => data.block;

  /// False while a block element is still streaming in and its closing tag
  /// has not arrived.
  bool get closed => node.closed;

  /// The parsed content: inline nodes for an inline element, blocks for a
  /// block one.
  List<MdNode> get nodes => data.children;

  /// The content as spans, styled like the text around it. For a block
  /// element, its blocks laid out in one paragraph.
  late final List<InlineSpan> children = _buildInline(data.children);

  /// The content as a widget, rendered the way `GptMarkdown` renders it.
  late final Widget child = _buildBlocks(data.children);

  /// [nodes] — any part of [nodes] — as spans.
  List<InlineSpan> buildInline(List<MdNode> nodes) => _buildInline(nodes);

  /// [nodes] — any part of [nodes] — as a widget.
  Widget buildBlocks(List<MdNode> nodes) => _buildBlocks(nodes);

  /// The first element named [name] in the content, at any depth — a
  /// `<summary>` inside `<details>`, say — or null. Only tags kept as
  /// elements ([HtmlTag.inline], [HtmlTag.block]) can be found.
  HtmlElementData? find(String name) => _find(data.children, name);

  /// The first element named [name] in the content, and the content without
  /// it — for a builder that renders that part separately, like the
  /// `<summary>` of a `<details>`:
  ///
  /// ```dart
  /// 'summary': const HtmlTag.block(),
  /// 'details': HtmlTag.block((context, element) {
  ///   final (:found, :rest) = element.take('summary');
  ///   return ExpansionTile(
  ///     title: found == null
  ///         ? const Text('Details')
  ///         : Text.rich(TextSpan(children: element.buildInline(found.children))),
  ///     children: [element.buildBlocks(rest)],
  ///   );
  /// }),
  /// ```
  ///
  /// A `<summary>` on a line of its own is a block, so its children are
  /// blocks; [buildBlocks] renders either kind.
  ({HtmlElementData? found, List<MdNode> rest}) take(String name) {
    HtmlElementData? found;
    List<MdNode> without(List<MdNode> nodes) {
      final out = <MdNode>[];
      for (final node in nodes) {
        if (found == null) {
          if (node case MdCustomBlock(
            :final HtmlElementData data,
          ) when data.name == name) {
            found = data;
            continue;
          }
          if (node is MdParagraph) {
            final children = without(node.children);
            if (children.isNotEmpty) {
              out.add(MdParagraph(children: children));
            }
            continue;
          }
        }
        out.add(node);
      }
      return out;
    }

    final rest = without(data.children);
    return (found: found, rest: rest);
  }

  static HtmlElementData? _find(List<MdNode> nodes, String name) {
    for (final node in nodes) {
      final found = switch (node) {
        MdCustomBlock(:final HtmlElementData data) =>
          data.name == name ? data : _find(data.children, name),
        MdParagraph(:final children) ||
        MdHeading(:final children) ||
        MdBold(:final children) ||
        MdItalic(:final children) ||
        MdStrike(:final children) ||
        MdUnderline(:final children) ||
        MdSuperscript(:final children) ||
        MdSubscript(:final children) ||
        MdHighlight(:final children) ||
        MdLink(:final children) ||
        MdBlockQuote(:final children) => _find(children, name),
        _ => null,
      };
      if (found != null) {
        return found;
      }
    }
    return null;
  }
}
