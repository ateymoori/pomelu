import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'bot_soul.freezed.dart';
part 'bot_soul.g.dart';

/// A bot's `SOUL.md`: the standing instructions Hermes puts first in its
/// system prompt. The answer of `GET /api/profiles/{name}/soul`.
@freezed
abstract class BotSoul with _$BotSoul {
  const BotSoul._();

  const factory BotSoul({
    @LooseString() @Default('') String content,

    /// False when the bot has no `SOUL.md`; Hermes then uses its own default
    /// identity.
    @LooseBool() @Default(false) bool exists,
  }) = _BotSoul;

  factory BotSoul.fromJson(Map<String, dynamic> json) =>
      _$BotSoulFromJson(json);

  /// Whether there is any text. A file of blanks counts as none, as it does for
  /// Hermes.
  bool get isBlank => content.trim().isEmpty;
}
