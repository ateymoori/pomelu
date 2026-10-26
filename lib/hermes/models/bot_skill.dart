import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'bot_skill.freezed.dart';
part 'bot_skill.g.dart';

/// One skill of a bot, a row of `GET /api/skills?profile=`: the same list the
/// Hermes dashboard's Skills page shows.
@freezed
abstract class BotSkill with _$BotSkill {
  const factory BotSkill({
    @LooseString() @Default('') String name,
    @LooseString() @Default('') String description,

    @LooseString() @Default('') String category,

    @LooseBool() @Default(true) bool enabled,
  }) = _BotSkill;

  factory BotSkill.fromJson(Map<String, dynamic> json) =>
      _$BotSkillFromJson(json);
}
