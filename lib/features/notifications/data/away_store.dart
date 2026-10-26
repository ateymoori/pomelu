import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/app_logger.dart';
import '../../settings/domain/preference_keys.dart';

/// What the app has seen of one bot's chat: its message count, and the time
/// up to which its messages are shown or notified. The count, not the
/// chat's `last_active`, tells that the chat moved: Hermes stamps that at the
/// start of a turn, not when its reply lands.
@immutable
class ChatMark {
  const ChatMark(this.at, this.count);

  final DateTime at;
  final int count;
}

/// What the message check remembers between runs: since when the app is
/// away, and a [ChatMark] per bot. The app and the background check both
/// write it, each from its own isolate, so it is read from disk every time
/// (no cache).
abstract interface class AwayStore {
  /// When the app left the screen; null while it is in front.
  Future<DateTime?> awaySince();

  /// Marks the app away from [since], or back in front with null.
  Future<void> setAwaySince(DateTime? since);

  /// The marks of [account]'s bots.
  Future<Map<String, ChatMark>> marks(String account);

  /// Replaces what [marks] answers for [account]; another account's go.
  Future<void> saveMarks(String account, Map<String, ChatMark> marks);
}

class PrefsAwayStore implements AwayStore {
  PrefsAwayStore([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  static const String _account = 'account';
  static const String _bots = 'bots';

  @override
  Future<DateTime?> awaySince() async {
    final ms = await _prefs.getInt(PreferenceKeys.awaySince);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  @override
  Future<void> setAwaySince(DateTime? since) => since == null
      ? _prefs.remove(PreferenceKeys.awaySince)
      : _prefs.setInt(PreferenceKeys.awaySince, since.millisecondsSinceEpoch);

  @override
  Future<Map<String, ChatMark>> marks(String account) async {
    final raw = await _prefs.getString(PreferenceKeys.chatMarks);
    if (raw == null) return {};
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json[_account] != account) return {};
      return {
        for (final MapEntry(:key, :value)
            in (json[_bots] as Map<String, dynamic>).entries)
          if (value case [final int at, final int count])
            key: ChatMark(DateTime.fromMillisecondsSinceEpoch(at), count),
      };
    } on Object catch (e) {
      log.w('chat marks unreadable (${e.runtimeType})');
      return {};
    }
  }

  @override
  Future<void> saveMarks(String account, Map<String, ChatMark> marks) =>
      _prefs.setString(
        PreferenceKeys.chatMarks,
        jsonEncode({
          _account: account,
          _bots: {
            for (final MapEntry(:key, :value) in marks.entries)
              key: [value.at.millisecondsSinceEpoch, value.count],
          },
        }),
      );
}
