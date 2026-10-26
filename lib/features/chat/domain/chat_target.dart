import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_target.freezed.dart';

/// What the user opened: a bot's one chat, its canonical "Bot Chat". Like a
/// Telegram bot chat, there is no second conversation with the same bot; a
/// new conversation starts inside it (see `SlashActions.startsOver`).
@Freezed(copyWith: false)
sealed class ChatTarget with _$ChatTarget {
  const ChatTarget._();

  const factory ChatTarget.bot(String profile) = BotTarget;

  static const String _botPrefix = 'bot:';

  /// Stable key for providers and composer drafts.
  String get key => switch (this) {
    BotTarget(:final profile) => '$_botPrefix$profile',
  };

  /// The target whose [key] is [key], or null when it names none.
  static ChatTarget? fromKey(String key) =>
      key.startsWith(_botPrefix) && key.length > _botPrefix.length
      ? ChatTarget.bot(key.substring(_botPrefix.length))
      : null;
}
