import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/data_url.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/api/hermes_api.dart';
import '../../../../hermes/models/local_attachment.dart';
import '../../domain/chat_message.dart';
import 'media_viewer.dart';

/// One picture a tile and the viewer can both show, on the phone, on the
/// gateway, inline, or behind a web URL.
class MediaItem {
  const MediaItem({
    required this.provider,
    required this.fileName,
    this.remotePath,
    this.localPath,
    this.sourceUrl,
  });

  final ImageProvider<Object> provider;
  final String fileName;

  /// Gateway path.
  final String? remotePath;

  /// Device path.
  final String? localPath;

  /// Web URL of a Markdown picture.
  final String? sourceUrl;

  static const int _cacheLimit = 64;

  static final Map<Object, MediaItem> _cache = {};

  static MediaItem _remember(Object key, MediaItem item) {
    if (_cache.length >= _cacheLimit) _cache.remove(_cache.keys.first);
    return _cache[key] = item;
  }

  /// A Markdown picture by absolute http(s) URL; null for anything else.
  static MediaItem? fromUrl(String url, {String? alt}) {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return null;
    }
    if (_cache[url] case final hit?) return hit;
    final name = alt?.trim() ?? '';
    return _remember(
      url,
      MediaItem(
        provider: CachedNetworkImageProvider(url),
        fileName: name.isNotEmpty
            ? name
            : uri.pathSegments.lastOrNull ?? uri.host,
        sourceUrl: url,
      ),
    );
  }

  static MediaItem? fromLocal(LocalAttachment a) => !a.isImage
      ? null
      : MediaItem(
          provider: FileImage(File(a.thumbnailPath ?? a.path)),
          fileName: a.name,
          localPath: a.path,
        );

  /// Null when [m] cannot be shown (no gateway, a bad data URL).
  static MediaItem? fromRef(MediaRef m, HermesApi? api) {
    if (m.kind != AttachmentKind.image) return null;
    final headers = api?.mediaHeaders() ?? const <String, String>{};
    final key = (
      m,
      api,
      (headers.entries.map((e) => '$e').toList()..sort()).join(),
    );
    if (_cache[key] case final hit?) return hit;
    final bytes = decodeDataUrl(m.dataUrl);
    if (bytes != null) {
      return _remember(
        key,
        MediaItem(provider: MemoryImage(bytes), fileName: m.fileName),
      );
    }
    if (api == null || m.path.isEmpty) return null;
    return _remember(
      key,
      MediaItem(
        provider: CachedNetworkImageProvider(
          api.mediaDownloadUrl(m.path).toString(),
          headers: headers,
        ),
        fileName: m.fileName,
        remotePath: m.path,
      ),
    );
  }
}

/// A row of square picture tiles; a tap opens the viewer at that picture.
class MediaStrip extends StatelessWidget {
  const MediaStrip({
    required this.items,
    super.key,
    this.alignEnd = false,
    this.onRemove,
  });

  final List<MediaItem> items;

  /// Right-aligned, in a user bubble.
  final bool alignEnd;

  /// A remove mark per tile, in the composer.
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    // A shrink-wrapping row, so a lone tile does not stretch its bubble.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: alignEnd,
      clipBehavior: Clip.none,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.spacing.sm,
        children: [
          for (var i = 0; i < items.length; i++)
            MediaTile(
              image: items[i].provider,
              label: items[i].fileName,
              onTap: () =>
                  MediaViewerPage.open(context, items: items, initialIndex: i),
              onRemove: onRemove == null ? null : () => onRemove!(i),
            ),
        ],
      ),
    );
  }
}

/// The compact row that stands in for media that is not there: a mark, the
/// name, a quiet line, and Retry when it can be tried again.
class MediaStatusChip extends StatelessWidget {
  const MediaStatusChip({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.busy = false,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// A spinner instead of [icon].
  final bool busy;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final theme = Theme.of(context).textTheme;
    return AppSurface(
      color: colors.toolSurface,
      border: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: spacing.minTouch),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: spacing.md,
            top: spacing.sm,
            bottom: spacing.sm,
            end: onRetry == null ? spacing.md : spacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                const AppSpinner()
              else
                Icon(icon, size: spacing.lg, color: colors.textSecondary),
              SizedBox(width: spacing.sm),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodyMedium,
                    ),
                    if (subtitle case final s?)
                      Text(
                        s,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodySmall,
                      ),
                  ],
                ),
              ),
              if (onRetry != null) ...[
                SizedBox(width: spacing.xs),
                TextButton(
                  onPressed: onRetry,
                  child: Text(context.l10n.actionRetry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
