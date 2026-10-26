/// The commands of a Telegram bot chat with Hermes. Anything else typed
/// after a slash is text for the agent.
enum SlashCommand {
  /// A fresh conversation; the old one stays above.
  newConversation('new', aliases: {'reset', 'clear'}),

  /// Restarts the whole gateway, so it asks first.
  restart('restart', confirms: true),

  /// Updates Hermes, then restarts it.
  update('update', confirms: true),

  /// Summarises older turns so the conversation fits its window.
  compact('compact', aliases: {'compress'});

  const SlashCommand(
    this.word, {
    this.aliases = const {},
    this.confirms = false,
  });

  final String word;
  final Set<String> aliases;
  final bool confirms;

  String get slash => '/$word';

  /// Works on the open session, so it needs the chat bound and online.
  bool get needsSession => this == newConversation || this == compact;

  /// The command [text] is, alone; `/clear the cache` is a message.
  static SlashCommand? parse(String text) {
    final body = text.trim();
    if (!isNameQuery(body)) return null;
    final name = body.substring(1).toLowerCase();
    return values
        .where((c) => c.word == name || c.aliases.contains(name))
        .firstOrNull;
  }

  /// A command name still being typed (`/`, `/re`).
  static bool isNameQuery(String text) =>
      text.startsWith('/') && !text.contains(RegExp(r'\s'));

  /// The commands whose word starts with what is typed so far.
  static List<SlashCommand> suggest(String text) => !isNameQuery(text)
      ? const []
      : [
          for (final c in values)
            if (c.word.startsWith(text.substring(1).toLowerCase())) c,
        ];
}
