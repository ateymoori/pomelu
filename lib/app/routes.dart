/// Route names and path builders. Keep all paths here.
abstract final class Routes {
  static const String home = '/';
  static const String settings = '/settings';
  static const String connectGuide = '/settings/connect';
  static const String share = '/share';

  static const String chatSegment = 'chat';

  static const String profileParam = 'profile';

  /// `/chat/:profile`, a sibling of [home].
  static const String chat = '/$chatSegment/:$profileParam';

  static String chatPath(String profile) =>
      '/$chatSegment/${Uri.encodeComponent(profile)}';

  /// `/screen/:profile`: a bot's screen, over its chat.
  static const String screen = '/screen/:$profileParam';

  static String screenPath(String profile) =>
      '/screen/${Uri.encodeComponent(profile)}';
}
