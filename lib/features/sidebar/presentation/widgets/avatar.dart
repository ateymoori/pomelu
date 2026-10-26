import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/avatar_palette.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/data_url.dart';
import '../../../../core/utils/stable_hash.dart';
import '../sidebar_providers.dart';

/// Round avatar: [image], or the first letter of [name] on a muted color
/// whose hue comes from the name. [busy] draws an accent ring that spins
/// unless motion is reduced.
class HermesAvatar extends StatelessWidget {
  const HermesAvatar({
    required this.name,
    super.key,
    this.image,
    this.busy = false,
    this.diameter,
  });

  final String name;
  final ImageProvider<Object>? image;

  final bool busy;

  /// Defaults to `spacing.avatar`.
  final double? diameter;

  static double hueOf(String name) => (stableHash(name) % 360).toDouble();

  /// The letter a picture-less avatar of [name] shows.
  static String letterOf(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty
        ? name
        : String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final diameter = this.diameter ?? context.spacing.avatar;
    final ring = context.surfaces.borderWidth * 2;
    final letter = letterOf(name);
    final picture = image;
    final Widget content = picture != null
        ? Image(image: picture, fit: BoxFit.cover)
        : DecoratedBox(
            decoration: BoxDecoration(
              color: AvatarPalette.fill(hueOf(name)),
              shape: BoxShape.circle,
            ),
            child: Center(
              // Sized to the circle: a scaled letter would only clip.
              child: Text(
                letter,
                textScaler: TextScaler.noScaling,
                maxLines: 1,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.onAccent,
                  fontSize: diameter / 2,
                  height: 1,
                ),
              ),
            ),
          );

    return Semantics(
      label: name,
      image: picture != null,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: diameter,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (busy && context.reduceMotion)
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.accent, width: ring),
                ),
              )
            else if (busy)
              CircularProgressIndicator(
                strokeWidth: ring,
                strokeCap: StrokeCap.round,
                color: colors.accent,
              ),
            Padding(
              padding: EdgeInsets.all(busy ? ring * 2 : 0),
              child: ClipOval(child: content),
            ),
          ],
        ),
      ),
    );
  }
}

/// Decoded avatars for the app's lifetime, by data URL: one small picture a
/// bot, decoded once.
final Map<String, MemoryImage> _decoded = {};

/// A bot's avatar: the gateway picture when it has one, else the letter.
class BotAvatar extends ConsumerWidget {
  const BotAvatar({
    required this.name,
    required this.title,
    super.key,
    this.busy = false,
    this.diameter,
  });

  /// Profile name: fetches the picture.
  final String name;

  /// Display title: the letter and the hue.
  final String title;
  final bool busy;

  /// Defaults to `spacing.avatar`.
  final double? diameter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(profileAvatarProvider(name)).value;
    MemoryImage? image;
    if (url != null) {
      image = _decoded[url];
      if (image == null) {
        final bytes = decodeDataUrl(url);
        if (bytes != null) image = _decoded[url] = MemoryImage(bytes);
      }
    }
    return HermesAvatar(
      name: title,
      image: image,
      busy: busy,
      diameter: diameter,
    );
  }
}
