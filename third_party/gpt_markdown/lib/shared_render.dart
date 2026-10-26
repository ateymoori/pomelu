part of 'gpt_markdown.dart';

/// Rendering shared by the two parsers.
///
/// The regex pipeline ([MarkdownComponent.generate]) and the plusparse
/// renderer disagree about how a block's *content* is produced — one re-runs
/// components over a substring, the other already holds a parsed AST — but
/// everything after that point is identical: resolve the style, hand off to a
/// caller-supplied builder if there is one, otherwise build the default
/// widget. Keeping that half here means a change to a default, a style field
/// or a builder hook lands on both paths at once.
///
/// Each function takes the content as a already-built [Widget] or as a
/// callback, which is the only part the two parsers need to supply themselves.

/// The horizontal rule, honouring [GptMarkdownConfig.hrBuilder] and
/// [HrStyle].
Widget hrWidget(BuildContext context, GptMarkdownConfig config) {
  final gptTheme = GptMarkdownTheme.of(context);
  final style = (resolvedStyleSheet(context, config).hr ?? const HrStyle())
      .resolve(Theme.of(context).colorScheme);
  final builder = config.hrBuilder;
  if (builder != null) {
    return builder(context, style);
  }
  final padding = style.padding;
  return CustomDivider(
    height: style.thickness ?? gptTheme.hrLineThickness,
    color: style.color ?? gptTheme.hrLineColor,
    padding: padding is EdgeInsets ? padding : gptTheme.hrLinePadding,
  );
}

/// A task-list checkbox with [label] beside it, honouring
/// [GptMarkdownConfig.checkboxBuilder], [CheckboxStyle] and
/// [GptMarkdownConfig.onCheckboxChanged].
Widget checkboxWidget(
  BuildContext context,
  GptMarkdownConfig config, {
  required bool checked,
  required Widget label,
}) {
  final style =
      (resolvedStyleSheet(context, config).checkbox ?? const CheckboxStyle())
          .resolve(Theme.of(context).colorScheme);
  final builder = config.checkboxBuilder;
  if (builder != null) {
    return builder(context, checked, label, style);
  }
  return CustomCb(
    scalesItsOwnText: config.blocksRenderDirectly,
    value: checked,
    textDirection: config.textDirection,
    spacing: style.gapAfterBox ?? 5,
    style: style,
    onChanged: config.onCheckboxChanged,
    child: label,
  );
}

/// A radio option with [label] beside it, honouring
/// [GptMarkdownConfig.radioOptionBuilder] and [CheckboxStyle].
Widget radioWidget(
  BuildContext context,
  GptMarkdownConfig config, {
  required bool selected,
  required Widget label,
}) {
  final style =
      (resolvedStyleSheet(context, config).checkbox ?? const CheckboxStyle())
          .resolve(Theme.of(context).colorScheme);
  final builder = config.radioOptionBuilder;
  if (builder != null) {
    return builder(context, selected, label, style);
  }
  return CustomRb(
    scalesItsOwnText: config.blocksRenderDirectly,
    value: selected,
    textDirection: config.textDirection,
    spacing: style.gapAfterBox ?? 5,
    style: style,
    onChanged: config.onCheckboxChanged,
    child: label,
  );
}

/// A heading of [level], honouring [GptMarkdownConfig.headingBuilder] and
/// [HeadingStyle].
///
/// [buildChildren] receives the heading-scoped config — the level's text style
/// merged with any [HeadingStyle.textStyle] override, and
/// [MarkdownScope.heading] — and returns the spans for the heading's own
/// content. Each parser supplies that differently.
Widget headingWidget(
  BuildContext context,
  GptMarkdownConfig config, {
  required int level,
  required List<InlineSpan> Function(GptMarkdownConfig conf) buildChildren,
}) {
  // A heading lifted out of the paragraph has to scale itself, from the
  // ambient MediaQuery; inside one, the paragraph already did it.
  final ambient = config.blocksRenderDirectly;
  final theme = GptMarkdownTheme.of(context);
  final headingStyle =
      (resolvedStyleSheet(context, config).heading ?? const HeadingStyle())
          .resolve(Theme.of(context).colorScheme);
  final levelStyle = [
    theme.h1,
    theme.h2,
    theme.h3,
    theme.h4,
    theme.h5,
    theme.h6,
  ][level - 1];
  final override = headingStyle.textStyle;
  final conf = config.copyWith(
    scope: MarkdownScope.heading,
    style: override == null
        ? levelStyle
        : (levelStyle ?? const TextStyle()).merge(override),
  );

  final builder = config.headingBuilder;
  if (builder != null) {
    final content = config.getRich(
      TextSpan(children: buildChildren(conf)),
      ambientScaling: ambient,
    );
    return builder(context, level, content, headingStyle);
  }

  final dividerPadding = headingStyle.dividerPadding;
  final rich = config.getRich(
    ambientScaling: ambient,
    TextSpan(
      children: [
        ...buildChildren(conf),
        if (level == 1 &&
            (headingStyle.showDivider ?? theme.autoAddDividerLineAfterH1)) ...[
          const TextSpan(text: "\n ", style: TextStyle(fontSize: 0, height: 0)),
          // Left uncompensated on purpose. The rule is a one-pixel decoration
          // with no text in it, so the paragraph scaling its box is invisible —
          // and compensating it made the space it takes at 1x differ from every
          // other scale.
          WidgetSpan(
            child: CustomDivider(
              height: headingStyle.dividerThickness ?? theme.hrLineThickness,
              color: headingStyle.dividerColor ?? theme.hrLineColor,
              padding: dividerPadding is EdgeInsets
                  ? dividerPadding
                  : theme.hrLinePadding,
            ),
          ),
        ],
      ],
    ),
  );

  final headingPadding = headingStyle.padding;
  if (headingPadding == null) {
    return rich;
  }
  return Padding(padding: headingPadding, child: rich);
}

/// The break between two blocks in a text-rendered document: one empty line.
///
/// With [GptMarkdownStyleSheet.blockSpacing] unset this is the historical
/// span, unchanged. Set, the empty line is exactly that tall. The first
/// newline ends the line before it and so takes that line's own style —
/// styled with the spacing, a large value would stretch the previous line as
/// well as add the gap.
InlineSpan paragraphBreakSpan(BuildContext context, GptMarkdownConfig config) {
  final fontSize = config.style?.fontSize ?? 14;
  final spacing = resolvedStyleSheet(context, config).blockSpacing;
  if (spacing == null) {
    return TextSpan(
      text: "\n\n",
      style: TextStyle(
        fontSize: fontSize,
        height: 1.15,
        color: config.style?.color,
      ),
    );
  }
  // No gap is no empty line at all: a zero-height one still takes a pixel.
  if (spacing == 0 || fontSize == 0) {
    return TextSpan(text: "\n", style: config.style);
  }
  return TextSpan(
    children: [
      TextSpan(text: "\n", style: config.style),
      TextSpan(
        text: "\n",
        style: TextStyle(
          fontSize: fontSize,
          height: spacing / fontSize,
          color: config.style?.color,
        ),
      ),
    ],
  );
}

/// A block quote, honouring [GptMarkdownConfig.blockQuoteBuilder] and
/// [BlockQuoteStyle].
///
/// [buildContent] receives the quote-scoped config — the surrounding style
/// merged with any [BlockQuoteStyle.textStyle] override — and returns the
/// quote's rendered body.
InlineSpan blockQuoteSpan(
  BuildContext context,
  GptMarkdownConfig config, {
  required Widget Function(GptMarkdownConfig conf) buildContent,
}) {
  return _blockSpanOf(
    _blockQuoteWidget(context, config, buildContent: buildContent),
  );
}

/// [blockQuoteSpan]'s widget, before it is placed in the text.
Widget _blockQuoteWidget(
  BuildContext context,
  GptMarkdownConfig config, {
  required Widget Function(GptMarkdownConfig conf) buildContent,
}) {
  final style =
      (resolvedStyleSheet(context, config).blockQuote ??
              const BlockQuoteStyle())
          .resolve(Theme.of(context).colorScheme);
  final content = buildContent(_withTextStyle(config, style.textStyle));

  final builder = config.blockQuoteBuilder;
  return builder == null
      ? defaultQuoteWidget(context, content, style, config.textDirection)
      : builder(context, content, style);
}

/// [config] with [textStyle] merged over its style.
GptMarkdownConfig _withTextStyle(
  GptMarkdownConfig config,
  TextStyle? textStyle,
) {
  if (textStyle == null) {
    return config;
  }
  final base = config.style;
  return config.copyWith(
    style: base == null ? textStyle : base.merge(textStyle),
  );
}

/// A block widget placed in the text: it owns its line.
InlineSpan _blockSpanOf(Widget block) {
  return TextSpan(
    children: [
      BlockWidgetSpan(
        alignment: PlaceholderAlignment.bottom,
        baseline: null,
        child: MarkdownTextScaling.wrap(block, enabled: false),
        bare: block,
      ),
    ],
  );
}

/// Whether a quote carrying an alert is drawn as an alert.
///
/// Not when the app replaced quotes with [GptMarkdownConfig.blockQuoteBuilder]
/// and gave no [GptMarkdownConfig.alertBuilder]: its alerts keep going to its
/// quote builder, as they did before alerts were recognised.
bool _rendersAlerts(GptMarkdownConfig config) =>
    config.alertBuilder != null || config.blockQuoteBuilder == null;

/// An alert, honouring [GptMarkdownConfig.alertBuilder] and [AlertStyle].
///
/// [buildContent] receives the alert-scoped config and returns the body,
/// without the marker line. [buildQuoteContent] returns the whole quote as
/// written, marker included; it runs only if the builder asks for
/// [AlertBuildDetails.asBlockQuote].
InlineSpan alertSpan(
  BuildContext context,
  GptMarkdownConfig config, {
  required MarkdownAlertType type,
  required Widget Function(GptMarkdownConfig conf) buildContent,
  required Widget Function(GptMarkdownConfig conf) buildQuoteContent,
}) {
  final sheet = resolvedStyleSheet(context, config).alert ?? const AlertStyle();
  final style = sheet.resolve(type, Theme.of(context).colorScheme);
  final content = buildContent(_withTextStyle(config, style.textStyle));
  final title = _alertTitle(context, config, style);

  late final AlertBuildDetails details;
  details = AlertBuildDetails(
    context: context,
    config: config,
    type: type,
    style: style,
    title: title,
    content: content,
    buildDefault: () => _defaultAlertWidget(details, config.textDirection),
    buildQuote: () =>
        _blockQuoteWidget(context, config, buildContent: buildQuoteContent),
  );
  final builder = config.alertBuilder;
  return _blockSpanOf(
    builder == null ? details.defaultAlert() : builder(context, details),
  );
}

/// The icon and title of an alert, or an empty box when [style] hides both.
///
/// One paragraph, so it follows the same text scaling as the body: the icon
/// is an inline widget and scales with the text beside it.
Widget _alertTitle(
  BuildContext context,
  GptMarkdownConfig config,
  AlertStyle style,
) {
  final text = style.title ?? '';
  final icon = style.icon;
  final showIcon = (style.showIcon ?? true) && icon != null;
  if (text.isEmpty && !showIcon) {
    return const SizedBox.shrink();
  }
  var titleStyle = (config.style ?? const TextStyle()).copyWith(
    color: style.color,
    fontWeight: FontWeight.w600,
  );
  final override = style.titleStyle;
  if (override != null) {
    titleStyle = titleStyle.merge(override);
  }
  final fontSize =
      titleStyle.fontSize ?? DefaultTextStyle.of(context).style.fontSize ?? 14;
  return config.getRich(
    TextSpan(
      style: titleStyle,
      children: [
        if (showIcon)
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: text.isEmpty ? 0 : fontSize * 0.4,
              ),
              child: Icon(
                icon,
                size: style.iconSize ?? fontSize * 1.15,
                color: style.color,
              ),
            ),
          ),
        if (text.isNotEmpty) TextSpan(text: text),
      ],
    ),
    ambientScaling: config.blocksRenderDirectly,
  );
}

/// The default alert: the title row over the body, beside a bar in the
/// accent colour, with optional padding, background and margin.
Widget _defaultAlertWidget(AlertBuildDetails details, TextDirection direction) {
  final style = details.style;
  final hasTitle = details.title is! SizedBox;
  Widget child = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (hasTitle) ...[details.title, SizedBox(height: style.titleGap ?? 4)],
      details.content,
    ],
  );
  final padding = style.padding;
  if (padding != null) {
    child = Padding(padding: padding, child: child);
  }
  child = BlockQuoteWidget(
    color: style.color!,
    direction: direction,
    width: style.barWidth ?? 3,
    child: child,
  );
  final background = style.backgroundColor;
  if (background != null && background.a > 0) {
    child = ColoredBox(color: background, child: child);
  }
  // Clipped rather than decorated, so the bar follows the rounded corners
  // instead of poking out of them square.
  final radius = style.borderRadius;
  if (radius != null && radius != Radius.zero) {
    child = ClipRRect(borderRadius: BorderRadius.all(radius), child: child);
  }
  final margin = style.margin;
  if (margin != null) {
    child = Padding(padding: margin, child: child);
  }
  return Directionality(textDirection: direction, child: child);
}

/// The default block quote: a bar, optional padding, background and margin.
Widget defaultQuoteWidget(
  BuildContext context,
  Widget content,
  BlockQuoteStyle style,
  TextDirection direction,
) {
  final padding = style.padding;
  final margin = style.margin;
  final background = style.backgroundColor;

  Widget child = content;
  if (padding != null) {
    child = Padding(padding: padding, child: child);
  }
  child = BlockQuoteWidget(
    color: style.barColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
    direction: direction,
    width: style.barWidth ?? 3,
    child: child,
  );
  if (background != null) {
    final radius = style.barRadius;
    child = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius == null ? null : BorderRadius.all(radius),
      ),
      child: child,
    );
  }
  if (margin != null) {
    child = Padding(padding: margin, child: child);
  }
  return Directionality(textDirection: direction, child: child);
}

/// A placeholder holding a *block* construct rather than an inline one.
///
/// The difference matters to whoever is laying the document out. A block owns
/// its line and can be lifted out of the paragraph entirely — rendered as a
/// sibling widget, skipping both the placeholder and the nested `Text.rich`
/// inside it. An inline image or equation cannot: it is positioned against a
/// text baseline that would no longer exist.
///
/// Marked explicitly because the two are indistinguishable by shape — an image
/// and a block quote are both a lone bottom-aligned `WidgetSpan`, and telling
/// them apart by looking silently swallowed every image in the document.
class BlockWidgetSpan extends WidgetSpan {
  /// Wraps a block-level [child].
  const BlockWidgetSpan({
    required super.child,
    this.bare,
    super.alignment,
    super.baseline,
    super.style,
  });

  /// [child] without the flex wrapper a placeholder needs, for a caller that
  /// is about to render this block as a sibling widget instead of inside a
  /// paragraph.
  ///
  /// Inside a paragraph the wrapper earns its keep. Rendered directly it is
  /// two render objects per block that resolve to the same constraints the
  /// column already hands down, and paint walks every one of them on every
  /// frame — which a streaming reply pays for on every chunk.
  final Widget? bare;
}

/// A citation tag such as `[1]`, honouring
/// [GptMarkdownConfig.inlineSourceTagBuilder], [SourceTagStyle] and
/// [GptMarkdownConfig.onSourceTagTap].
InlineSpan sourceTagSpan(
  BuildContext context,
  String id,
  GptMarkdownConfig config, {
  String? url,
}) {
  final tagStyle =
      (resolvedStyleSheet(context, config).sourceTag ?? const SourceTagStyle())
          .resolve(Theme.of(context).colorScheme);
  final onSourceTagTap = config.onSourceTagTap;
  final onLinkTap = config.onLinkTap;
  // A tag the document gives a URL (`[1]: https://…`) opens it like a link
  // when the host handles links but not tags.
  final VoidCallback? onTap = onSourceTagTap != null
      ? () => onSourceTagTap(id)
      : url != null && onLinkTap != null
      ? () => onLinkTap(url, id)
      : null;

  final details = SourceTagBuildDetails(
    context: context,
    config: config,
    // The resolved style, not `const TextStyle()`. `SourceTagStyle.textStyle`
    // documents itself as defaulting to the surrounding style; now it does.
    style: tagStyle.textStyle ?? config.style ?? const TextStyle(),
    id: id,
    url: url,
    sourceTagStyle: tagStyle,
    onTap: onTap,
  );

  final builder = config.inlineSourceTagBuilder;
  if (builder != null) {
    final span = builder(details);
    assert(
      onTap == null ||
          span.toPlainText(includePlaceholders: false).isEmpty ||
          _hasReachableTap(span),
      'inlineSourceTagBuilder returned a span with nothing that can be tapped '
      'for "$id". Return details.defaultSpan(), a TappableTextSpan, or '
      'details.asWidgetSpan() for a widget.',
    );
    return span;
  }

  // ignore: deprecated_member_use_from_same_package
  final legacyBuilder = config.sourceTagBuilder;
  if (legacyBuilder != null) {
    // Kept so 1.2.x code compiles, including the empty TextStyle it has always
    // been handed — that is what existing builders were written against.
    return details.asWidgetSpan(
      legacyBuilder(context, id, tagStyle.textStyle ?? const TextStyle()),
    );
  }

  return defaultSourceTagSpan(details);
}

/// The stock `[1]` chip: a filled circle with the number scaled to fit.
///
/// Split out so [SourceTagBuildDetails.defaultSpan] can return it, and so a
/// builder that only wants to wrap the stock chip does not have to restate it.
InlineSpan defaultSourceTagSpan(SourceTagBuildDetails details) {
  final style = details.sourceTagStyle;
  final size = style.size ?? 20;
  return details.asWidgetSpan(
    SizedBox(
      width: size,
      height: size,
      child: Material(
        color:
            style.backgroundColor ??
            Theme.of(details.context).colorScheme.onInverseSurface,
        shape: style.shape == BoxShape.rectangle
            ? const RoundedRectangleBorder()
            : const OvalBorder(),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            details.id,
            style: style.textStyle,
            textDirection: details.config.textDirection,
          ),
        ),
      ),
    ),
  );
}

/// A fenced code block, honouring [GptMarkdownConfig.codeBuilder],
/// [CodeBlockStyle] and [GptMarkdownConfig.onCodeCopy].
Widget codeBlockWidget(
  BuildContext context,
  GptMarkdownConfig config, {
  required String name,
  required String code,
  required bool closed,
}) {
  final style =
      (resolvedStyleSheet(context, config).codeBlock ?? const CodeBlockStyle())
          .resolve(Theme.of(context).colorScheme);
  return config.codeBuilder?.call(context, name, code, closed) ??
      CodeField(
        scalesItsOwnText: config.blocksRenderDirectly,
        name: name,
        codes: code,
        highlightCode: closed || (style.highlightWhileStreaming ?? true),
        style: style,
        onCopy: config.onCodeCopy,
      );
}

/// One bullet-list item, honouring [GptMarkdownConfig.unOrderedListBuilder]
/// and [ListStyle].
Widget unorderedListItem(
  BuildContext context,
  GptMarkdownConfig config,
  Widget child,
) {
  final builder = config.unOrderedListBuilder;
  if (builder != null) {
    return builder(context, child, config.copyWith());
  }
  final style = (resolvedStyleSheet(context, config).list ?? const ListStyle())
      .resolve(Theme.of(context).colorScheme);
  final fontSize =
      config.style?.fontSize ??
      DefaultTextStyle.of(context).style.fontSize ??
      kDefaultFontSize;
  return UnorderedListView(
    scalesItsOwnText: config.blocksRenderDirectly,
    bulletColor:
        style.bulletColor ??
        config.style?.color ??
        DefaultTextStyle.of(context).style.color,
    padding: style.indent ?? 7,
    spacing: style.gapAfterMarker ?? 10,
    bulletSize: style.bulletSize ?? 0.3 * fontSize,
    bulletShape: style.bulletShape ?? BoxShape.circle,
    textDirection: config.textDirection,
    child: child,
  );
}

/// One numbered-list item, honouring [GptMarkdownConfig.orderedListBuilder]
/// and [ListStyle]. [no] is the number without its trailing dot.
Widget orderedListItem(
  BuildContext context,
  GptMarkdownConfig config,
  String no,
  Widget child,
) {
  final builder = config.orderedListBuilder;
  if (builder != null) {
    return builder(context, no, child, config.copyWith());
  }
  final style = (resolvedStyleSheet(context, config).list ?? const ListStyle())
      .resolve(Theme.of(context).colorScheme);
  final marker = style.markerTextStyle;
  final base = (config.style ?? const TextStyle()).copyWith(
    fontWeight: FontWeight.w100,
  );
  return OrderedListView(
    scalesItsOwnText: config.blocksRenderDirectly,
    no: "$no.",
    textDirection: config.textDirection,
    style: marker == null ? base : base.merge(marker),
    // 6 is what `OrderedListView` used before this was configurable; the
    // bullet list uses different numbers, so neither is a shared default.
    padding: style.indent ?? 6,
    spacing: style.gapAfterMarker ?? 6,
    child: child,
  );
}

/// Where the default image widget loads [url] from.
///
/// A `data:` URL is decoded here: it is not a network address, and outside a
/// browser `NetworkImage` cannot load one. Anything else goes to the network
/// as before.
ImageProvider _imageProvider(String url) {
  if (!_isDataUrl(url)) {
    return NetworkImage(url);
  }
  return MemoryImage(_dataUrlBytes(url));
}

bool _isDataUrl(String url) =>
    url.length > 5 && url.substring(0, 5).toLowerCase() == 'data:';

/// Decoded `data:` URLs, most recently used last.
///
/// A [MemoryImage] is identified by its byte list, so decoding afresh on every
/// build — and a streaming reply rebuilds constantly — would make every build
/// a new image: decoded again, and flickering while it is. Handing back the
/// same list keeps the image cache hitting.
final LinkedHashMap<String, Uint8List> _dataUrlCache = LinkedHashMap();

/// Upper bound on [_dataUrlCache], in entries and in decoded bytes. Past
/// either, the least recently used entries go.
const int _dataUrlCacheEntries = 32;
const int _dataUrlCacheBytes = 32 * 1024 * 1024;
int _dataUrlCachedBytes = 0;

/// The bytes of the `data:` URL [url], or an empty list when it is not an
/// image or does not decode — which the image widget then reports through its
/// error builder, like any other image that fails to load.
Uint8List _dataUrlBytes(String url) {
  final cached = _dataUrlCache.remove(url);
  if (cached != null) {
    _dataUrlCache[url] = cached;
    return cached;
  }
  Uint8List bytes;
  try {
    final data = UriData.parse(url);
    bytes = data.mimeType.toLowerCase().startsWith('image/')
        ? data.contentAsBytes()
        : Uint8List(0);
  } on FormatException {
    bytes = Uint8List(0);
  }
  _dataUrlCache[url] = bytes;
  _dataUrlCachedBytes += bytes.length;
  while (_dataUrlCache.length > _dataUrlCacheEntries ||
      (_dataUrlCachedBytes > _dataUrlCacheBytes && _dataUrlCache.length > 1)) {
    final oldest = _dataUrlCache.keys.first;
    _dataUrlCachedBytes -= _dataUrlCache.remove(oldest)!.length;
  }
  return bytes;
}

/// An image, honouring [GptMarkdownConfig.imageBuilder], [ImageStyle] and
/// [GptMarkdownConfig.onImageTap].
///
/// [url] may be a `data:` URL — `data:image/png;base64,...` — as well as a
/// network address. SVG renders too: a `.svg` URL or `data:image/svg+xml`
/// directly, and any other network image that turns out not to be a bitmap
/// when it arrives.
///
/// [onTap] replaces [GptMarkdownConfig.onImageTap] for this image — set when
/// the image is a link's label, so tapping it follows the link.
InlineSpan imageSpan(
  BuildContext context,
  GptMarkdownConfig config, {
  required String url,
  double? width,
  double? height,
  VoidCallback? onTap,
}) {
  // Resolved before the image is built, not after: `fit` decides how the
  // bytes are drawn, so it has to be in hand at construction time. It used to
  // be resolved below, purely for the border and padding, which is why `fit`,
  // `maxWidth` and `maxHeight` were settable and inert.
  final imageStyle =
      (resolvedStyleSheet(context, config).image ?? const ImageStyle()).resolve(
        Theme.of(context).colorScheme,
      );

  final builder = config.imageBuilder;
  final Widget image;
  // An SVG keeps its proportions unless a style says otherwise: stretched to
  // a box like a bitmap, a badge given only a width would distort.
  final svgFit = imageStyle.fit ?? BoxFit.contain;
  Widget svgError(BuildContext context) => const CustomImageError();
  Widget svgLoading(BuildContext context) =>
      const CustomImageLoading(progress: 1);
  if (builder != null) {
    image = builder(context, url, width, height);
  } else if (isSvgUrl(url)) {
    image = SizedBox(
      width: width,
      height: height,
      child: _isDataUrl(url)
          ? memorySvg(
              _dataUrlBytes(url),
              width: width,
              height: height,
              fit: svgFit,
              error: svgError,
            )
          : NetworkSvg(
              url,
              width: width,
              height: height,
              fit: svgFit,
              loading: svgLoading,
              error: svgError,
            ),
    );
  } else {
    image = SizedBox(
      width: width,
      height: height,
      child: Image(
        image: _imageProvider(url),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          final total = loadingProgress.expectedTotalBytes;
          return CustomImageLoading(
            progress: total == null
                ? 1
                : loadingProgress.cumulativeBytesLoaded / total,
          );
        },
        fit: imageStyle.fit ?? BoxFit.fill,
        // An image that arrived but is not a bitmap may be an SVG whose URL
        // does not say so — `https://img.shields.io/pub/v/x`, every README
        // badge. It is tried as one; a failed download is not retried.
        errorBuilder: (context, error, stackTrace) =>
            error is NetworkImageLoadException || _isDataUrl(url)
            ? const CustomImageError()
            : NetworkSvg(
                url,
                width: width,
                height: height,
                fit: svgFit,
                loading: svgLoading,
                error: svgError,
              ),
      ),
    );
  }

  Widget decorated = image;
  // A ceiling, not a size: an image smaller than the bound keeps its own
  // dimensions. Applied before the rounding and padding so the clip follows
  // the constrained box rather than the original.
  final maxWidth = imageStyle.maxWidth;
  final maxHeight = imageStyle.maxHeight;
  if (maxWidth != null || maxHeight != null) {
    decorated = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: decorated,
    );
  }
  final imageRadius = imageStyle.borderRadius;
  if (imageRadius != null) {
    decorated = ClipRRect(
      borderRadius: BorderRadius.all(imageRadius),
      child: decorated,
    );
  }
  final imagePadding = imageStyle.padding;
  if (imagePadding != null) {
    decorated = Padding(padding: imagePadding, child: decorated);
  }
  final onImageTap = config.onImageTap;
  if (onTap != null) {
    decorated = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: decorated),
    );
  } else if (onImageTap != null) {
    decorated = GestureDetector(onTap: () => onImageTap(url), child: decorated);
  }
  return scaledWidgetSpan(
    config: config,
    alignment: PlaceholderAlignment.bottom,
    baseline: null,
    child: decorated,
  );
}

/// Rendered maths, honouring [GptMarkdownConfig.blockLatexBuilder], the
/// deprecated [GptMarkdownConfig.latexBuilder],
/// [GptMarkdownConfig.latexWorkaround] and [LatexStyle].
///
/// [inline] picks between an inline formula and a display block; only the
/// block form takes [LatexStyle]'s padding, background and horizontal scroll.
/// Inline maths inside a paragraph goes through [_latexSpan], which also
/// honours [GptMarkdownConfig.inlineLatexBuilder].
Widget latexWidget(
  BuildContext context,
  GptMarkdownConfig config, {
  required String tex,
  required bool inline,
}) {
  final latexStyle =
      (resolvedStyleSheet(context, config).latex ?? const LatexStyle()).resolve(
        Theme.of(context).colorScheme,
      );
  final rendered = (config.latexWorkaround ?? (String tex) => tex)(tex);
  final style = _latexTextStyle(config, latexStyle);
  final blockBuilder = inline ? null : config.blockLatexBuilder;
  // ignore: deprecated_member_use_from_same_package
  final legacyBuilder = config.latexBuilder;
  // Build below the boundary so custom builders and the math engine read the
  // effective scaler, including when this formula is nested inside a block.
  Widget maths = MarkdownTextScaling.wrap(
    Builder(
      builder: (mathContext) {
        Widget buildDefault() => _defaultLatex(
          mathContext,
          config,
          tex: rendered,
          source: tex,
          style: style,
          inline: inline,
        );
        if (blockBuilder != null) {
          return blockBuilder(
            BlockLatexBuildDetails(
              context: mathContext,
              config: config,
              style: style,
              tex: rendered,
              source: tex,
              onTap: _latexTap(config, rendered, tex, inline),
              buildDefault: buildDefault,
            ),
          );
        }
        if (legacyBuilder != null) {
          return legacyBuilder(mathContext, rendered, style, inline);
        }
        return buildDefault();
      },
    ),
    enabled: !inline && config.blocksRenderDirectly,
  );
  if (inline) {
    return maths;
  }

  if (latexStyle.scrollBlockHorizontally ?? false) {
    // Rendered maths cannot wrap, so a wide formula overflows a phone.
    maths = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: maths,
    );
  }
  final background = latexStyle.backgroundColor;
  if (background != null) {
    final radius = latexStyle.borderRadius;
    maths = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius == null ? null : BorderRadius.all(radius),
      ),
      child: maths,
    );
  }
  final padding = latexStyle.padding;
  if (padding != null) {
    maths = Padding(padding: padding, child: maths);
  }
  return maths;
}

/// An inline formula as a span, honouring
/// [GptMarkdownConfig.inlineLatexBuilder]; without one, [latexWidget] placed
/// with [placeholder].
///
/// [placeholder] puts a widget in the line the way the calling pipeline does,
/// so the default formula sits exactly where it always has.
InlineSpan _latexSpan(
  BuildContext context,
  GptMarkdownConfig config, {
  required String tex,
  required InlineSpan Function(Widget child) placeholder,
}) {
  final builder = config.inlineLatexBuilder;
  if (builder == null) {
    return placeholder(latexWidget(context, config, tex: tex, inline: true));
  }
  final latexStyle =
      (resolvedStyleSheet(context, config).latex ?? const LatexStyle()).resolve(
        Theme.of(context).colorScheme,
      );
  final rendered = (config.latexWorkaround ?? (String tex) => tex)(tex);
  final style = _latexTextStyle(config, latexStyle);
  return builder(
    InlineLatexBuildDetails(
      context: context,
      config: config,
      style: style,
      tex: rendered,
      source: tex,
      onTap: _latexTap(config, rendered, tex, true),
      // The paragraph scales its placeholders, so whatever goes in one must
      // not scale itself as well.
      placeholder: (child) =>
          placeholder(MarkdownTextScaling.wrap(child, enabled: false)),
      buildDefault: () => Builder(
        builder: (mathContext) => _defaultLatex(
          mathContext,
          config,
          tex: rendered,
          source: tex,
          style: style,
          inline: true,
        ),
      ),
    ),
  );
}

/// The style a formula is drawn with: [LatexStyle.textStyle] over the
/// surrounding style.
TextStyle _latexTextStyle(GptMarkdownConfig config, LatexStyle latexStyle) {
  final override = latexStyle.textStyle;
  final base = config.style ?? const TextStyle();
  return override == null ? base : base.merge(override);
}

/// [GptMarkdownConfig.onLatexTap] bound to a formula as a whole, or null.
VoidCallback? _latexTap(
  GptMarkdownConfig config,
  String tex,
  String source,
  bool inline,
) {
  final onTap = config.onLatexTap;
  if (onTap == null) return null;
  return () => onTap(LatexTapDetails(tex: tex, source: source, inline: inline));
}

/// The package's own formula: [tex] drawn by `val_latex_flutter`, with
/// [GptMarkdownConfig.onLatexTap] wired to the part tapped.
Widget _defaultLatex(
  BuildContext context,
  GptMarkdownConfig config, {
  required String tex,
  required String source,
  required TextStyle style,
  required bool inline,
}) {
  // Bold surrounding text (a heading, say) sets its formulas in bold.
  final bold = (config.style?.fontWeight?.value ?? 400) >= 600;
  final onLatexTap = config.onLatexTap;
  // `Math` would scale by the ambient text scaler itself. Scaling the text
  // size first and then enlarging by a fifth, as formulas always have been,
  // needs the formula's own scaling off — the two differ for a non-linear
  // scaler.
  Widget math = MediaQuery.withNoTextScaling(
    child: Math.tex(
      bold ? '\\boldsymbol{$tex}' : tex,
      // Display style everywhere, as an inline box: big operators and
      // full-size fractions even in a paragraph, and no full-width block, so
      // the formula keeps its own width and `LatexStyle` places it.
      displayMode: true,
      block: false,
      // No wrapping or overflow handling: both need a `LayoutBuilder`, which
      // throws inside `IntrinsicWidth` — the usual chat-bubble shrink-wrap
      // (#107). `LatexStyle.scrollBlockHorizontally` covers wide formulas
      // instead.
      wrap: false,
      overflow: MathOverflow.visible,
      textStyle: style.copyWith(
        color: config.style?.color ?? Theme.of(context).colorScheme.onSurface,
        fontSize:
            MarkdownTextScaling.fontSize(
              context,
              style.fontSize ??
                  Theme.of(context).textTheme.bodyMedium?.fontSize ??
                  14,
            ) *
            1.2,
      ),
      // Streaming on, explicitly: an unfinished formula renders what has
      // arrived instead of failing. `Math.tex` defaults it off since
      // val_latex_flutter 0.1.1, and a formula still streaming in reaches
      // here closed but incomplete.
      parseOptions: const ParseOptions(strict: Strict.ignore, streaming: true),
      onTap: onLatexTap == null
          ? null
          : (tap) => onLatexTap(
              LatexTapDetails(
                tex: tex,
                source: source,
                inline: inline,
                tappedTex: tap.tex,
                href: tap.link,
              ),
            ),
      // `Math` registers with the enclosing `SelectionArea` itself and copies
      // the LaTeX of what is selected, so it needs no adapter.
      // Plain text again, so it takes the scaling switched off above.
      onError: (_, _) => MediaQuery(
        data: MediaQuery.of(context),
        child: Text(
          tex,
          textDirection: config.textDirection,
          style: style.copyWith(
            color: (!kDebugMode) ? null : Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    ),
  );
  if (onLatexTap != null) {
    math = MouseRegion(cursor: SystemMouseCursors.click, child: math);
  }
  return math;
}

/// Pomelu patch: a [TableRow] decoration paints square past the border's
/// rounded corners; the clip keeps the header and stripe fills inside it.
Widget _clipTable(Radius? radius, Widget table) => radius == null
    ? table
    : ClipRRect(borderRadius: BorderRadius.all(radius), child: table);

/// Owns the horizontal scroll state of one mounted table.
class _TableViewport extends StatefulWidget {
  const _TableViewport({
    required this.child,
    this.overflow = TableOverflow.scroll,
  });
  final Widget child;

  /// [TableOverflow.wrap] drops the scroll view, so the table is laid out
  /// against the available width and shrinks its columns to fit it.
  final TableOverflow overflow;
  @override
  State<_TableViewport> createState() => _TableViewportState();
}

class _TableViewportState extends State<_TableViewport> {
  final _controller = ScrollController();
  final _fit = _TableFit();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The strip reserved under the table for the bar, and the bar's own
  /// thickness — the same number, so the bar fills the strip exactly. Material
  /// would otherwise hold a 2px `crossAxisMargin` off the edge, leaving a gap
  /// under the bar; that is set to zero below.
  static const double _barStrip = 8;

  @override
  Widget build(BuildContext context) {
    final table = _TableIntrinsicsGuard(child: widget.child);
    if (widget.overflow == TableOverflow.wrap) {
      return table;
    }
    // A horizontal scrollable never gets a scrollbar from the ambient
    // behaviour — `MaterialScrollBehavior.buildScrollbar` returns the child
    // unchanged for `Axis.horizontal` on every platform — so this widget is
    // the only reason one appears, and it is on us to decide where.
    //
    // On a touch device, nowhere: a finger already knows how to drag a table
    // sideways, and the bar has no gesture of its own to offer. Drawn, it
    // overlaps the bottom row, because a scrollbar paints inside the viewport
    // it belongs to.
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return _ViewportWidth(
          fit: _fit,
          child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            child: _WidthFloor(fit: _fit, child: table),
          ),
        );
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        // A pointer has no such affordance, so the bar earns its place — but
        // it gets a strip of its own rather than the last row's. The strip is
        // exactly the bar's height: no gap under it.
        return ScrollbarTheme(
          // `crossAxisMargin` is not a `Scrollbar` argument; it only reaches
          // the painter through the theme. Material defaults it to 2, which
          // holds the bar off the viewport edge and leaves a gap beneath it.
          data: ScrollbarThemeData(
            crossAxisMargin: 0,
            mainAxisMargin: 0,
            thickness: const WidgetStatePropertyAll<double>(_barStrip),
          ),
          child: _ViewportWidth(
            fit: _fit,
            child: Scrollbar(
              controller: _controller,
              child: SingleChildScrollView(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                child: _WidthFloor(
                  fit: _fit,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: _barStrip),
                    child: table,
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }
}

/// Pomelu patch: the width a table's scroll view has. The table inside gets
/// no width from the scroll view, so [_ViewportWidth] notes it here and
/// [_WidthFloor] lays the table out at it: the cells wrap to fit the screen,
/// and the table scrolls only when its columns cannot fit with whole words.
class _TableFit {
  double width = double.infinity;
  _RenderWidthFloor? floor;
}

class _ViewportWidth extends SingleChildRenderObjectWidget {
  const _ViewportWidth({required this.fit, super.child});

  final _TableFit fit;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderViewportWidth(fit);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderViewportWidth renderObject,
  ) => renderObject.fit = fit;
}

class _RenderViewportWidth extends RenderProxyBox {
  _RenderViewportWidth(this.fit);

  _TableFit fit;

  @override
  void performLayout() {
    if (fit.width != constraints.maxWidth) {
      fit.width = constraints.maxWidth;
      // The floor below lays out again at the new width; as with
      // `LayoutBuilder`, only a layout callback may dirty a descendant.
      invokeLayoutCallback<BoxConstraints>((_) => fit.floor?.markNeedsLayout());
    }
    super.performLayout();
  }
}

class _WidthFloor extends SingleChildRenderObjectWidget {
  const _WidthFloor({required this.fit, super.child});

  final _TableFit fit;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderWidthFloor(fit);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderWidthFloor renderObject,
  ) => renderObject.fit = fit;
}

class _RenderWidthFloor extends RenderProxyBox {
  _RenderWidthFloor(this._fit);

  _TableFit _fit;

  set fit(_TableFit value) {
    if (identical(value, _fit)) return;
    if (_fit.floor == this) _fit.floor = null;
    _fit = value;
    if (attached) _fit.floor = this;
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _fit.floor = this;
  }

  @override
  void detach() {
    if (_fit.floor == this) _fit.floor = null;
    super.detach();
  }

  /// [constraints] at the table's own width when it fits the viewport,
  /// else at the viewport's width, or at the table's narrowest with whole
  /// words when that is wider.
  BoxConstraints _fitted(RenderBox child, BoxConstraints constraints) {
    final width = _fit.width;
    if (!width.isFinite) return constraints;
    final floor = child.getMinIntrinsicWidth(double.infinity);
    final natural = child.getMaxIntrinsicWidth(double.infinity);
    return constraints.copyWith(
      maxWidth: constraints.constrainWidth(min(natural, max(width, floor))),
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    return constraints.constrain(
      child.getDryLayout(_fitted(child, constraints)),
    );
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_fitted(child, constraints), parentUsesSize: true);
    size = constraints.constrain(child.size);
  }
}
