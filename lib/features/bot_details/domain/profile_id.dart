/// Profile ids Hermes keeps for itself.
const Set<String> _reserved = {
  'hermes',
  'default',
  'test',
  'tmp',
  'root',
  'sudo',
};

/// Longest profile id Hermes accepts.
const int _maxLength = 64;

/// A free profile id for a new bot named [title], as Hermes would suggest
/// it: lowercase letters, digits, `-` and `_` ("My Work" is `my-work`). A
/// title with none of those (one in another script) becomes `bot`; a taken
/// or reserved id gets `-2`, `-3`, ... The title itself stays the name.
String profileIdFor(String title, Set<String> taken) {
  final slug = title
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9_-]+'), '-')
      .replaceAll(RegExp(r'^[-_]+|[-_]+$'), '');
  final base = slug.isEmpty
      ? 'bot'
      : slug.substring(0, slug.length.clamp(0, _maxLength - 4));
  bool free(String id) => !taken.contains(id) && !_reserved.contains(id);
  if (free(base)) return base;
  for (var n = 2; ; n++) {
    if (free('$base-$n')) return '$base-$n';
  }
}
