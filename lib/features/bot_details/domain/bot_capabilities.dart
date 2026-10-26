import '../../../hermes/models/bot_skill.dart';
import '../../../hermes/models/bot_toolset.dart';

/// The skills of one category, ready to list.
class SkillGroup {
  const SkillGroup({required this.category, required this.skills});

  /// The gateway's category folder name; empty for skills in none.
  final String category;
  final List<BotSkill> skills;
}

/// What the details sheet lists: only what the bot has on, as the agent
/// cannot use the rest.
abstract final class BotCapabilities {
  /// Lower-case folder words that read as acronyms.
  static const Map<String, String> _acronyms = {
    'ai': 'AI',
    'ml': 'ML',
    'mlops': 'MLOps',
    'devops': 'DevOps',
    'api': 'API',
    'ui': 'UI',
    'cli': 'CLI',
    'mcp': 'MCP',
    'llm': 'LLM',
    'sql': 'SQL',
    'ios': 'iOS',
    'nlp': 'NLP',
    'tts': 'TTS',
    'stt': 'STT',
  };

  /// By category (the uncategorised last), each sorted by name.
  static List<SkillGroup> groupSkills(List<BotSkill> skills) {
    final byCategory = <String, List<BotSkill>>{};
    for (final skill in skills) {
      if (skill.enabled) (byCategory[skill.category] ??= []).add(skill);
    }
    return [
      for (final e in byCategory.entries)
        SkillGroup(
          category: e.key,
          skills: [...e.value]
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            ),
        ),
    ]..sort((a, b) {
      if (a.category.isEmpty != b.category.isEmpty) {
        return a.category.isEmpty ? 1 : -1;
      }
      return prettyCategory(a.category).compareTo(prettyCategory(b.category));
    });
  }

  /// `software-development` as `Software development`, and
  /// `autonomous-ai-agents` as `Autonomous AI agents`.
  static String prettyCategory(String category) {
    final words = category
        .trim()
        .split(RegExp(r'[-_\s]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    return [
      for (var i = 0; i < words.length; i++)
        _acronyms[words[i].toLowerCase()] ??
            (i == 0
                ? words[i][0].toUpperCase() + words[i].substring(1)
                : words[i]),
    ].join(' ');
  }

  static List<BotToolset> enabledToolsets(List<BotToolset> all) => [
    for (final t in all)
      if (t.enabled) t,
  ]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
}
