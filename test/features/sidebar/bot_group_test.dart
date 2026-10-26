import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/sidebar/domain/bot_group.dart';
import 'package:hermes/hermes/models/profile.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1, 12);
  const freshness = Duration(minutes: 2);

  HermesProfile bot(
    String name, {
    bool isDefault = false,
    int? minutesAgo,
    bool hidden = false,
    int? workerMinutesAgo,
  }) => HermesProfile(
    name: name,
    isDefault: isDefault,
    canonicalSession: minutesAgo == null
        ? null
        : CanonicalSession(
            lastActive: now.subtract(Duration(minutes: minutesAgo)),
          ),
    workerSession: workerMinutesAgo == null
        ? null
        : WorkerSession(
            lastActive: now.subtract(Duration(minutes: workerMinutesAgo)),
          ),
    uiMeta: hidden
        ? const {
            'hermes-bots': {'hidden': true},
          }
        : null,
  );

  List<String> names(List<BotGroup> groups) => [for (final g in groups) g.name];

  test('the default bot leads, then the most recently active', () {
    final groups = BotGroup.build(
      profiles: [
        bot('old', minutesAgo: 30),
        bot('never'),
        bot('main', isDefault: true, minutesAgo: 90),
        bot('new', minutesAgo: 1),
      ],
      now: now,
      workerFreshness: freshness,
    );
    expect(names(groups), ['main', 'new', 'old', 'never']);
  });

  test('hidden bots stay out of the list', () {
    final groups = BotGroup.build(
      profiles: [bot('shown'), bot('secret', hidden: true)],
      now: now,
      workerFreshness: freshness,
    );
    expect(names(groups), ['shown']);
  });

  test('a fresh worker heartbeat marks the bot as working', () {
    final groups = BotGroup.build(
      profiles: [
        bot('busy', workerMinutesAgo: 1),
        bot('stale', workerMinutesAgo: 5),
      ],
      now: now,
      workerFreshness: freshness,
    );
    expect(
      {for (final g in groups) g.name: g.working},
      {'busy': true, 'stale': false},
    );
  });
}
