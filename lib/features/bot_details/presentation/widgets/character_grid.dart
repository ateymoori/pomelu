import 'package:flutter/material.dart';

import '../../../../core/config/assets.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/l10n_ext.dart';

/// The ready-made pictures; [selected] wears the accent ring.
class CharacterGrid extends StatelessWidget {
  const CharacterGrid({required this.onPick, super.key, this.selected});

  final String? selected;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final tile = spacing.characterTile;
    final ring = context.surfaces.borderWidth * 2;
    final cache = (tile * MediaQuery.devicePixelRatioOf(context)).round();

    return GridView.extent(
      // Its own padding: a grid would take the page's safe-area inset.
      padding: EdgeInsets.all(spacing.md),
      maxCrossAxisExtent: tile + spacing.sm,
      mainAxisSpacing: spacing.sm,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final (i, asset) in Assets.botCharacters.indexed)
          Semantics(
            button: true,
            selected: asset == selected,
            label: context.l10n.botEditCharacter(i + 1),
            onTap: () => onPick(asset),
            excludeSemantics: true,
            child: Center(
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => onPick(asset),
                child: Container(
                  width: tile,
                  height: tile,
                  padding: EdgeInsets.all(ring),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: asset == selected
                          ? colors.accent
                          : Colors.transparent,
                      width: ring,
                    ),
                  ),
                  child: Image.asset(asset, cacheWidth: cache),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
