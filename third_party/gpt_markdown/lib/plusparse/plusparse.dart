/// plusparse — a fast, hand-written Markdown + LaTeX parser, fully rewritten
/// in pure Dart and built into gpt_markdown (originally a Rust
/// flutter_rust_bridge plugin).
///
/// Single-pass, regex-free, and error-tolerant: it never throws on malformed
/// or partial (streaming) input, which makes it suitable for re-parsing
/// streaming LLM output on every token. No initialisation or native library
/// loading is needed — parsing is synchronous pure Dart.
///
/// Usage:
/// ```dart
/// final MdDocument doc = Plusparse.parse('# Hello **world**');
/// ```
library;

import 'ast.dart';
import 'block_parser.dart';
import 'block_syntax.dart';
import 'definitions.dart';
import 'html_tags.dart';
export 'block_syntax.dart';

export 'ast.dart';
export 'definitions.dart' show MarkdownDefinitions, MdLinkDefinition;
export 'html_tags.dart'
    show
        HtmlTagKind,
        HtmlTagSyntax,
        MarkdownHtml,
        HtmlElementData,
        htmlElementType;
export 'stream_splitter.dart';

/// Public entry point for the plusparse Markdown parser.
class Plusparse {
  Plusparse._();

  /// Parses [markdown] into a structured [MdDocument] tree.
  ///
  /// Synchronous and fast — suitable for re-parsing streaming LLM output.
  /// Set [useDollarSignsForLatex] to also treat `$ … $` / `$$ … $$` as LaTeX
  /// in addition to the always-on `\( … \)` / `\[ … \]` forms (mirrors
  /// gpt_markdown's option).
  ///
  /// Link reference and footnote definitions are collected from [markdown]
  /// itself. When parsing a document in pieces, collect them once from the
  /// whole of it with [MarkdownDefinitions.collect] and pass them as
  /// [definitions], so a reference in one piece finds a definition in another.
  ///
  /// [html] decides which HTML tags are understood and what each becomes;
  /// [MarkdownHtml.defaults] when null, and [MarkdownHtml.none] for no HTML
  /// at all.
  static MdDocument parse(
    String markdown, {
    bool useDollarSignsForLatex = false,
    MarkdownBlockRegistry? blockRegistry,
    MarkdownDefinitions? definitions,
    MarkdownHtml? html,
  }) {
    return parseDocument(
      markdown,
      useDollarSignsForLatex,
      blockRegistry,
      definitions,
      html,
    );
  }
}
