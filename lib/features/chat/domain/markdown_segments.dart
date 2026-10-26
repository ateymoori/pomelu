import 'markdown_chunks.dart';

/// One top-level piece of a reply. `gpt_markdown` knows nothing of
/// `<details>` or link cards, so the source is split first and each piece
/// goes to its own renderer.
sealed class MarkdownSegment {
  const MarkdownSegment();
}

/// Ordinary Markdown.
final class MarkdownTextSegment extends MarkdownSegment {
  const MarkdownTextSegment(this.text);

  final String text;
}

/// A `<details>` disclosure, collapsed behind [summary] until tapped.
final class MarkdownDetailsSegment extends MarkdownSegment {
  const MarkdownDetailsSegment({
    required this.summary,
    required this.body,
    this.open = false,
  });

  final String summary;
  final String body;

  /// The author wrote `<details open>`.
  final bool open;
}

/// A link alone on its line, shown as a card.
final class MarkdownLinkSegment extends MarkdownSegment {
  const MarkdownLinkSegment(this.target);

  final LinkTarget target;
}

/// A link lifted out of the Markdown for a card. YouTube gets a thumbnail and
/// a title without an API key; any other host shows its name and path.
class LinkTarget {
  const LinkTarget({required this.url, this.videoId, this.label});

  final String url;

  /// Set for a YouTube video.
  final String? videoId;

  /// Text of `[label](url)`, when the author wrote one.
  final String? label;

  bool get isVideo => videoId != null;

  /// `hqdefault` exists for every video; `maxresdefault` 404s on old ones.
  String? get thumbnailUrl => videoId == null
      ? null
      : 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  /// YouTube's public oEmbed document of the video (title, author).
  Uri? get oEmbedUri => videoId == null
      ? null
      : Uri.parse(
          'https://www.youtube.com/oembed'
          '?url=https://www.youtube.com/watch%3Fv%3D$videoId&format=json',
        );

  /// Host without `www.`.
  String get host {
    final h = Uri.tryParse(url)?.host ?? '';
    return h.startsWith('www.') ? h.substring(4) : h;
  }

  /// The author's text, else the last path segment, else the host.
  String get fallbackTitle {
    final given = label?.trim() ?? '';
    if (given.isNotEmpty) return given;
    // `pathSegments` are decoded already; decoding again throws on a `%`.
    final last = Uri.tryParse(url)?.pathSegments.where((s) => s.isNotEmpty);
    return last?.lastOrNull ?? (host.isEmpty ? url : host);
  }

  static final RegExp _videoId = RegExp(r'^[A-Za-z0-9_-]{6,20}$');

  /// [url] as a target; null unless it is an absolute http(s) link.
  static LinkTarget? parse(String url, {String? label}) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return null;
    }
    if (uri.host.isEmpty) return null;
    final host = uri.host.toLowerCase().replaceFirst('www.', '');
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final id = switch (host) {
      'youtu.be' => segments.firstOrNull,
      'youtube.com' ||
      'm.youtube.com' ||
      'music.youtube.com' ||
      'youtube-nocookie.com'
          when segments.isNotEmpty &&
              const {'embed', 'shorts', 'live', 'v'}.contains(segments.first) =>
        segments.length > 1 ? segments[1] : null,
      'youtube.com' ||
      'm.youtube.com' ||
      'music.youtube.com' ||
      'youtube-nocookie.com' => uri.queryParameters['v'],
      _ => null,
    };
    return LinkTarget(
      url: url.trim(),
      videoId: id != null && _videoId.hasMatch(id) ? id : null,
      label: label,
    );
  }
}

/// Splits Markdown into renderable segments.
abstract final class MarkdownSegments {
  static final RegExp _detailsOpen = RegExp(
    r'^\s*<details(\s[^>]*)?>\s*$',
    caseSensitive: false,
  );
  static final RegExp _detailsClose = RegExp(
    r'^\s*</details>\s*$',
    caseSensitive: false,
  );
  static final RegExp _summary = RegExp(
    r'<summary(?:\s[^>]*)?>(.*?)</summary>',
    caseSensitive: false,
    dotAll: true,
  );
  static final RegExp _tag = RegExp('<[^>]+>');

  static final RegExp _lonelyLink = RegExp(
    r'^\s*(?:\[([^\]]*)\]\(\s*(<?https?://[^\s)]+>?)\s*\)|<?(https?://\S+?)>?)\s*$',
  );

  /// Splits [source]; plain prose is one [MarkdownTextSegment].
  static List<MarkdownSegment> split(String source) {
    if (source.isEmpty) return const [];
    final lower = source.toLowerCase();
    if (!lower.contains('<details') && !lower.contains('http')) {
      return [MarkdownTextSegment(source)];
    }
    final lines = source.split('\n');
    final out = <MarkdownSegment>[];
    final buffer = StringBuffer();
    final fence = MarkdownFence();
    void flush() {
      final text = buffer.toString().trim();
      buffer.clear();
      if (text.isNotEmpty) out.add(MarkdownTextSegment(text));
    }

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      // Nothing inside a code fence is a disclosure or a card.
      if (fence.feed(line)) {
        buffer.writeln(line);
        continue;
      }
      final open = _detailsOpen.firstMatch(line);
      if (open != null) {
        final end = _matchingClose(lines, i);
        // A reply still streaming can end at `<details>`, with no body yet.
        final inner = end <= i + 1 ? '' : lines.sublist(i + 1, end).join('\n');
        flush();
        out.add(
          MarkdownDetailsSegment(
            summary:
                _summary
                    .firstMatch(inner)
                    ?.group(1)!
                    .replaceAll(_tag, '')
                    .trim() ??
                '',
            body: inner.replaceFirst(_summary, '').trim(),
            open: (open.group(1) ?? '').toLowerCase().contains('open'),
          ),
        );
        i = end;
        continue;
      }
      final link = _lonelyLink.firstMatch(line);
      final target = link == null
          ? null
          : LinkTarget.parse(
              (link.group(2) ?? link.group(3) ?? '').replaceAll(
                RegExp(r'^<|>$'),
                '',
              ),
              label: link.group(1),
            );
      if (target != null) {
        flush();
        out.add(MarkdownLinkSegment(target));
        continue;
      }
      buffer.writeln(line);
    }
    flush();
    return out.isEmpty ? [MarkdownTextSegment(source)] : out;
  }

  static int _matchingClose(List<String> lines, int from) {
    var depth = 0;
    for (var i = from; i < lines.length; i++) {
      if (_detailsOpen.hasMatch(lines[i])) depth++;
      if (_detailsClose.hasMatch(lines[i]) && --depth == 0) return i;
    }
    return lines.length;
  }

  static final RegExp _taskItem = RegExp(
    r'^(\s*)(?:[-*+]|\d+[.)])\s+\[([ xX])\]\s+(\S.*)$',
  );

  /// `- [ ] task` as `[ ] task`: `gpt_markdown` only takes a checkbox at the
  /// start of the line, and every model writes it as a list item. Code is
  /// left alone.
  static String normalizeTaskLists(String source) {
    if (!source.contains(RegExp(r'\[[ xX]\]'))) return source;
    final fence = MarkdownFence();
    String fix(String line) {
      final m = fence.feed(line) ? null : _taskItem.firstMatch(line);
      if (m == null) return line;
      return '${m.group(1)}[${m.group(2) == ' ' ? ' ' : 'x'}] ${m.group(3)}';
    }

    return source.split('\n').map(fix).join('\n');
  }
}
