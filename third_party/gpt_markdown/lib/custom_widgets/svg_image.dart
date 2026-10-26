import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

/// Whether [url] names an SVG by itself: a path ending `.svg`, or a
/// `data:image/svg+xml` URL.
///
/// Many SVGs say nothing in their URL — `https://img.shields.io/pub/v/x` is
/// one — so an image that fails to decode as a bitmap is tried as an SVG too.
bool isSvgUrl(String url) {
  final lower = url.toLowerCase();
  if (lower.startsWith('data:')) {
    return lower.startsWith('data:image/svg+xml');
  }
  var end = lower.length;
  final query = lower.indexOf('?');
  if (query != -1) end = query;
  final fragment = lower.indexOf('#');
  if (fragment != -1 && fragment < end) end = fragment;
  return lower.substring(0, end).endsWith('.svg');
}

/// Whether [bytes] start like an SVG document: an `<svg` element near the
/// start, after any XML declaration, doctype or comment.
///
/// Checked before the bytes reach the SVG decoder, which reports bad input
/// as an uncaught error on top of its error widget.
bool looksLikeSvg(Uint8List bytes) {
  final head = String.fromCharCodes(
    bytes.length > 2048 ? bytes.sublist(0, 2048) : bytes,
  ).toLowerCase();
  return head.contains('<svg');
}

/// [bytes] rewritten around two gaps in the SVG compiler under `flutter_svg`,
/// both of which every shields.io badge runs into. Anything else is left as
/// written, and rewritten bytes are kept, so a rebuild does not parse again.
///
/// * **An embedded SVG image** — `<image href="data:image/svg+xml;…">`, how a
///   badge carries its `logo=` icon — is dropped by the compiler, which only
///   decodes bitmaps there. It is replaced with the embedded SVG's own
///   content, in a group placed and scaled the way its `viewBox` would be.
/// * **Text in a uniformly scaled group** — `font-size="110"` inside
///   `scale(.1)` — has its position scaled by the compiler but not its size,
///   so it came out ten times too large. A group holding only text has the
///   scale folded into the text itself: positions, font size and spacing
///   multiplied, and the transform removed, so the result does not depend on
///   the compiler's handling either way.
Uint8List normalizeSvgText(Uint8List bytes) {
  final cached = _normalized[bytes];
  if (cached != null) {
    return cached;
  }
  final result = _normalize(bytes);
  _normalized[bytes] = result;
  return result;
}

final Expando<Uint8List> _normalized = Expando();

final RegExp _uniformScale = RegExp(r'^\s*scale\(\s*([0-9.eE+-]+)\s*\)\s*$');

Uint8List _normalize(Uint8List bytes) {
  final String source;
  try {
    source = utf8.decode(bytes);
  } on FormatException {
    return bytes;
  }
  final embedsSvg = source.contains('image/svg+xml');
  final scalesText = source.contains('scale(') && source.contains('<text');
  if (!embedsSvg && !scalesText) {
    return bytes;
  }
  final XmlDocument document;
  try {
    document = XmlDocument.parse(source);
  } on XmlException {
    return bytes;
  }
  var changed = embedsSvg && _inlineSvgImages(document, 0);
  changed = _foldTextScale(document) || changed;
  return changed
      ? Uint8List.fromList(utf8.encode(document.toXmlString()))
      : bytes;
}

/// Replaces each `<image>` showing a `data:image/svg+xml` with that SVG's
/// content. Returns whether anything changed. [depth] bounds SVGs embedded
/// in embedded SVGs.
bool _inlineSvgImages(XmlNode root, int depth) {
  if (depth > 3) {
    return false;
  }
  var changed = false;
  for (final image
      in root.descendantElements
          .where((e) => e.name.local == 'image')
          .toList()) {
    final href = image.getAttribute('href') ?? image.getAttribute('xlink:href');
    if (href == null || !href.toLowerCase().startsWith('data:image/svg+xml')) {
      continue;
    }
    final XmlElement inner;
    try {
      inner = XmlDocument.parse(_dataUrlText(href)).rootElement;
    } on FormatException {
      continue;
    } on XmlException {
      continue;
    }
    if (inner.name.local != 'svg') {
      continue;
    }
    _inlineSvgImages(inner, depth + 1);
    _prefixIds(inner, 'gm$depth-${_inlined++}-');

    double attr(XmlElement e, String name, double fallback) =>
        double.tryParse(
          (e.getAttribute(name) ?? '').replaceAll(RegExp(r'px$'), ''),
        ) ??
        fallback;
    final x = attr(image, 'x', 0);
    final y = attr(image, 'y', 0);
    final width = attr(image, 'width', attr(inner, 'width', 0));
    final height = attr(image, 'height', attr(inner, 'height', 0));
    final viewBox = (inner.getAttribute('viewBox') ?? '')
        .trim()
        .split(RegExp(r'[\s,]+'))
        .map(double.tryParse)
        .toList();
    final double vx, vy, vw, vh;
    if (viewBox.length == 4 && viewBox.every((v) => v != null)) {
      vx = viewBox[0]!;
      vy = viewBox[1]!;
      vw = viewBox[2]!;
      vh = viewBox[3]!;
    } else {
      vx = 0;
      vy = 0;
      vw = attr(inner, 'width', width);
      vh = attr(inner, 'height', height);
    }
    if (width <= 0 || height <= 0 || vw <= 0 || vh <= 0) {
      continue;
    }
    // The viewBox fitted into the image's box, centred — the default
    // `preserveAspectRatio` — or stretched when it says `none`.
    final String transform;
    final aspect =
        image.getAttribute('preserveAspectRatio') ??
        inner.getAttribute('preserveAspectRatio') ??
        '';
    if (aspect.trim() == 'none') {
      transform =
          'translate(${_number(x - vx * width / vw)} ${_number(y - vy * height / vh)}) '
          'scale(${_number(width / vw)} ${_number(height / vh)})';
    } else {
      final scale = width / vw < height / vh ? width / vw : height / vh;
      final tx = x + (width - vw * scale) / 2 - vx * scale;
      final ty = y + (height - vh * scale) / 2 - vy * scale;
      transform =
          'translate(${_number(tx)} ${_number(ty)}) scale(${_number(scale)})';
    }

    const skip = {
      'width',
      'height',
      'x',
      'y',
      'viewBox',
      'preserveAspectRatio',
      'role',
      'version',
      'id',
      'xmlns',
      'xmlns:xlink',
      'baseProfile',
    };
    final group = XmlDocument.parse('<g/>').rootElement.copy()
      ..setAttribute('transform', transform);
    for (final a in inner.attributes) {
      final name = a.name.qualified;
      if (!skip.contains(name) && a.name.prefix != 'xmlns') {
        group.setAttribute(name, a.value);
      }
    }
    final opacity = image.getAttribute('opacity');
    if (opacity != null) {
      group.setAttribute('opacity', opacity);
    }
    for (final child in inner.childElements) {
      if (!const {'title', 'desc', 'metadata'}.contains(child.name.local)) {
        group.children.add(child.copy());
      }
    }
    image.replace(group);
    changed = true;
  }
  return changed;
}

int _inlined = 0;

/// The text a `data:` URL carries: base64 when it says so, percent-decoded
/// otherwise. Not `UriData.parse`, which rejects the common but non-standard
/// `data:image/svg+xml;utf8,<svg …>`.
String _dataUrlText(String href) {
  final comma = href.indexOf(',');
  if (comma == -1) {
    throw const FormatException('no data');
  }
  final header = href.substring(0, comma).toLowerCase();
  final payload = href.substring(comma + 1);
  if (header.endsWith(';base64')) {
    return utf8.decode(base64.decode(payload.replaceAll(RegExp(r'\s'), '')));
  }
  try {
    return Uri.decodeComponent(payload);
  } on ArgumentError {
    return payload;
  }
}

/// Gives every id in [root] a [prefix], and its references with it, so an
/// inlined SVG's ids cannot collide with its host's.
void _prefixIds(XmlElement root, String prefix) {
  final ids = <String>{
    for (final e in [root, ...root.descendantElements]) ?e.getAttribute('id'),
  };
  if (ids.isEmpty) {
    return;
  }
  for (final e in [root, ...root.descendantElements]) {
    for (final a in e.attributes) {
      var value = a.value;
      if (a.name.local == 'id' && ids.contains(value)) {
        a.value = '$prefix$value';
        continue;
      }
      for (final id in ids) {
        value = value
            .replaceAll('url(#$id)', 'url(#$prefix$id)')
            .replaceAll(RegExp('^#${RegExp.escape(id)}\$'), '#$prefix$id');
      }
      a.value = value;
    }
  }
}

/// Folds each text-only `scale(s)` group into its text. Returns whether
/// anything changed.
bool _foldTextScale(XmlDocument document) {
  var changed = false;
  for (final group in document.findAllElements('g').toList()) {
    final match = _uniformScale.firstMatch(
      group.getAttribute('transform') ?? '',
    );
    if (match == null) {
      continue;
    }
    final scale = double.tryParse(match[1]!);
    if (scale == null || scale <= 0) {
      continue;
    }
    // Only text — directly, or in plain groups of its own — so nothing but
    // text depends on the transform being gone.
    final inside = group.descendantElements.toList();
    const textOnly = {'text', 'tspan', 'title', 'desc', 'g'};
    if (!inside.any((e) => e.name.local == 'text') ||
        inside.any(
          (e) =>
              !textOnly.contains(e.name.local) ||
              (e.name.local == 'g' && e.getAttribute('transform') != null),
        )) {
      continue;
    }
    for (final text in inside.where((e) => e.name.local == 'text')) {
      for (final element in [text, ...text.findAllElements('tspan')]) {
        for (final name in const ['x', 'y', 'dx', 'dy', 'textLength']) {
          final value = element.getAttribute(name);
          if (value != null) {
            element.setAttribute(name, _scaleNumbers(value, scale));
          }
        }
      }
      final size = _inheritedFontSize(text);
      if (size != null) {
        text.setAttribute('font-size', _number(size * scale));
      }
    }
    group.removeAttribute('transform');
    changed = true;
  }
  return changed;
}

/// The font size [element] inherits, from itself or the nearest ancestor
/// setting one in plain user units.
double? _inheritedFontSize(XmlElement element) {
  XmlNode? node = element;
  while (node is XmlElement) {
    final size = double.tryParse(node.getAttribute('font-size') ?? '');
    if (size != null) {
      return size;
    }
    node = node.parent;
  }
  return null;
}

String _scaleNumbers(String value, double scale) => value.replaceAllMapped(
  RegExp(r'-?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?'),
  (m) => _number(double.parse(m[0]!) * scale),
);

String _number(double value) {
  final rounded = double.parse(value.toStringAsFixed(4));
  return rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toString();
}

/// An SVG image from the network.
///
/// The bytes are fetched once per URL and kept (the 64 most recent URLs), so
/// a streaming reply, which rebuilds constantly, does not download the image
/// again on every frame. A failed download, or a response that is not an
/// SVG, shows [error].
class NetworkSvg extends StatefulWidget {
  const NetworkSvg(
    this.url, {
    super.key,
    this.width,
    this.height,
    required this.fit,
    required this.loading,
    required this.error,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final WidgetBuilder loading;
  final WidgetBuilder error;

  static final LinkedHashMap<String, Future<Uint8List?>> _cache =
      LinkedHashMap();
  static const int _cacheEntries = 64;

  static Future<Uint8List?> _fetch(String url) {
    final cached = _cache.remove(url);
    if (cached != null) {
      _cache[url] = cached;
      return cached;
    }
    final future = () async {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode < 200 || response.statusCode >= 300) {
          return null;
        }
        final bytes = response.bodyBytes;
        return looksLikeSvg(bytes) ? normalizeSvgText(bytes) : null;
      } catch (_) {
        return null;
      }
    }();
    _cache[url] = future;
    while (_cache.length > _cacheEntries) {
      _cache.remove(_cache.keys.first);
    }
    return future;
  }

  @override
  State<NetworkSvg> createState() => _NetworkSvgState();
}

class _NetworkSvgState extends State<NetworkSvg> {
  late Future<Uint8List?> _bytes = NetworkSvg._fetch(widget.url);

  @override
  void didUpdateWidget(NetworkSvg oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _bytes = NetworkSvg._fetch(widget.url);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: _bytes,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return widget.loading(context);
      }
      final bytes = snapshot.data;
      if (bytes == null) {
        return widget.error(context);
      }
      return memorySvg(
        bytes,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        error: widget.error,
      );
    },
  );
}

/// An SVG image from bytes — a `data:` URL's, or a download's.
Widget memorySvg(
  Uint8List bytes, {
  double? width,
  double? height,
  required BoxFit fit,
  required WidgetBuilder error,
}) => !looksLikeSvg(bytes)
    ? Builder(builder: error)
    : SvgPicture.memory(
        normalizeSvgText(bytes),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, _, _) => error(context),
      );

/// Largest inline `<svg>` drawn, in characters of markup. Past it the error
/// box shows instead, so one runaway reply cannot stall a frame parsing
/// megabytes of path data.
const int maxInlineSvgLength = 200000;

/// The size a browser gives an `<svg>` that states none.
const Size _defaultSvgSize = Size(300, 150);

/// An inline `<svg>` element — its [attributes] and the [markup] between its
/// tags — drawn as a picture.
///
/// While [closed] is false the element is still streaming in, and its markup
/// changes on every frame; parsing each version would fail and cost a parse
/// per frame, so only a box of its stated size shows until it is complete.
///
/// It is as wide as `width` says and as tall as `height` says. With one of
/// them, or none, the `viewBox` gives the proportions, and a drawing with
/// neither is 300 by 150, as in a browser. It never grows past the width it
/// is given. `fill="currentColor"` takes [currentColor], so an icon follows
/// the text around it. Markup that does not parse, or is longer than
/// [maxInlineSvgLength], shows [error].
///
/// Parsed drawings are cached by their markup (flutter_svg's cache), so a
/// rebuild or a scroll draws without parsing again. Nothing is fetched: an
/// `<image>` in the drawing shows only when it is embedded as a `data:` URL.
Widget inlineSvg({
  required Map<String, String> attributes,
  required String markup,
  required bool closed,
  required WidgetBuilder error,
  Color? currentColor,
}) {
  final size = _svgSize(attributes);
  if (!closed) {
    return _SvgBox(size: size, child: const SizedBox.expand());
  }
  if (markup.length > maxInlineSvgLength) {
    return _SvgBox(
      size: size,
      child: Builder(builder: error),
    );
  }
  final label = attributes['aria-label'];
  return _SvgBox(
    size: size,
    child: SvgPicture.string(
      _normalizedSvg(_svgDocument(attributes, markup)),
      fit: BoxFit.contain,
      theme: currentColor == null
          ? const SvgTheme()
          : SvgTheme(currentColor: currentColor),
      semanticsLabel: label,
      excludeFromSemantics: label == null,
      errorBuilder: (context, _, _) => error(context),
    ),
  );
}

/// [size], shrunk to the width available with its proportions kept.
class _SvgBox extends StatelessWidget {
  const _SvgBox({required this.size, required this.child});

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: size.width),
    child: AspectRatio(aspectRatio: size.width / size.height, child: child),
  );
}

/// The element as a document of its own: its tag rebuilt from [attributes],
/// with the SVG namespace added when it was left out.
String _svgDocument(Map<String, String> attributes, String markup) {
  final out = StringBuffer('<svg');
  if (!attributes.containsKey('xmlns')) {
    out.write(' xmlns="http://www.w3.org/2000/svg"');
  }
  for (final MapEntry(:key, :value) in attributes.entries) {
    out
      ..write(' ')
      ..write(_svgAttributeNames[key] ?? key)
      ..write('="')
      ..write(
        value
            .replaceAll('&', '&amp;')
            .replaceAll('"', '&quot;')
            .replaceAll('<', '&lt;'),
      )
      ..write('"');
  }
  out
    ..write('>')
    ..write(markup)
    ..write('</svg>');
  return out.toString();
}

/// The HTML scanner lower-cases attribute names; SVG's are case-sensitive.
/// The ones a root `<svg>` carries, back in their own case.
const Map<String, String> _svgAttributeNames = {
  'viewbox': 'viewBox',
  'preserveaspectratio': 'preserveAspectRatio',
  'baseprofile': 'baseProfile',
};

/// [normalizeSvgText] for a document as text, remembered for the last few
/// documents: the same drawing rebuilds with an equal string, not the same
/// bytes, so the byte-keyed cache would miss.
String _normalizedSvg(String document) {
  final cached = _normalizedDocuments.remove(document);
  if (cached != null) {
    _normalizedDocuments[document] = cached;
    return cached;
  }
  final bytes = Uint8List.fromList(utf8.encode(document));
  final normalized = normalizeSvgText(bytes);
  final result = identical(normalized, bytes)
      ? document
      : utf8.decode(normalized);
  _normalizedDocuments[document] = result;
  while (_normalizedDocuments.length > 32) {
    _normalizedDocuments.remove(_normalizedDocuments.keys.first);
  }
  return result;
}

final LinkedHashMap<String, String> _normalizedDocuments =
    LinkedHashMap<String, String>();

/// The size the element states, filled in from its `viewBox`.
Size _svgSize(Map<String, String> attributes) {
  final width = _svgLength(attributes['width']);
  final height = _svgLength(attributes['height']);
  final box = (attributes['viewbox'] ?? '')
      .trim()
      .split(RegExp(r'[\s,]+'))
      .map(double.tryParse)
      .toList();
  final boxSize =
      box.length == 4 &&
          box[2] != null &&
          box[3] != null &&
          box[2]! > 0 &&
          box[3]! > 0
      ? Size(box[2]!, box[3]!)
      : null;
  if (width != null && height != null) {
    return Size(width, height);
  }
  if (boxSize != null) {
    if (width != null) {
      return Size(width, width * boxSize.height / boxSize.width);
    }
    if (height != null) {
      return Size(height * boxSize.width / boxSize.height, height);
    }
    return boxSize;
  }
  return Size(width ?? _defaultSvgSize.width, height ?? _defaultSvgSize.height);
}

/// A length in pixels: `24` or `24px`. Percentages and other units are left
/// to the viewBox.
double? _svgLength(String? value) {
  if (value == null) {
    return null;
  }
  var v = value.trim();
  if (v.endsWith('px')) {
    v = v.substring(0, v.length - 2).trim();
  }
  final number = double.tryParse(v);
  return number != null && number > 0 && number.isFinite ? number : null;
}
