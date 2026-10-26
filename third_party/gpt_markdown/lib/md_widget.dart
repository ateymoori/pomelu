part of 'gpt_markdown.dart';

/// It creates a markdown widget closed to each other.
///
/// Deprecated because it is the renderer for the legacy regex pipeline, which
/// [GptMarkdown] no longer selects by default. Building it directly costs the
/// three things the plusparse path provides: there is no incremental segment
/// cache, so the whole source is re-split and re-parsed on every text change;
/// there is no span-level reveal, because a reveal here falls back to
/// [StreamingMarkdown] re-slicing the source instead of restyling spans that
/// already exist; and there is no viewport laziness, because inside
/// [SliverGptMarkdown] this path becomes one `SliverToBoxAdapter` holding the
/// entire document.
///
/// It remains what the legacy path builds internally — [GptMarkdown] reaches
/// it whenever `components`, `inlineComponents` or `incremental: false` is
/// passed — so it keeps working unchanged until it is removed.
///
/// Before:
///
/// ```dart
/// MdWidget(
///   context,
///   '# Title',
///   true,
///   config: GptMarkdownConfig(style: Theme.of(context).textTheme.bodyMedium),
/// )
/// ```
///
/// After:
///
/// ```dart
/// GptMarkdown('# Title', style: Theme.of(context).textTheme.bodyMedium)
/// ```
@Deprecated('Use GptMarkdown instead. Will be removed in 2.0.0.')
class MdWidget extends StatefulWidget {
  const MdWidget(
    this.context,
    this.exp,
    this.includeGlobalComponents, {
    super.key,
    required this.config,
    this.isRoot = false,
  });

  /// isRoot
  final bool isRoot;

  /// The expression to be displayed.
  final String exp;
  final BuildContext context;

  /// Whether to include global components.
  final bool includeGlobalComponents;

  /// The configuration of the markdown widget.
  final GptMarkdownConfig config;

  @override
  State<MdWidget> createState() => _MdWidgetState();
}

class _MdWidgetState extends State<MdWidget> {
  List<InlineSpan> list = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Colours are resolved while the spans are built, not while they are
    // painted: link colours come from `GptMarkdownTheme`, inline code and
    // headings from the ambient `ColorScheme`. So an inherited change — a
    // light/dark switch, a new `GptMarkdownTheme`, a text-direction change —
    // has to regenerate them. Without this the widget rebuilds happily and
    // keeps painting the previous theme's colours.
    //
    // This also covers the first build: `didChangeDependencies` runs after
    // `initState` and before `build`.
    _generate();
  }

  @override
  void didUpdateWidget(covariant MdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exp != widget.exp ||
        !oldWidget.config.isSame(widget.config)) {
      _generate();
    }
  }

  /// Regenerates the spans.
  ///
  /// Uses this element's own `context`, not [MdWidget.context]. Components
  /// resolve their colours through the context handed to them, and an
  /// inherited lookup registers the dependency on *that* element — so passing
  /// an ancestor's context would mean this widget is never notified when the
  /// theme changes.
  void _generate() {
    list = MarkdownComponent.generate(
      context,
      widget.exp,
      widget.config,
      widget.includeGlobalComponents,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.config.getRich(
      TextSpan(children: list, style: widget.config.style?.copyWith()),
      isRoot: widget.isRoot,
    );
  }
}

/// A custom table column width.
///
/// Stateless, so every instance is interchangeable — and it declares that,
/// which matters more than it looks. `RenderTable.defaultColumnWidth`'s setter
/// short-circuits on `==` before calling `markNeedsLayout`. Without an
/// equality this class inherits identity, a fresh instance is allocated on
/// every build, the comparison always fails, and the table re-measures every
/// cell on every rebuild — a full extra layout pass per cell, for a table that
/// has not changed.
class CustomTableColumnWidth extends TableColumnWidth {
  /// Creates the default column width.
  const CustomTableColumnWidth();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CustomTableColumnWidth;

  @override
  int get hashCode => (CustomTableColumnWidth).hashCode;

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    double width = 50;
    for (var each in cells) {
      width = max(width, _measure(each));
      // The result is clamped to the container, and measuring more cells can
      // only make `width` larger — so once it is already at the clamp, the
      // rest of the column is a layout pass per cell for an answer that
      // cannot change.
      if (width >= containerWidth) {
        return containerWidth;
      }
    }
    return min(containerWidth, width);
  }

  /// The widest [cell] wants to be.
  ///
  /// Lays the cell out rather than asking for an intrinsic, for two reasons,
  /// both measured rather than assumed:
  ///
  ///  * `LayoutBuilder` cannot answer an intrinsic — producing one would mean
  ///    running its callback speculatively against constraints it has not been
  ///    given. It throws when asserts are on and quietly returns zero when they
  ///    are not, so a consumer whose cell holds one would get a crash in
  ///    development and a collapsed column in production.
  ///  * it is not even faster. `getMaxIntrinsicWidth` on a paragraph lays the
  ///    text out at unbounded width anyway, and the table still lays the cell
  ///    out afterwards for real — so it buys a second pass, not a cheaper one.
  ///    Measured at 5924 and 7039 us against 5263 and 4545 for four tables.
  ///
  /// The measurement is the price of sizing columns to their content.
  /// `TableStyle.columnWidth` opts out of it — a `FlexColumnWidth` divides the
  /// width proportionally and measures nothing.
  static double _measure(RenderBox cell) {
    if (_measuringWithoutLayout > 0) {
      // An intrinsic or dry-layout query (`IntrinsicWidth`, `IntrinsicHeight`
      // above the table) must not lay anything out: Flutter asserts on it, and
      // in release the cell is left without a size and fails in paint (#107).
      return cell.getMaxIntrinsicWidth(double.infinity);
    }
    cell.layout(const BoxConstraints(), parentUsesSize: true);
    return cell.size.width;
  }

  /// Non-zero while [_TableIntrinsicsGuard] is answering an intrinsic or
  /// dry-layout query for its table.
  ///
  /// [RenderTable] sizes its columns through [maxIntrinsicWidth] both during
  /// layout and while answering those queries, and passes nothing that tells
  /// them apart. The table's parent does know, so it sets this around the
  /// query. A counter rather than a flag, so a nested query cannot clear it
  /// for the one still running.
  static int _measuringWithoutLayout = 0;

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return 50;
  }
}

/// The column width a table of [columnCount] columns uses when
/// [TableStyle.columnWidth] is unset.
///
/// Pomelu patch: a scrolling table fits its width as well and scrolls only
/// when whole words do not fit (`_WidthFloor`), so its minimum is not capped.
TableColumnWidth _defaultTableColumnWidth(
  TableOverflow? overflow,
  int columnCount,
) => _WrapTableColumnWidth(columnCount, capped: overflow == TableOverflow.wrap);

/// [CustomTableColumnWidth] with a minimum that keeps words whole, for
/// [TableOverflow.wrap].
///
/// A table too wide for its space takes an equal share off every column until
/// each reaches its minimum. With the flat 50-pixel minimum that crushes a
/// short column mid-word ("Feat" / "ure") while a long one keeps its width, so
/// the minimum here is the longest word in the column.
///
/// It is capped at an equal share of the table width. The minimums then never
/// add up to more than the space, so a wrapped table always fits: a long URL,
/// or more columns than the words allow, breaks inside a word rather than
/// running off a screen that no longer scrolls.
class _WrapTableColumnWidth extends TableColumnWidth {
  const _WrapTableColumnWidth(this.columnCount, {this.capped = true});

  final int columnCount;

  /// Whether the minimum stops at an equal share of the table width.
  final bool capped;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WrapTableColumnWidth &&
          other.columnCount == columnCount &&
          other.capped == capped;

  @override
  int get hashCode => Object.hash(_WrapTableColumnWidth, columnCount, capped);

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      const CustomTableColumnWidth().maxIntrinsicWidth(cells, containerWidth);

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    final cap = capped && containerWidth.isFinite
        ? containerWidth / max(columnCount, 1)
        : double.infinity;
    double width = 0;
    for (final cell in cells) {
      width = max(width, cell.getMinIntrinsicWidth(double.infinity));
      if (width >= cap) {
        return cap;
      }
    }
    return width;
  }

  /// Pomelu patch: in a fitted table the columns of running text wrap
  /// first, each in proportion to what it can spare. A column of short
  /// values (a size, a date, a name), whose longest line is at most
  /// [_shortValue] times its longest word, is not flexible: it gives up
  /// width only when the text columns are down to whole words.
  @override
  double? flex(Iterable<RenderBox> cells) {
    if (capped) return null;
    final longest = maxIntrinsicWidth(cells, double.infinity);
    final word = minIntrinsicWidth(cells, double.infinity);
    return longest > word * _shortValue ? longest - word : null;
  }

  static const double _shortValue = 3;
}

/// Tells [CustomTableColumnWidth] when its table is being measured rather than
/// laid out, so the column measurement stays legal under `IntrinsicWidth` and
/// `IntrinsicHeight`.
///
/// Ordinary layout passes straight through: only the intrinsic and dry-layout
/// queries change, and those threw before.
class _TableIntrinsicsGuard extends SingleChildRenderObjectWidget {
  const _TableIntrinsicsGuard({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTableIntrinsicsGuard();
}

class _RenderTableIntrinsicsGuard extends RenderProxyBox {
  T _withoutLayout<T>(T Function() query) {
    CustomTableColumnWidth._measuringWithoutLayout++;
    try {
      return query();
    } finally {
      CustomTableColumnWidth._measuringWithoutLayout--;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _withoutLayout(() => super.computeMinIntrinsicWidth(height));

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _withoutLayout(() => super.computeMaxIntrinsicWidth(height));

  @override
  double computeMinIntrinsicHeight(double width) =>
      _withoutLayout(() => super.computeMinIntrinsicHeight(width));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _withoutLayout(() => super.computeMaxIntrinsicHeight(width));

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _withoutLayout(() => super.computeDryLayout(constraints));

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) => _withoutLayout(() => super.computeDryBaseline(constraints, baseline));
}
