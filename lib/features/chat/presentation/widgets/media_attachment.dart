import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/models/local_attachment.dart';
import '../../../connection/presentation/connection_providers.dart';
import '../../data/media_cache.dart';
import '../../domain/chat_message.dart';
import '../media_size.dart';
import 'media_audio.dart';
import 'media_strip.dart';
import 'media_video.dart';

/// Renders one gateway [MediaRef]: picture, video, audio or file chip.
class MediaAttachment extends ConsumerWidget {
  const MediaAttachment({
    required this.media,
    required this.profile,
    super.key,
  });

  /// The reference to render.
  final MediaRef media;

  /// Profile the media belongs to; scopes the gateway stream route.
  final String profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(hermesApiProvider);
    final chip = _FileChip(media: media);
    Widget play(Widget Function(Uri url, Map<String, String> headers) player) =>
        api == null || media.path.isEmpty
        ? chip
        : player(
            api.mediaStreamUrl(media.path, profile: profile),
            api.mediaHeaders(),
          );

    // No inset of its own: the turn that holds it sets the gap above.
    return switch (media.kind) {
      AttachmentKind.image => switch (MediaItem.fromRef(media, api)) {
        final item? => MediaStrip(items: [item]),
        null => chip,
      },
      AttachmentKind.video => play(
        (url, headers) => MediaVideo(url: url, headers: headers),
      ),
      AttachmentKind.audio => play(
        (url, headers) => MediaAudio(url: url, headers: headers),
      ),
      AttachmentKind.file => chip,
    };
  }
}

/// What the file chip's sheet can do with the file.
enum _FileAction { open, save, share }

/// A gateway file: a tap opens it in the phone's default app; the menu
/// (or a long press) opens, saves a copy to a folder, or shares it.
class _FileChip extends ConsumerStatefulWidget {
  const _FileChip({required this.media});

  final MediaRef media;

  @override
  ConsumerState<_FileChip> createState() => _FileChipState();
}

class _FileChipState extends ConsumerState<_FileChip> {
  bool _busy = false;

  String get _name =>
      widget.media.fileName.isEmpty ? widget.media.path : widget.media.fileName;

  bool get _openable => MediaCache.openTypes(_name).isNotEmpty;

  /// Downloads the file once, then does [action]. When no app opens it,
  /// the sheet offers to save or share it instead.
  Future<void> _run(_FileAction action) async {
    if (_busy) return;
    final client = ref.read(hermesClientProvider);
    final api = ref.read(hermesApiProvider);
    final l10n = context.l10n;
    final snacks = AppSnacks.of(context);
    final name = _name;
    var opened = true;
    setState(() => _busy = true);
    try {
      if (client == null || api == null || widget.media.path.isEmpty) {
        throw StateError('no gateway for $name');
      }
      final file = await MediaCache.fetch(client, api, widget.media.path, name);
      switch (action) {
        case _FileAction.open:
          opened = await MediaCache.open(file);
        case _FileAction.save:
          if (await MediaCache.saveAs(file, name)) {
            snacks.show(l10n.attachSaved(name));
          }
        case _FileAction.share:
          await MediaCache.shareFile(file);
      }
    } on Object catch (e) {
      log.w('file ${action.name} failed', error: e);
      snacks.show(
        action == _FileAction.save
            ? l10n.attachSaveFailed(name)
            : l10n.attachDownloadFailed(name),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!opened && mounted) await _offer(title: l10n.attachNoApp(name));
  }

  /// The file's actions. [title] says why the menu came up on its own;
  /// then Open is left out, as it just failed.
  Future<void> _offer({String? title}) async {
    final l10n = context.l10n;
    final action = await showAppMenu<_FileAction>(
      context,
      title: title ?? _name,
      items: [
        if (title == null && _openable)
          AppMenuItem(
            value: _FileAction.open,
            label: l10n.attachOpen,
            icon: CupertinoIcons.arrow_up_right_square,
          ),
        AppMenuItem(
          value: _FileAction.save,
          label: l10n.attachSaveToFiles,
          icon: CupertinoIcons.arrow_down_to_line,
        ),
        AppMenuItem(
          value: _FileAction.share,
          label: l10n.attachShare,
          icon: CupertinoIcons.square_arrow_up,
        ),
      ],
    );
    if (action != null) await _run(action);
  }

  void _tap() => unawaited(
    _openable
        ? _run(_FileAction.open)
        : _offer(title: context.l10n.attachNoApp(_name)),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final text = Theme.of(context).textTheme;
    final path = widget.media.path;
    final size = path.isEmpty ? null : ref.watch(mediaSizeProvider(path)).value;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: AppSurface(
        color: colors.toolSurface,
        border: false,
        // The row's ink spreads to the rounded edge.
        clip: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: _tap,
            onLongPress: () => unawaited(_offer()),
            onSecondaryTap: () => unawaited(_offer()),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: spacing.minTouch),
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: spacing.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: spacing.fileBadge,
                      child: _busy
                          ? const Center(child: AppSpinner())
                          : FileBadge(name: _name, kind: widget.media.kind),
                    ),
                    SizedBox(width: spacing.sm),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodyMedium,
                          ),
                          if (size != null)
                            Text(
                              Format.bytes(context.l10n, size),
                              maxLines: 1,
                              style: text.labelSmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    AppIconButton.plain(
                      icon: CupertinoIcons.ellipsis,
                      tooltip: context.l10n.attachFileActions(_name),
                      color: colors.textSecondary,
                      onPressed: _busy ? null : () => unawaited(_offer()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
