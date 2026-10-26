import 'dart:convert';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../hermes/api/hermes_api.dart';
import '../../../hermes/hermes_failure.dart';
import '../../../hermes/models/profile.dart';
import '../../connection/presentation/connection_providers.dart';
import '../../sidebar/presentation/sidebar_providers.dart';
import '../domain/profile_id.dart';

part 'bot_edit_providers.g.dart';

/// A change to a bot's picture.
sealed class PictureEdit {
  const PictureEdit();
}

/// A new picture: JPEG, PNG or WebP bytes.
final class SetPicture extends PictureEdit {
  const SetPicture(this.bytes);

  final Uint8List bytes;
}

/// Back to the letter.
final class RemovePicture extends PictureEdit {
  const RemovePicture();
}

HermesApi _connected(Ref ref) =>
    ref.read(hermesApiProvider) ?? (throw NetworkFailure.notConnected);

/// Renames bot [profile], changes its picture, or deletes it. Each answers
/// true once the gateway has it; a failure stays in the state.
@riverpod
class BotEdit extends _$BotEdit {
  @override
  AsyncValue<void> build(String profile) => const AsyncData(null);

  /// Writes what is not null: the [title] (empty shows the profile id
  /// again) and the [picture].
  Future<bool> save({String? title, PictureEdit? picture}) => _run((api) async {
    if (title != null) await api.setBotTitle(profile, title);
    switch (picture) {
      case SetPicture(:final bytes):
        await api.setAvatar(profile, base64Encode(bytes));
      case RemovePicture():
        await api.setAvatar(profile, null);
      case null:
    }
    if (picture != null) ref.invalidate(profileAvatarProvider(profile));
  });

  /// Deletes the bot with its chats, memory and files.
  Future<bool> delete() => _run((api) => api.deleteProfile(profile));

  Future<bool> _run(Future<void> Function(HermesApi api) act) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    try {
      await act(_connected(ref));
      await ref.read(profilesProvider.notifier).refresh();
      if (ref.mounted) state = const AsyncData(null);
      return true;
    } on HermesFailure catch (e, st) {
      if (ref.mounted) state = AsyncError(e, st);
      return false;
    }
  }
}

/// Creates a bot named [title]: a free profile id from it, and the title as
/// its name when the two differ. The new id once the gateway has it, else
/// null with the failure in the state.
@riverpod
class BotCreate extends _$BotCreate {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<String?> create(String title) async {
    final name = title.trim();
    if (name.isEmpty || state.isLoading) return null;
    state = const AsyncLoading();
    try {
      final api = _connected(ref);
      final taken = {
        for (final p in ref.read(profilesProvider).value ?? <HermesProfile>[])
          p.name,
      };
      final id = profileIdFor(name, taken);
      await api.createProfile(id);
      if (name != id) await api.setBotTitle(id, name);
      await ref.read(profilesProvider.notifier).refresh();
      if (ref.mounted) state = const AsyncData(null);
      return id;
    } on HermesFailure catch (e, st) {
      if (ref.mounted) state = AsyncError(e, st);
      return null;
    }
  }
}
