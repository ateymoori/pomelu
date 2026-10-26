import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../hermes/models/local_attachment.dart';
import '../data/attachments.dart';
import '../data/chat_store.dart';
import '../domain/chat_target.dart';
import 'chat_controller.dart';

part 'composer_draft.g.dart';

/// What a composer shows besides its words: the files of the turn, and
/// whether a voice note is being turned into text.
typedef ComposerFiles = ({
  List<LocalAttachment> attachments,
  bool transcribing,
});

/// The draft of one chat's composer, kept on the phone while it is written.
/// The words live in the composer's text field and come here to be saved;
/// the files live here.
@riverpod
class ComposerDraftController extends _$ComposerDraftController {
  late ChatStore _store;
  String _text = '';
  Timer? _saving;

  /// The draft waiting for [_saving].
  ComposerDraft? _pending;

  @override
  ComposerFiles build(ChatTarget target) {
    // Read once: the draft belongs to the gateway it was started on.
    _store = ref.read(chatStoreProvider);
    final draft = _store.draft(target.key);
    _text = draft.text;
    ref.onDispose(flush);
    return (
      // A file the system cleared away is gone from the draft too.
      attachments: List.unmodifiable(
        draft.attachments.where((a) => File(a.path).existsSync()),
      ),
      transcribing: false,
    );
  }

  /// The words of the draft, for a composer that opens.
  String savedText() => _text;

  /// The words were edited.
  void typed(String text) {
    if (text == _text) return;
    _text = text;
    _saveSoon();
  }

  /// Adds [picked] while they fit the turn; returns the files left out, whose
  /// copies are deleted.
  List<Refused> admit(List<LocalAttachment> picked) {
    if (picked.isEmpty) return const [];
    final (:accepted, :refused) = Attachments.admit(state.attachments, picked);
    state = (attachments: accepted, transcribing: state.transcribing);
    _saveSoon();
    unawaited(Attachments.discardCopies([for (final r in refused) r.file]));
    return refused;
  }

  void remove(LocalAttachment a) {
    state = (
      attachments: List.unmodifiable(
        state.attachments.where((x) => x.id != a.id),
      ),
      transcribing: state.transcribing,
    );
    _saveSoon();
  }

  /// Empties the draft at once: what it held went out.
  void clear() {
    _text = '';
    state = (attachments: const [], transcribing: state.transcribing);
    _pending = const ComposerDraft();
    flush();
  }

  /// The words of [take], through the gateway; empty when nothing was heard.
  Future<String> transcribe(LocalAttachment take) async {
    state = (attachments: state.attachments, transcribing: true);
    try {
      return (await ref
              .read(chatControllerProvider(target).notifier)
              .transcribe(take))
          .trim();
    } finally {
      if (ref.mounted) {
        state = (attachments: state.attachments, transcribing: false);
      }
    }
  }

  void _saveSoon() {
    _pending = ComposerDraft(text: _text, attachments: state.attachments);
    _saving?.cancel();
    _saving = Timer(AppConfig.composerDraftDebounce, flush);
  }

  /// Saves what waits for the debounce now: the composer is going.
  void flush() {
    _saving?.cancel();
    final draft = _pending;
    _pending = null;
    if (draft != null) unawaited(_store.saveDraft(target.key, draft));
  }
}
