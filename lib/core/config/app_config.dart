/// App defaults. Strings live in l10n, visual tokens in the theme, wire
/// constants in `lib/hermes/hermes_constants.dart`.
abstract final class AppConfig {
  /// The app id on every platform; fixed for good after the first upload.
  static const String appId = 'se.royan.pomelu';

  static const String deepLinkScheme = 'pomelu';
  static const String deepLinkChatHost = 'chat';
  static const String deepLinkProfileParam = 'profile';

  /// Pre-fills the composer.
  static const String deepLinkTextParam = 'text';

  /// None: the phone's own loopback is no gateway.
  static const String defaultGatewayUrl = '';

  /// Lines of a message being written before its field scrolls.
  static const int maxComposerLines = 6;

  /// Bots in the app icon's menu: the sidebar's first ones. Android shows
  /// four at most on most launchers, iOS four.
  static const int botShortcuts = 4;

  /// Shortest find query: one character would match most of a transcript.
  static const int minSearchLength = 2;

  /// Schemes a link in a reply may open. The agent writes the links, so an
  /// `intent:`, `file:` or app scheme must not start something on the phone.
  static const Set<String> openableLinkSchemes = {'http', 'https', 'mailto'};

  /// A longer reply is cut into list rows of about this size: one row is
  /// built in one frame.
  static const int replyChunkChars = 800;

  /// Parent links walked to find the conversation before one.
  static const int conversationWalkLimit = 50;

  /// Pages of the bot's conversations read to find a Bot Chat the gateway
  /// moved aside.
  static const int movedAsidePages = 5;

  /// Pause after a failed load of an earlier conversation before scrolling
  /// asks again.
  static const Duration earlierRetryAfter = Duration(seconds: 10);

  /// Undo steps a delete may take past the turns it counted, for rows the
  /// gateway stores per tool call, before it gives up.
  static const int deleteUndoSlack = 3;

  /// Sent (not shown) for a turn of pictures and no words: the agent needs
  /// a question.
  static const String imageOnlyPrompt = 'What do you see in this image?';

  /// Album saved pictures land in.
  static const String galleryAlbum = 'Pomelu';

  /// A bot picture is scaled to fit this edge (px) and saved at this JPEG
  /// quality: small enough for the gateway's asset limit.
  static const double botPictureEdge = 512;
  static const int botPictureQuality = 85;

  /// Visible lines of a free-text answer before the field scrolls.
  static const int clarifyFreeTextLines = 4;

  /// Newest history rows the outbox looks through for its unanswered turns.
  static const int outboxLookback = 40;

  /// How much older than an outbox entry a stored row may be stamped and
  /// still count as it: the phone's and the gateway's clocks differ.
  static const Duration outboxClockSkew = Duration(minutes: 10);

  /// Silent re-sign-ins in a row before the sign-in is left to the user.
  static const int reauthMaxAttempts = 3;

  /// How long "Stay connected" redials an unreachable gateway in the
  /// background before it stops until the app opens or the network changes.
  static const Duration backgroundRedialBudget = Duration(minutes: 10);

  /// How often the system is asked to run the background check for bot
  /// messages: Android's shortest period; iOS treats it as the earliest.
  static const Duration messageCheckEvery = Duration(minutes: 15);

  /// One background check: dial, list the bots, read the chats that moved.
  /// iOS ends a refresh task after about 30 s.
  static const Duration messageCheckBudget = Duration(seconds: 25);

  /// Pause after `sessions.changed` before the app checks, so one burst of
  /// writes is one check.
  static const Duration messageCheckDelay = Duration(seconds: 2);

  /// While on screen, how often the app tells the Pomelu plugin so again.
  /// The plugin counts an app quiet for 10 minutes as away (it may have
  /// left without saying so), and pushes again.
  static const Duration pushPresenceBeat = Duration(minutes: 5);

  /// Newest rows of a chat read for its newest message.
  static const int messageCheckRows = 20;

  /// OpenStreetMap tiles: free, no key. The tile policy wants the app's name
  /// as User-Agent and the attribution on the map.
  static const String mapTiles =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String mapUserAgentPackage = appId;
  static const String mapAttribution = 'OpenStreetMap contributors';
  static const String mapAttributionUrl =
      'https://www.openstreetmap.org/copyright';
  static const double mapWorldZoom = 2;
  static const double mapPlaceZoom = 16;
  static const double mapMaxZoom = 19;

  /// Deepest zoom of a picture in the viewer, in screen fits.
  static const double viewerMaxZoom = 4;

  /// Context-window fill at which the header ring warns, then alarms.
  static const double contextWarnAt = 0.75;
  static const double contextDangerAt = 0.90;

  /// Where the map opens before the phone's location is known.
  static const double mapWorldLatitude = 20;
  static const double mapWorldLongitude = 0;

  /// Digits after the point of a shared coordinate: about 10 cm.
  static const int coordinateDigits = 6;

  /// Lines of the place's address under the map.
  static const int locationAddressLines = 2;

  /// How long a resumed chat polls a hydrating transcript that reads empty.
  static const Duration historyHydrateBudget = Duration(seconds: 12);
  static const Duration historyHydratePoll = Duration(milliseconds: 350);

  /// How long a `session.interrupt` gets to produce its `message.complete`.
  static const Duration interruptGrace = Duration(seconds: 8);

  /// Quiet time after `sessions.changed` before an open chat checks its
  /// transcript: a burst of writes costs one request.
  static const Duration transcriptFollowDelay = Duration(milliseconds: 800);
  static const Duration sidebarRefreshDebounce = Duration(milliseconds: 600);
  static const Duration composerDraftDebounce = Duration(milliseconds: 400);
  static const Duration addressLookupDebounce = Duration(milliseconds: 400);

  /// A geocoder with no network can hang for a minute; Share must not wait.
  static const Duration addressLookupTimeout = Duration(seconds: 6);

  /// Longest the splash waits for preferences and credential.
  static const Duration startupBudget = Duration(seconds: 5);

  /// Media cache files older than this go at startup.
  static const Duration mediaCacheMaxAge = Duration(days: 7);

  /// The longest the "Reading aloud" bar stays; it goes when the reading
  /// ends. Speech of a long reply takes a while to make.
  static const Duration readAloudBar = Duration(minutes: 10);

  /// How long the sidebar waits for a connection before it shows Retry.
  static const Duration rosterConnectTimeout = Duration(seconds: 20);
  static const Duration recordingTick = Duration(seconds: 1);

  /// A shorter hold on the mic is a tap: the take is dropped.
  static const Duration minVoiceTake = Duration(milliseconds: 600);

  /// A take stops by itself after this long, and is kept.
  static const Duration maxVoiceTake = Duration(minutes: 10);

  /// A voice note is AAC in an MPEG-4 file.
  static const String voiceNoteMime = 'audio/mp4';
  static const String voiceNoteExtension = 'm4a';
  static const Duration urlProbeDebounce = Duration(milliseconds: 500);
  static const Duration connectionTestBudget = Duration(seconds: 12);

  /// Wait before the second silent re-sign-in; it doubles after that.
  static const Duration reauthBackoff = Duration(seconds: 2);
  static const Duration linkTitleTimeout = Duration(seconds: 4);

  /// A link title that failed is not asked for again before this.
  static const Duration linkTitleRetryAfter = Duration(minutes: 5);
  static const Duration mediaSaveConnectTimeout = Duration(seconds: 10);
  static const Duration mediaSaveReceiveTimeout = Duration(seconds: 30);

  /// A reported reply is cut to this many characters, so the mailto link
  /// stays within what mail apps take.
  static const int reportExcerptChars = 2000;

  /// Control of a bot's screen is kept this long while the app is away
  /// (a password copied from another app), then handed back to the bot.
  static const Duration screenAwayHandBack = Duration(minutes: 2);

  /// A screen stream that drops is opened again this many times, the
  /// wait growing by [screenReattachDelay]; one that stayed up
  /// [screenStableAfter] starts the count over.
  static const int screenReattachAttempts = 3;
  static const Duration screenReattachDelay = Duration(seconds: 1);
  static const Duration screenStableAfter = Duration(seconds: 10);

  /// Longest clipboard text Paste also types on a bot's screen (it goes
  /// key by key); a longer one only reaches the screen's clipboard.
  static const int screenPasteMaxChars = 2000;
}
