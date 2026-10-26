import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/models/local_attachment.dart';

/// The shared items: square picture tiles like the chat's, pills for the
/// rest.
class SharePreviewStrip extends StatelessWidget {
  const SharePreviewStrip({required this.files, super.key});

  final List<LocalAttachment> files;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < files.length; i++) ...[
            if (i > 0) SizedBox(width: spacing.sm),
            _item(context, files[i]),
          ],
        ],
      ),
    );
  }

  Widget _item(BuildContext context, LocalAttachment file) {
    final path = file.thumbnailPath ?? file.path;
    if (file.isImage || file.thumbnailPath != null) {
      return _Tile(file: file, path: path);
    }
    return _Chip(file: file);
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.file, required this.path});

  final LocalAttachment file;
  final String path;

  @override
  Widget build(BuildContext context) => MediaTile(
    image: FileImage(File(path)),
    label: file.name,
    errorBuilder: (_) => _Chip(file: file),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.file});

  final LocalAttachment file;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return AppSurface(
      borderRadius: BorderRadius.circular(context.radii.md),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FileBadge(name: file.name, kind: file.kind),
          SizedBox(width: spacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: spacing.attachmentLabelMaxWidth,
                ),
                child: Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                Format.bytes(context.l10n, file.sizeBytes),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
