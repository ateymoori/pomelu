/// Asset paths. Keep in sync with `pubspec.yaml`.
abstract final class Assets {
  static const String _characters = 'assets/characters';

  static const String logo = 'assets/images/pomelu_logo.png';

  /// Ready-made bot pictures (512 px WebP), offered on the edit bot page.
  static const List<String> botCharacters = [
    '$_characters/01-pomelu.webp',
    '$_characters/02-boss.webp',
    '$_characters/03-alfred.webp',
    '$_characters/04-hermes-girl.webp',
    '$_characters/05-red-pony.webp',
    '$_characters/06-blue-pony.webp',
    '$_characters/07-felipe.webp',
    '$_characters/08-iggy.webp',
    '$_characters/09-jojo.webp',
    '$_characters/10-peach.webp',
    '$_characters/11-todd.webp',
    '$_characters/12-clawd.webp',
    '$_characters/13-deepseek.webp',
    '$_characters/14-grok.webp',
    '$_characters/15-chatgpt.webp',
    '$_characters/16-gemini.webp',
    '$_characters/17-gemini-twins.webp',
    '$_characters/18-llama.webp',
    '$_characters/19-hugging-face.webp',
    '$_characters/20-hugging-face-2.webp',
    '$_characters/21-perplexity.webp',
    '$_characters/22-perplexity-2.webp',
    '$_characters/23-google-search.webp',
    '$_characters/24-midjourney.webp',
    '$_characters/25-hallucination.webp',
    '$_characters/26-hot-gpu.webp',
    '$_characters/27-business.webp',
    '$_characters/28-money.webp',
    '$_characters/29-homework.webp',
    '$_characters/30-school.webp',
    '$_characters/31-studying.webp',
    '$_characters/32-teacher.webp',
  ];

  /// The Bot Screen viewer: noVNC and its driver in one page, built by
  /// `tool/bot_screen/build.mjs`.
  static const String botScreenPage = 'assets/bot_screen/screen.html';

  /// Notices of what ships as files, not packages (license page): the OFL
  /// of the fonts, and noVNC and pako in the screen viewer.
  static const List<({String name, String asset})> bundledLicenses = [
    (name: 'Inter', asset: 'assets/fonts/Inter-OFL.txt'),
    (name: 'JetBrains Mono', asset: 'assets/fonts/JetBrainsMono-OFL.txt'),
    (name: 'noVNC', asset: 'assets/bot_screen/noVNC-LICENSE.txt'),
    (name: 'pako', asset: 'assets/bot_screen/pako-LICENSE.txt'),
  ];
}
