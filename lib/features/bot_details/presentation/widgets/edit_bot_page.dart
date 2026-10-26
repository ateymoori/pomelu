import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/failure_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/hermes_constants.dart';
import '../../../sidebar/presentation/sidebar_providers.dart';
import '../../../sidebar/presentation/widgets/avatar.dart';
import '../bot_edit_providers.dart';
import 'character_grid.dart';

/// What [EditBotPage] did, for the sheet below it.
enum BotEditResult { saved, deleted }

/// A bot's name and picture, and deleting it, laid out as Contacts edits a
/// contact: the picture with Edit under it, the name in a card, delete as a
/// red row of its own. A page, as a route can refuse to close over unsaved
/// work and a sheet's drag cannot.
class EditBotPage extends ConsumerStatefulWidget {
  const EditBotPage({required this.profile, super.key});

  final String profile;

  @override
  ConsumerState<EditBotPage> createState() => _EditBotPageState();
}

class _EditBotPageState extends ConsumerState<EditBotPage> {
  late final String _initialName =
      ref
          .read(profilesProvider)
          .value
          ?.where((p) => p.name == widget.profile)
          .firstOrNull
          ?.botMeta
          ?.title ??
      '';
  late final TextEditingController _name = TextEditingController(
    text: _initialName,
  )..addListener(() => setState(() {}));
  PictureEdit? _picture;

  /// The ready-made picture [_picture] holds, if it is one.
  String? _character;

  bool get _dirty => _name.text.trim() != _initialName || _picture != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final l10n = context.l10n;
    final snacks = AppSnacks.of(context);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConfig.botPictureEdge,
        maxHeight: AppConfig.botPictureEdge,
        imageQuality: AppConfig.botPictureQuality,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > HermesLimits.maxAvatarBytes) {
        snacks.show(l10n.botEditPhotoTooLarge);
        return;
      }
      if (mounted) {
        setState(() {
          _picture = SetPicture(bytes);
          _character = null;
        });
      }
    } on PlatformException catch (e) {
      log.w('photo picker failed', error: e);
      snacks.show(l10n.botEditPhotoFailed);
    }
  }

  Future<void> _pickCharacter(String asset) async {
    final data = await rootBundle.load(asset);
    if (!mounted) return;
    setState(() {
      _picture = SetPicture(data.buffer.asUint8List());
      _character = asset;
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final saved = await ref
        .read(botEditProvider(widget.profile).notifier)
        .save(title: name == _initialName ? null : name, picture: _picture);
    if (saved && mounted) Navigator.of(context).pop(BotEditResult.saved);
  }

  Future<void> _delete(String title) async {
    final l10n = context.l10n;
    final go = await showConfirmDialog(
      context,
      title: l10n.botDeleteTitle(title),
      body: l10n.botDeleteBody,
      confirmLabel: l10n.botDelete,
    );
    if (!go || !mounted) return;
    final deleted = await ref
        .read(botEditProvider(widget.profile).notifier)
        .delete();
    if (deleted && mounted) Navigator.of(context).pop(BotEditResult.deleted);
  }

  Future<void> _confirmDiscard() async {
    final discard = await confirmDiscard(
      context,
      body: context.l10n.botEditDiscardBody,
    );
    if (discard && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final edit = ref.watch(botEditProvider(widget.profile));
    final busy = edit.isLoading;
    final profile = ref.watch(
      profilesProvider.select(
        (bots) =>
            bots.value?.where((b) => b.name == widget.profile).firstOrNull,
      ),
    );
    final title = ref.watch(botTitleProvider(widget.profile));
    final shownName = _name.text.trim().isEmpty
        ? (profile?.displayName.isNotEmpty ?? false)
              ? profile!.displayName
              : widget.profile
        : _name.text.trim();
    final hasPicture = switch (_picture) {
      SetPicture() => true,
      RemovePicture() => false,
      null => ref.watch(profileAvatarProvider(widget.profile)).value != null,
    };

    return PopScope(
      // A save or delete in flight cannot be undone: stay until it answers.
      canPop: !_dirty && !busy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !busy) unawaited(_confirmDiscard());
      },
      child: Scaffold(
        backgroundColor: context.surfaces.grouped,
        extendBodyBehindAppBar: true,
        appBar: readingAppBar(
          context,
          title: l10n.botEdit,
          onClose: () => Navigator.of(context).maybePop(),
          action: AppIconButton(
            icon: CupertinoIcons.checkmark,
            tooltip: l10n.botEditSave,
            busy: busy,
            onPressed: _dirty && !busy ? _save : null,
          ),
        ),
        // Under the Scaffold, so the top inset includes the glass bar.
        body: Builder(
          builder: (context) {
            final spacing = context.spacing;
            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top + spacing.lg,
                  bottom: spacing.xxl,
                ),
                child: ReadingColumn(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: switch (_picture) {
                          SetPicture(:final bytes) => HermesAvatar(
                            name: shownName,
                            image: MemoryImage(bytes),
                            diameter: spacing.avatarLg,
                          ),
                          RemovePicture() => HermesAvatar(
                            name: shownName,
                            diameter: spacing.avatarLg,
                          ),
                          null => BotAvatar(
                            name: widget.profile,
                            title: shownName,
                            diameter: spacing.avatarLg,
                          ),
                        },
                      ),
                      SizedBox(height: spacing.lg),
                      FormSection(
                        footer: l10n.botEditProfileId(widget.profile),
                        children: [
                          // The placeholder names the row, as in Contacts;
                          // the label names it for a screen reader.
                          Semantics(
                            label: l10n.botEditName,
                            child: TextField(
                              controller: _name,
                              enabled: !busy,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(hintText: title),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.xl),
                      FormSection(
                        header: l10n.botEditPicture,
                        children: [
                          FormButtonRow(
                            label: l10n.botEditChoosePhoto,
                            onPressed: busy
                                ? null
                                : () => unawaited(_choosePhoto()),
                          ),
                          if (hasPicture)
                            FormButtonRow(
                              label: l10n.botEditRemovePhoto,
                              destructive: true,
                              onPressed: busy
                                  ? null
                                  : () => setState(() {
                                      _picture = const RemovePicture();
                                      _character = null;
                                    }),
                            ),
                        ],
                      ),
                      SizedBox(height: spacing.xl),
                      FormSection(
                        header: l10n.botEditCharacters,
                        children: [
                          CharacterGrid(
                            selected: _character,
                            onPick: (asset) => unawaited(_pickCharacter(asset)),
                          ),
                        ],
                      ),
                      if (edit.error case final error?) ...[
                        SizedBox(height: spacing.sm),
                        ErrorText(
                          l10n.botEditSaveFailed(failureText(context, error)),
                        ),
                      ],
                      if (profile != null && !profile.isDefault) ...[
                        SizedBox(height: spacing.xl),
                        FormSection(
                          children: [
                            FormButtonRow(
                              label: l10n.botDelete,
                              destructive: true,
                              onPressed: busy ? null : () => _delete(title),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
