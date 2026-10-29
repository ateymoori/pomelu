import 'hermes_failure.dart';

/// Gateway paths, relative to its base URL (which may carry a proxy prefix).
abstract final class HermesPaths {
  static const String root = '';
  static const String status = 'api/status';
  static const String ws = 'api/ws';
  static const String authProviders = 'api/auth/providers';
  static const String passwordLogin = 'auth/password-login';
  static const String nativeRefresh = 'auth/native/refresh';
  static const String wsTicket = 'api/auth/ws-ticket';
  static const String audioTranscribe = 'api/audio/transcribe';
  static const String audioSpeak = 'api/audio/speak';
  static const String filesDownload = 'api/files/download';
  static const String filesStream = 'api/files/stream';
  static const String skills = 'api/skills';
  static const String toolsets = 'api/tools/toolsets';
  static const String cronJobs = 'api/cron/jobs';
  static const String gatewayRestart = 'api/gateway/restart';
  static const String hermesUpdate = 'api/hermes/update';
  static const String hermesUpdateCheck = 'api/hermes/update/check';

  /// The Bot Screen's raw RFB stream, opened with a `display.observe`
  /// ticket alone ([HermesProtocol.displayTicketParam]).
  static const String displayWs = 'api/display/ws';
  static const String sessions = 'api/sessions';
  static String session(String storedId) => '$sessions/${_seg(storedId)}';
  static String sessionMessages(String storedId) =>
      '${session(storedId)}/messages';
  static String profile(String name) => 'api/profiles/${_seg(name)}';
  static String profileSoul(String profile) =>
      'api/profiles/${_seg(profile)}/soul';
  static String cronJob(String id, [String? action]) =>
      '$cronJobs/${_seg(id)}${action == null ? '' : '/$action'}';
  static String actionStatus(String name) => 'api/actions/${_seg(name)}/status';

  /// [id] as one path segment; a dot segment would climb out of it.
  static String _seg(String id) {
    if (id.isEmpty || id == '.' || id == '..') {
      throw ProtocolFailure('not a usable id in a path: "$id"');
    }
    return Uri.encodeComponent(id);
  }
}

/// How long the SDK waits.
abstract final class HermesTimeouts {
  static const Duration http = Duration(seconds: 15);
  static const Duration rpc = Duration(seconds: 30);
  static const Duration rpcStartup = Duration(seconds: 60);
  static const Duration slashExec = Duration(seconds: 90);
  static const Duration actionPoll = Duration(seconds: 2);
  static const Duration gatewayRestart = Duration(minutes: 5);

  static const Duration hermesUpdate = Duration(minutes: 30);
  static const Duration cronRun = Duration(minutes: 10);
  static const Duration compress = Duration(minutes: 3);

  /// `display.start` answers once Xvnc and the desktop are up.
  static const Duration screenStart = Duration(minutes: 2);

  /// Creating a bot copies keys and skills; deleting one first stops its
  /// running gateway.
  static const Duration profileChange = Duration(minutes: 1);
  static const Duration rpcSubmit = Duration(minutes: 30);
  static const Duration rpcReplay = Duration(seconds: 10);
  static const Duration rpcLiveness = Duration(seconds: 5);
  static const Duration wsConnect = Duration(seconds: 15);
  static const Duration heartbeatInterval = Duration(seconds: 15);
  static const Duration heartbeatDeadline = Duration(seconds: 45);

  /// Heartbeat deadline while an upload keeps the socket busy.
  static const Duration bulkLivenessDeadline = Duration(minutes: 2);
  static const Duration backoffInitial = Duration(milliseconds: 300);
  static const Duration backoffMax = Duration(seconds: 15);
  static const Duration backoffLongMax = Duration(minutes: 1);
  static const Duration backoffStable = Duration(seconds: 10);
  static const Duration gatewayReady = Duration(seconds: 10);
  static const Duration upload = Duration(minutes: 5);
  static const Duration transcribe = Duration(minutes: 3);

  /// Text to speech: a long reply is spoken in chunks, one after the other.
  static const Duration speak = Duration(minutes: 3);
  static const Duration workerFreshness = Duration(seconds: 90);
  static const Duration refreshSkew = Duration(minutes: 1);
}

/// Size and count limits, most of them the gateway's own.
abstract final class HermesLimits {
  static const int storedMessagesPage = 500;
  static const int actionLogLines = 40;
  static const int maxImageBytes = 25 * 1024 * 1024;
  static const int maxFileBytes = 50 * 1024 * 1024;
  static const int maxAudioBytes = 25 * 1024 * 1024;
  static const int maxAttachmentsPerMessage = 10;

  /// All attachments of one turn together: each rides in one RPC frame.
  static const int maxTotalAttachmentBytes = 64 * 1024 * 1024;
  static const int maxChoiceChars = 8000;
  static const int terminalCols = 96;
  static const int backoffLongAfter = 10;
  static const int actionPollMaxFailures = 150;

  /// "Not running, no exit code" polls in a row: the action is lost.
  static const int actionNoResultPolls = 30;
  static const int heldEventsMax = 2000;
  static const int sessionRefCache = 256;
  static const int offloadJsonBytes = 512 * 1024;
  static const int closeReasonChars = 160;

  /// Rows `session.list` returns for a title lookup.
  static const int titleLookupRows = 5;

  /// Rows of one `GET /api/sessions` page, the gateway's most.
  static const int sessionListPage = 100;

  /// A bot picture the gateway stores (`profiles.set_asset`).
  static const int maxAvatarBytes = 2000000;

  /// Tries of a bot-title write that another client keeps beating.
  static const int metaWriteAttempts = 3;

  /// Most a paste onto a Bot Screen's clipboard may hold, in UTF-8 bytes
  /// (Xvnc's `-MaxCutText`); more closes the stream.
  static const int screenClipboardBytes = 256 * 1024;
}

/// HTTP status codes the SDK and the app react to.
abstract final class HermesHttpStatus {
  /// Bad request; also the Host guard's answer.
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int payloadTooLarge = 413;
}

/// Protocol values the app and the SDK share.
abstract final class HermesProtocol {
  static const String minGatewayVersion = '0.21.5';
  static const String botChatTitle = 'Bot Chat';

  /// The source the app's sessions carry: Hermes' own label for a graphical
  /// chat client. A source it does not know (this app's old [legacySource])
  /// makes the gateway move a Bot Chat aside, as [movedAsidePrefix], the
  /// first time it delivers into it (a cron job, another bot).
  static const String sourceName = 'gui';
  static const String legacySource = 'mobile';

  /// Title start of a Bot Chat the gateway moved aside, followed by the
  /// source and the session id.
  static const String movedAsidePrefix = 'Bot Chat (';
  static const String compressionEndReason = 'compression';
  static const String soulFile = 'SOUL.md';

  /// The `ui_meta` key Hermes Desktop keeps a bot's title and look under.
  static const String botsMetaKey = 'hermes-bots';
  static const String avatarAsset = 'avatar';
  static const String basicProvider = 'basic';
  static const String imageRefPrefix = '@image:';
  static const String mediaLinePrefix = 'MEDIA:';
  static const String actionGatewayRestart = 'gateway-restart';
  static const String actionHermesUpdate = 'hermes-update';
  // dart format off
  static const List<String> reasoningEfforts = [
    'none', 'minimal', 'low', 'medium', 'high', 'xhigh', 'max', 'ultra',
  ];

  /// Query parameters and cookies whose value is a secret.
  static const List<String> secretParams = [
    'token', 'ticket', 'access_token', 'refresh_token', 'password',
    displayTicketParam, sessionAccessCookie, sessionRefreshCookie,
  ];
  // dart format on

  static const String jsonRpcVersion = '2.0';

  /// WebSocket subprotocol of a ticket dial; the ticket rides in a second
  /// one, after [wsTicketProtocolPrefix].
  static const String wsSubprotocol = 'hermes-gateway-v1';
  static const String wsTicketProtocolPrefix = 'hermes-gateway-ticket.';

  /// Close codes of a socket the gateway refused the credential on.
  static const Set<int> authCloseCodes = {4401, 4403, 4408};

  /// Cookies of a password login (a `__Host-` / `__Secure-` prefix dropped).
  static const String sessionAccessCookie = 'hermes_session_at';
  static const String sessionRefreshCookie = 'hermes_session_rt';
  static const String sessionProviderCookie = 'hermes_session_provider';

  /// The script global an un-gated dashboard's index page sets its session
  /// token in, and the header that token goes out in.
  static const String sessionTokenGlobal = '__HERMES_SESSION_TOKEN__';
  static const String sessionTokenHeader = 'X-Hermes-Session-Token';
  static const int errSessionNotFound = 4001;
  static const int errSessionGone = 4007;
  static const int errImageTooLarge = 4018;

  /// `session.title` refused the title; the text tells a conflict
  /// ([titleInUseMarker]) from a bad title.
  static const int errTitleRejected = 4022;
  static const String titleInUseMarker = 'already in use';

  /// `prompt.submit` refused the turn: another gateway process has this chat
  /// open ([sessionNotOwned]), or the gateway holds as many chats as it may
  /// (`data.reason`).
  static const int errSessionBusy = 4090;
  static const String sessionNotOwned = 'SESSION_NOT_OWNED';
  static const int errMethodNotFound = -32601;
  static const int errInvalidParams = -32602;

  /// JSON-RPC answer to a server request whose handler failed.
  static const int errServer = -32000;

  /// Answer to a desktop-window request: "this client does not show it", so
  /// a desktop on the same session can still take it.
  static const int errNotShown = 4404;

  /// Every refused `display.*` call; `data.code` [viewerMismatch] when the
  /// viewer id is not this socket's, or another viewer holds control.
  static const int errDisplay = 5300;
  static const String viewerMismatch = 'viewer_mismatch';

  /// Query parameter of the Bot Screen stream's single-use ticket.
  static const String displayTicketParam = 'display_ticket';

  /// A lease names its holder by the first hex digits of the SHA-256 of
  /// the viewer id; the id itself never leaves the gateway.
  static const int viewerHashChars = 12;

  /// Close codes of the Bot Screen stream: another viewer took control
  /// from this one, the screen stopped. Any other close (a spent ticket's
  /// 4401 too) is a lost stream, attached again.
  static const int screenControlTaken = 4000;
  static const int screenStopped = 4001;

  /// Codes this client closes the stream with: [screenHandBack] hands
  /// control back at the gateway, [screenKeep] keeps it for a viewer that
  /// comes back (any code but 1000 and 1001 does).
  static const int screenHandBack = 1000;
  static const int screenKeep = 4100;
}

/// JSON-RPC methods the client calls, and the one notification it reads.
abstract final class HermesMethods {
  static const String event = 'event';
  static const String ping = 'ping';
  static const String gatewayPing = 'gateway.ping';
  static const String clientCapabilities = 'client.capabilities';
  static const String profilesList = 'profiles.list';
  static const String profilesGetAsset = 'profiles.get_asset';
  static const String profilesSetAsset = 'profiles.set_asset';
  static const String profilesConfigure = 'profiles.configure';
  static const String profilesCreate = 'profiles.create';
  static const String sessionList = 'session.list';
  static const String sessionCreate = 'session.create';
  static const String sessionResume = 'session.resume';
  static const String sessionActivate = 'session.activate';
  static const String sessionClose = 'session.close';
  static const String sessionEventsSince = 'session.events.since';
  static const String sessionUndo = 'session.undo';
  static const String sessionHistory = 'session.history';
  static const String sessionTitle = 'session.title';
  static const String sessionArchive = 'session.archive';
  static const String sessionCompress = 'session.compress';
  static const String sessionContextBreakdown = 'session.context_breakdown';
  static const String sessionInterrupt = 'session.interrupt';
  static const String promptSubmit = 'prompt.submit';
  static const String imageAttachBytes = 'image.attach_bytes';
  static const String fileAttach = 'file.attach';
  static const String modelOptions = 'model.options';
  static const String slashExec = 'slash.exec';
  static const String configSet = 'config.set';
  static const String displayStatus = 'display.status';
  static const String displayStart = 'display.start';
  static const String displayThumbnail = 'display.thumbnail';
  static const String displayObserve = 'display.observe';
  static const String displayLeaseAcquire = 'display.lease.acquire';
  static const String displayLeaseRelease = 'display.lease.release';
}

/// Wire values of an approval's choices.
abstract final class ApprovalChoices {
  static const String once = 'once';
  static const String always = 'always';
  static const String session = 'session';
  static const String deny = 'deny';
  static const String no = 'no';
  static bool refuses(String choice) => choice == deny || choice == no;
}
