/// Finding a safe place to cut streaming Markdown in two.
library;

import '../plusparse/html_tags.dart';
import '../plusparse/scanner.dart';

/// The offset of the last blank line that is safe to split at, or 0 when the
/// whole document has to stay together.
///
/// Everything before the split is settled: it can be rendered once and cached,
/// because appending to the end of a document cannot change it. Everything
/// after is the live tail, and is the only part re-rendered as text arrives.
/// That is what keeps the per-token cost proportional to the tail rather than
/// to the whole reply.
///
/// A blank line inside a fenced code block or block LaTeX is **not** a safe
/// split: cutting there would leave the prefix holding an unterminated
/// ``` fence, which renders as literal text until the closing fence arrives —
/// a visible flicker mid-stream. Those regions are skipped.
///
/// The last construct is never settled either, even when it is followed by a
/// blank line, because the next token may still extend it — a list gaining
/// another item, a paragraph another sentence.
///
/// [html] is the HTML the parse understands: a blank line inside an HTML block
/// that spans lines — `<pre>`, `<blockquote>` — is not a split either.
int settledSplitOffset(String source, {MarkdownHtml? html}) {
  FenceOpen? fence;
  final htmlBlocks = HtmlBlockTracker(html ?? MarkdownHtml.defaults);
  var inLatex = false;
  var inComment = false;

  // Offsets of blank lines outside fences and block maths.
  final candidates = <int>[];

  // The lines since the last candidate, for [continuesAfterBlank].
  final block = <String>[];

  /// The first non-blank line after offset [from], or null.
  String? nextContentLine(int from) {
    var start = from;
    while (start < source.length) {
      var end = source.indexOf('\n', start);
      if (end == -1) {
        end = source.length;
      }
      final candidate = source.substring(start, end);
      if (candidate.trim().isNotEmpty) {
        return candidate;
      }
      start = end + 1;
    }
    return null;
  }

  var lineStart = 0;
  var index = 0;
  while (index <= source.length) {
    final atEnd = index == source.length;
    if (!atEnd && source.codeUnitAt(index) != 0x0A) {
      index++;
      continue;
    }

    final line = source.substring(lineStart, index);
    final trimmed = line.trimLeft();
    final inHtmlBlock = htmlBlocks.isOpen;

    final open = fence;
    if (open != null) {
      if (isFenceClose(line, open)) {
        fence = null;
      }
    } else if (inLatex) {
      if (trimmed.contains(r'\]')) {
        inLatex = false;
      }
    } else if (inComment) {
      if (trimmed.contains('-->')) {
        inComment = false;
      }
    } else if (inHtmlBlock) {
      htmlBlocks.add(line);
    } else if (fenceOpen(trimmed) != null) {
      fence = fenceOpen(trimmed);
    } else if (trimmed.startsWith(r'\[') && !trimmed.contains(r'\]')) {
      inLatex = true;
    } else if (startsHtmlComment(trimmed) &&
        !trimmed.substring(4).contains('-->')) {
      inComment = true;
    } else if (!atEnd && trimmed.isEmpty && lineStart > 0) {
      // A blank line inside a list item — before the item's second paragraph
      // or its code block — is not a block boundary.
      final next = nextContentLine(index + 1);
      if (next != null && continuesAfterBlank(block, next)) {
        block.add(line);
        index++;
        lineStart = index;
        continue;
      }
      // The split goes after the blank line, so the tail starts on real
      // content rather than with leading whitespace.
      //
      // `!atEnd` matters: a source ending in a newline makes the final
      // iteration see an empty last line, and counting it as a blank line
      // would add a candidate past the end of the string. That extra entry
      // pushes the real last candidate into the settled half, so the split
      // runs one construct too far ahead and then jumps *backwards* as soon
      // as the next character arrives — content settles, then unsettles.
      candidates.add(index + 1);
      block.clear();
    }
    if (trimmed.isNotEmpty) {
      block.add(line);
      if (fence == null && !inLatex && !inComment && !inHtmlBlock) {
        htmlBlocks.add(line);
      }
    }

    if (atEnd) {
      break;
    }
    index++;
    lineStart = index;
  }

  // Never settle the final construct: the next token may extend it.
  if (candidates.length < 2) {
    return 0;
  }
  return candidates[candidates.length - 2];
}
