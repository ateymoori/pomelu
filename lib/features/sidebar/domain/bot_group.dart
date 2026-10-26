import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../hermes/models/profile.dart';

part 'bot_group.freezed.dart';

/// One sidebar row: a bot, and whether it works right now.
@freezed
abstract class BotGroup with _$BotGroup {
  const BotGroup._();

  const factory BotGroup({
    required HermesProfile profile,
    @Default(false) bool working,
  }) = _BotGroup;

  String get name => profile.name;
  String get title => profile.title;

  /// The visible bots: the default one first, then the most recently active.
  static List<BotGroup> build({
    required List<HermesProfile> profiles,
    required DateTime now,
    required Duration workerFreshness,
  }) {
    final groups = [
      for (final p in profiles)
        if (!p.isHidden)
          BotGroup(profile: p, working: p.isWorking(now, workerFreshness)),
    ];
    groups.sort((a, b) {
      if (a.profile.isDefault != b.profile.isDefault) {
        return a.profile.isDefault ? -1 : 1;
      }
      final ta = a.profile.lastActivity?.millisecondsSinceEpoch ?? 0;
      final tb = b.profile.lastActivity?.millisecondsSinceEpoch ?? 0;
      return tb.compareTo(ta);
    });
    return groups;
  }
}
