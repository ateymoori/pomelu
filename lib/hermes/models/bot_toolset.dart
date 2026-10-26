import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'bot_toolset.freezed.dart';
part 'bot_toolset.g.dart';

/// One group of tools a bot may use, a row of
/// `GET /api/tools/toolsets?profile=`: the same list the Hermes dashboard's
/// Tools page shows.
@freezed
abstract class BotToolset with _$BotToolset {
  const BotToolset._();

  const factory BotToolset({
    @LooseString() @Default('') String name,
    @LooseString() @Default('') String label,
    @LooseString() @Default('') String description,

    @LooseBool() @Default(false) bool enabled,
    @LooseStringList() List<String>? tools,
  }) = _BotToolset;

  factory BotToolset.fromJson(Map<String, dynamic> json) =>
      _$BotToolsetFromJson(json);

  String get title => label.isNotEmpty ? label : name;

  List<String> get toolNames => tools ?? const [];
}
