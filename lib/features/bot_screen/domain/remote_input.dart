/// A key of the Screen page's key row, named as the viewer page names it.
enum ScreenKey { escape, tab, enter, backspace, left, up, right, down }

/// A modifier held around the next key or text.
enum ScreenModifier { ctrl, alt }

/// What the soft keyboard typed into the Screen page's hidden field, as
/// keys for the bot's desktop.
///
/// The field always holds [filler], so a backspace has something to delete
/// and the keyboard keeps sending it; each change is compared with the text
/// before, as noVNC's own keyboard does, so an autocorrected word becomes
/// backspaces and the new word.
abstract final class RemoteTyping {
  static final String filler = '_' * 64;

  /// The keys from [before] to [after]: backspaces, then text. Compared by
  /// character, so an emoji is one backspace.
  static ({int backspaces, String text}) diff(String before, String after) {
    final a = before.runes.toList();
    final b = after.runes.toList();
    var same = 0;
    while (same < a.length && same < b.length && a[same] == b[same]) {
      same++;
    }
    return (
      backspaces: a.length - same,
      text: String.fromCharCodes(b.skip(same)),
    );
  }

  /// Whether the field goes back to [filler]: emptied, or grown long.
  static bool spent(String text) =>
      text.isEmpty || text.length > filler.length * 2;
}
