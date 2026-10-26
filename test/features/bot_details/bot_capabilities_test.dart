import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/bot_details/domain/bot_capabilities.dart';
import 'package:hermes/hermes/models/bot_skill.dart';
import 'package:hermes/hermes/models/bot_toolset.dart';

import '../../support/fixtures.dart';

void main() {
  final skills = fixtureList('skills.json', BotSkill.fromJson);
  final sets = fixtureList('toolsets.json', BotToolset.fromJson);

  group('groupSkills', () {
    test('lists only the skills the bot has on, grouped and sorted', () {
      final groups = BotCapabilities.groupSkills(skills);
      expect(groups.map((g) => g.category), [
        'github',
        'productivity',
        'software-development',
        '', // uncategorised last
      ]);
      expect(groups.expand((g) => g.skills).any((s) => !s.enabled), isFalse);
      final dev = groups.firstWhere(
        (g) => g.category == 'software-development',
      );
      // Case-insensitive: "daily-report" before "Systematic-Debugging".
      expect(dev.skills.map((s) => s.name), [
        'daily-report',
        'Systematic-Debugging',
      ]);
    });

    test('prettyCategory', () {
      expect(
        BotCapabilities.prettyCategory('software-development'),
        'Software development',
      );
      expect(BotCapabilities.prettyCategory('mlops'), 'MLOps');
      expect(
        BotCapabilities.prettyCategory('autonomous-ai-agents'),
        'Autonomous AI agents',
      );
      expect(BotCapabilities.prettyCategory('ai-tools'), 'AI tools');
      expect(BotCapabilities.prettyCategory(''), '');
    });
  });

  group('toolsets', () {
    test('only the ones that are on, by title', () {
      expect(BotCapabilities.enabledToolsets(sets).map((t) => t.name), [
        'file',
        'terminal',
        'web',
      ]);
    });
  });
}
