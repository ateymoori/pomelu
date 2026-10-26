import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../hermes/models/local_attachment.dart';
import '../theme/tokens.dart';

/// A file's type at a glance, as mail and chat apps show it: a tile in the
/// type's color with the name's extension (PDF, DOCX, MD). A name without
/// a short extension shows the [kind]'s glyph instead.
class FileBadge extends StatelessWidget {
  const FileBadge({required this.name, required this.kind, super.key});

  /// The file name; may be empty (a voice note).
  final String name;
  final AttachmentKind kind;

  /// Longer extensions do not fit the tile.
  static const int _maxLabel = 4;

  /// Extensions by type; the rest go by [kind].
  static final Map<String, _Type> _types = {
    for (final (type, names) in [
      (_Type.pdf, 'pdf'),
      (_Type.document, 'doc docx odt rtf pages'),
      (_Type.sheet, 'xls xlsx csv tsv ods numbers'),
      (_Type.slides, 'ppt pptx odp key'),
      (_Type.archive, 'zip rar 7z tar gz tgz bz2 xz'),
      (_Type.text, 'md txt log rst'),
      (
        _Type.code,
        'json yaml yml toml xml html htm css js ts py dart sh swift kt java '
            'c h cpp go rs rb php sql ini',
      ),
    ])
      for (final name in names.split(' ')) name: type,
  };

  @override
  Widget build(BuildContext context) {
    final files = context.colors.files;
    final spacing = context.spacing;
    final dot = name.lastIndexOf('.');
    final ext = dot <= 0 ? '' : name.substring(dot + 1).toLowerCase();
    final type =
        _types[ext] ??
        switch (kind) {
          AttachmentKind.image => _Type.image,
          AttachmentKind.video => _Type.video,
          AttachmentKind.audio => _Type.audio,
          AttachmentKind.file => _Type.other,
        };
    final fill = switch (type) {
      _Type.pdf => files.pdf,
      _Type.document => files.document,
      _Type.sheet => files.sheet,
      _Type.slides => files.slides,
      _Type.archive => files.archive,
      _Type.code => files.code,
      _Type.text => files.text,
      _Type.image => files.image,
      _Type.video => files.video,
      _Type.audio => files.audio,
      _Type.other => files.other,
    };
    final label = ext.isEmpty || ext.length > _maxLabel
        ? Icon(
            switch (kind) {
              AttachmentKind.image => CupertinoIcons.photo_fill,
              AttachmentKind.video => CupertinoIcons.film_fill,
              AttachmentKind.audio => CupertinoIcons.waveform,
              AttachmentKind.file => CupertinoIcons.doc_fill,
            },
            size: spacing.lg,
            color: files.label,
          )
        // The name next to the badge is what is read and scaled; the
        // label only shrinks to fit.
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              ext.toUpperCase(),
              maxLines: 1,
              textScaler: TextScaler.noScaling,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: files.label, fontWeight: FontWeight.w700),
            ),
          );

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: spacing.fileBadge,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: fill,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(context.radii.xs),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(spacing.xxs),
            child: Center(child: label),
          ),
        ),
      ),
    );
  }
}

enum _Type {
  pdf,
  document,
  sheet,
  slides,
  archive,
  code,
  text,
  image,
  video,
  audio,
  other,
}
