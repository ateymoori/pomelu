import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/failure_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/models/model_options.dart';
import '../../domain/model_catalog.dart';

/// Loads the provider catalogue and shows it as slivers of the settings
/// sheet's one scroll view: a shimmer while it loads, one line when it fails
/// or is empty, else the model rows.
class ModelCatalogView extends StatefulWidget {
  const ModelCatalogView({
    required this.load,
    required this.current,
    required this.onPick,
    super.key,
  });

  /// Loads the catalogue. May fail; the view says so.
  final Future<ModelOptions> Function() load;

  /// Model id currently driving the session.
  final String current;

  /// Chosen model and its provider slug.
  final void Function(String model, String provider) onPick;

  @override
  State<ModelCatalogView> createState() => _ModelCatalogViewState();
}

class _ModelCatalogViewState extends State<ModelCatalogView> {
  late final Future<ModelOptions> _options = Future<ModelOptions>.sync(
    widget.load,
  );

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return FutureBuilder<ModelOptions>(
      future: _options,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _note(
            context,
            failureText(context, snapshot.error!),
            color: context.colors.danger,
          );
        }
        final options = snapshot.data;
        if (options == null) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(spacing.lg),
              child: const Center(child: ShimmerLine()),
            ),
          );
        }
        if (options.usable.isEmpty) {
          return _note(context, context.l10n.composerNoModels);
        }
        return _ModelPicker(
          options: options,
          current: widget.current,
          onPick: widget.onPick,
        );
      },
    );
  }

  Widget _note(BuildContext context, String text, {Color? color}) =>
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xl),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: color),
          ),
        ),
      );
}

/// Search field, one chip per provider, and that provider's models newest
/// first, as slivers. The provider holding the live model opens first, with
/// its row tinted and checked. The rows are a lazy sliver list, so a catalogue
/// of hundreds of models costs only the rows on screen.
class _ModelPicker extends StatefulWidget {
  const _ModelPicker({
    required this.options,
    required this.current,
    required this.onPick,
  });

  final ModelOptions options;

  /// Model id currently driving the session.
  final String current;

  /// Chosen model and its provider slug.
  final void Function(String model, String provider) onPick;

  @override
  State<_ModelPicker> createState() => _ModelPickerState();
}

class _ModelPickerState extends State<_ModelPicker> {
  final TextEditingController _search = TextEditingController();

  late final String? _currentSlug = _findCurrent();

  late final List<ModelProvider> _providers = [
    for (final p in widget.options.usable)
      if (p.slug == _currentSlug) p,
    for (final p in widget.options.usable)
      if (p.slug != _currentSlug) p,
  ];

  late final Map<String, List<String>> _sorted = {
    for (final p in _providers) p.slug: sortNewestFirst(p.models),
  };

  late String _slug = _providers.first.slug;

  String? _findCurrent() {
    final holders = [
      for (final p in widget.options.usable)
        if (p.models.contains(widget.current)) p.slug,
    ];
    if (holders.isEmpty) return null;
    return holders.contains(widget.options.provider)
        ? widget.options.provider
        : holders.first;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final provider = _providers.firstWhere((p) => p.slug == _slug);
    final models = filterModels(_sorted[_slug]!, _search.text);

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              spacing.xl,
              spacing.xs,
              spacing.xl,
              spacing.sm,
            ),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: context.l10n.composerSearchModels,
                prefixIcon: const Icon(CupertinoIcons.search),
              ),
            ),
          ),
        ),
        if (_providers.length > 1) SliverToBoxAdapter(child: _chips(context)),
        if (models.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(spacing.xl),
              child: Center(
                child: Text(
                  context.l10n.composerNoModelMatch,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: context.colors.textTertiary),
                ),
              ),
            ),
          )
        else
          _list(context, provider, models),
      ],
    );
  }

  Widget _chips(BuildContext context) {
    final spacing = context.spacing;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsetsDirectional.symmetric(horizontal: spacing.xl),
      child: Row(
        children: [
          for (final p in _providers)
            Padding(
              padding: EdgeInsetsDirectional.only(end: spacing.sm),
              child: ChoiceChip(
                label: Text(p.name),
                avatar: p.authenticated
                    ? null
                    : Icon(CupertinoIcons.lock, size: spacing.lg),
                selected: p.slug == _slug,
                onSelected: (_) => setState(() => _slug = p.slug),
              ),
            ),
        ],
      ),
    );
  }

  Widget _list(
    BuildContext context,
    ModelProvider provider,
    List<String> models,
  ) {
    final spacing = context.spacing;
    return SliverPadding(
      padding: EdgeInsetsDirectional.fromSTEB(
        spacing.md,
        spacing.sm,
        spacing.md,
        spacing.sm,
      ),
      // Signed-out providers stay listed, never silently dropped; their rows
      // are dimmed and inert.
      sliver: SliverList.builder(
        itemCount: models.length,
        itemBuilder: (context, i) => _ModelRow(
          model: models[i],
          selected:
              models[i] == widget.current && provider.slug == _currentSlug,
          enabled: provider.authenticated,
          onTap: () => widget.onPick(models[i], provider.slug),
        ),
      ),
    );
  }
}

class _ModelRow extends StatelessWidget {
  const _ModelRow({
    required this.model,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String model;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context).textTheme;
    final vendor = modelVendor(model);
    return ListTile(
      selected: selected,
      enabled: enabled,
      title: Text(
        modelDisplayName(model),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: selected
            ? theme.titleSmall?.copyWith(color: colors.accentText)
            : theme.bodyMedium,
      ),
      subtitle: vendor.isEmpty ? null : Text(vendor),
      trailing: selected
          ? Icon(CupertinoIcons.checkmark, color: colors.accent)
          : null,
      onTap: onTap,
    );
  }
}
