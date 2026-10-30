# Architecture

A thin, live client for one Hermes gateway. Every screen is a projection of
gateway state; the app keeps no logic the gateway owns. Wire details:
`PROTOCOL.md`.

## Layers

```
presentation   widgets, screens, Riverpod notifiers      lib/features/*/presentation
domain         pure rules and models (no I/O)             lib/features/*/domain
data           stores, platform bridges, file work        lib/features/*/data
hermes SDK     transport, JSON-RPC, typed API, events     lib/hermes
```

Dependencies point down. `lib/hermes/` is pure Dart (no Flutter import) and
every public member has a doc comment (`lib/hermes/analysis_options.yaml`).
Presentation calls `HermesApi` and `HermesClient` directly; there is no
repository layer between them.

## Folders

```
lib/
  main.dart          logger, error hooks, bundled licenses, prefs + credential
                     loaded within AppConfig.startupBudget (5 s; else
                     defaults and signed out), ProviderScope, media cache prune
  app/               MaterialApp.router (app.dart), go_router (router.dart),
                     route constants (routes.dart), route observer
  core/
    config/          AppConfig (timeouts, limits, deep link names), Assets,
                     LegalConfig (privacy policy URL, reply report address)
    layout/          FoldGeometry, FoldScope, PaneSplit (hinge-aware panes)
    navigation/      leavePage / requestLeavePage
    platform/        PlatformInfo + platformInfoProvider, PlatformChannels,
                     AppShortcuts (app icon menu), openAppSettings,
                     appIsVisible
    storage/         KeyValueStore (shared_preferences), MemoryKeyValueStore,
                     SecretStore (flutter_secure_storage), StoredFlag /
                     StoredChoice (one preference behind a notifier)
    theme/           tokens.dart (+ tokens/ parts), app_theme.dart (+
                     app_control_themes.dart part: buttons, fields,
                     toggles; app_color_scheme.dart, app_text_theme.dart),
                     app_chrome.dart (system bar icons, snack bar width)
    ui/              reusable widgets, barrel ui.dart (DESIGN.md)
    utils/           logger (redacting), failureText, bidi text, format
  hermes/
    transport/       HermesHttp (dio), WebSocketTransport (TransportState,
                     RedialBackoff, close reasons, WsConnection seam)
    rpc/             JsonRpcClient (ids, pending calls), MessageChannel,
                     JsonRpcError, json_offload.dart (Base64Bytes, JSON
                     on another isolate)
    client/          HermesClient (dial, auth renewal, heartbeat, version
                     check), client_replay.dart (seq de-dup, replay, rebind),
                     SessionSignals, connection states
    api/             HermesApi: hermes_api.dart (bots, sessions, turns)
                     with parts media_routes.dart (attachments, speech to
                     text, media URLs), model_routes.dart (model, effort),
                     dashboard_routes.dart (REST), profile_routes.dart
                     (bot changes), screen_routes.dart (`display.*`)
    auth/            AuthCredential (origin-bound), HermesAuth
    events/          GatewayEvent, EventNames, payload readers:
                     event_payloads.dart (notices, background results,
                     usage, SessionRef), turn_payloads.dart (tool calls,
                     interim and final text, session.info runtime)
    requests/        ServerRequest, ClarifyQuestion, ServerRequestRouter
    models/          freezed models, json_parse (parseObject, parseRows)
    hermes_constants.dart  paths, timeouts, limits, protocol values
    hermes_failure.dart    sealed HermesFailure
  features/
    connection/      gateway config, credential storage, probe and test,
                     supervisor (redial, silent re-sign-in), gateway_address
    settings/        settings page, "How to connect" guide
    sidebar/         bot list, rail, avatars
    chat/            controller (+ controller/ parts), ChatStore, outbox,
                     reducer, transcript, composer, media, location,
                     reply report (ReplyReporter: a mailto to LegalConfig.reportEmail)
    bot_details/     skills, tools, SOUL.md, cron; a bot's name, picture, create, delete
    bot_screen/      a bot's screen: status, the page's session, the web
                     view (noVNC), keyboard, header button
    notifications/   NotificationCenter, policy, gateway, "Stay connected"
    share/           ShareIntakeService, share bridge, target picker
  l10n/              app_en.arb, generated/
android/             MainActivity.kt (share bridge), SharedFiles.kt,
                     ConnectionService.kt, BotShortcuts.kt
ios/                 Runner (AppDelegate, ShareBridge.swift), ShareExtension,
                     Shared/ShareInbox.swift (compiled into both targets)
assets/bot_screen/   screen.html: noVNC 1.7.0 and tool/bot_screen/screen.js in
                     one page (built by tool/bot_screen/build.mjs), and the
                     noVNC and pako notices
third_party/         gpt_markdown 1.3.4, patched ("Pomelu patch"): table
                     fills clipped to the rounded border, header style kept;
                     a dependency_overrides path, dropped once upstream fixes it
```

## Providers and seams

| Provider | Owns |
|---|---|
| `gatewayConfigProvider`, `credentialProvider` | URL, auth mode, username; the credential (bound to the origin that issued it) |
| `hermesClientProvider` | one `HermesClient` per gateway URI (null with none); rebuilt only when the URI changes |
| `hermesApiProvider`, `serverRequestRouterProvider` | typed API and the agent's open questions, of that client |
| `connectionStateProvider` | `Disconnected / Connecting / Reconnecting / Connected / AuthRequired` |
| `connectionSupervisorProvider` | redial on network change and resume; silent re-sign-in (`AppConfig.reauthMaxAttempts`, 3) |
| `profilesProvider`, `sidebarGroupsProvider`, `profileAvatarProvider` | bots; refreshed on `sessions.changed` and `gateway.ready` |
| `botShortcutsProvider`, `appShortcutsProvider` | the app icon menu: the sidebar's first four bots, Android with avatars (`shortcutIcon`) |
| `chatControllerProvider(target)` | `ChatState` of one bot's chat (with the running turn's plan, `TodoPlan`) |
| `readAloudProvider`, `speechOutputProvider` | the reply read aloud (`/api/audio/speak`) and its player; one at a time with voice notes (`nowPlayingProvider`) |
| `chatStoreProvider`, `chatGatewayScopeProvider` | `ChatStore`, keyed by gateway identity |
| `composerDraftControllerProvider(target)` | a composer's files and transcribing flag; saves its draft |
| `outboxDrainerProvider` | wakes chats whose queue has work |
| `pendingRequestProvider(runtimeId)` | the oldest open question of a session |
| `pendingShareProvider`, `composerSeedsProvider` | incoming share; text and files waiting for a composer |
| `notificationCenterProvider` + settings and permission providers | signals → notifications; "Stay connected" |
| `botSkillsProvider`, `botToolsetsProvider`, `botSoulProvider`, `botCronJobsProvider`, `cronJobActionsProvider` | bot details sheet |
| `botScreenProvider(profile)`, `screenSessionProvider(profile)` | a bot's screen (status and control, kept by events); the open Screen page (viewer, stream, Take over, Hand back) |
| `platformInfoProvider` | which OS; providers pick platform parts from it |

`keyValueStoreProvider` has no default: `main.dart` overrides it, and so does
every test that builds a chat (`memoryStoreOverrides()`).

Interfaces exist only at real seams: `KeyValueStore`, `SecretStore`,
`WsConnection` (fake socket in tests), `MessageChannel`, `ConnectionService`
(settings probe), `ShareBridge`, `NotificationGateway`,
`ConnectionServiceController`, `ScreenSurface` (the Screen page's web view). Tests fake `HermesClient` and `HermesApi` with
`Fake implements` (`test/support/`).

## Platform layer

Only `PlatformInfo` asks which OS runs (`AppPlatform.android / ios / other`;
`flutter test` is `other`). `canStayConnected` is true on Android only.

| Part | Android | iOS | Other |
|---|---|---|---|
| Share sheet (`ShareBridge`) | `ShareChannel` ← `MainActivity.kt` | `ShareChannel` ← `ShareBridge.swift` | `NoShareBridge` |
| Notifications (`NotificationGateway`) | `LocalNotificationGateway` | same, Darwin settings | `NoopNotificationGateway` |
| Push (`PushBridge`) | `ChannelPushBridge` ← `PushBridge.kt` (FCM token, the phone's key), `PushService.kt` opens and posts; Firebase starts from `BuildConfig` (`android/firebase.properties`, private) or not at all | `ChannelPushBridge` ← `PushBridge.swift` (APNs token); `NotificationService` extension opens and shows; `Shared/PushKey.swift` holds the key in the App Group | `NoPushBridge` |
| "Stay connected" (`ConnectionServiceController`) | foreground service, `specialUse` | none; Settings hides the row | none |
| Links | `app_links`, `pomelu://` intent filter, `flutter_deeplinking_enabled` false | `app_links`, `CFBundleURLTypes` `pomelu`, `FlutterDeepLinkingEnabled` false | `app_links` |
| Gallery, geocoder, pickers | plugins (`gal`, `geocoding`, system pickers) | same plugins | fail softly |
| App settings page | `openAppSettings` (geolocator) | same | — |
| Bots for the system (`AppShortcuts`): app icon menu, share sheet's top row | `AndroidAppShortcuts` → `BotShortcuts.kt`: long-lived dynamic shortcuts with each bot's round avatar as Dart draws it (`shortcutIcon`); a pick opens `pomelu://chat?profile=`; also Direct Share targets (`res/xml/shortcuts.xml`), ranked by `reportShortcutUsed` on each send | `IosAppShortcuts`: quick actions (`quick_actions`, no picture: iOS takes only monochrome symbols) and share suggestions (`BotSuggestions` in `AppDelegate.swift` donates an `INSendMessageIntent` per bot, again on each send; `NSUserActivityTypes`, the extension's `IntentsSupported`) | `NoAppShortcuts` |

Channel names: `PlatformChannels` (`se.royan.pomelu/share`, `.../share/events`,
`.../connection_service`, `.../shortcuts`). Kotlin and Swift spell the same strings.

iOS build: Swift Package Manager only (`enable-swift-package-manager`; no
Podfile, no CocoaPods). Targets: Runner (`se.royan.pomelu`), ShareExtension
(`se.royan.pomelu.ShareExtension`), both in App Group
`group.se.royan.pomelu`. Deployment target iOS 15. `Info.plist`: usage
strings for camera, microphone, location when in use, photo library (add and
read), local network; `hermes` URL scheme; ATS `NSAllowsArbitraryLoads` and
`NSAllowsLocalNetworking` (users reach their own gateway by IP, often over
plain http); `ITSAppUsesNonExemptEncryption`
false.

Android: `minSdk` 29, `targetSdk` 36 (pinned), `compileSdk` 37. No camera,
media or storage permission (system pickers; plugin merges removed). Cleartext
on (`network_security_config.xml`, system + user CAs). Backup off.
`configChanges` covers fold, resize and density, so a posture change never
recreates the activity. R8 uses the plugins' own keep rules, none of the
app's (`shared_preferences_android` keeps its JNI types since 2.5.2).
Release logs: `ProductionFilter` (warnings and up), every line redacted.

## Connection

- One socket per gateway, shared by all features. `HermesClient` dials,
  renews credentials (one renewal at a time; only a 401/403 on the refresh
  means "sign in again"), checks the version once per gateway process, and
  sends `client.capabilities` before it reports `Connected`.
- Heartbeat, backoff, replay after reconnect: `PROTOCOL.md`.
- An RPC whose frame never left fails with `NetworkFailure`; once written, a
  timeout or drop is `OutcomeUnknownFailure`, and a non-idempotent call is
  never resent blindly.
- Settings saves nothing until "Save and connect". On a new address the old
  client stops first, then credential, then config. A result (probe, test,
  sign-in) that returns after the URL changed is dropped. `user:pass@` URLs
  are refused. `http://` to a public host shows "Not encrypted" and asks
  before a password goes out (`gateway_address.dart`).

## Chat

`ChatController` (`chat_controller.dart`) owns one bot's chat. Its parts are
mixins in `presentation/controller/`: `_Session` (bind, history, events,
connection), `_Opening` (find or make the bot chat once the gateway is up),
`_Outbox` (send queue, delivery), `_Stop` (stop turn), `_Conversations` (new
conversation, earlier conversations, following other clients), `_Commands`
(slash commands) and `_Edits` (delete, hide). Per build a `_Run` holds the API, client,
store and in-flight work; a rebuilt or closed chat drops what the old run
left (`ref.mounted` after each await). With no gateway the controller builds
in an error state and every method does nothing.

Pure parts: `ChatReducer` (event → state), `Transcript` (history rows,
matching, earlier rows, in-flight restore), `Outbox` (queue transitions,
projection, reconcile), `SlashCommand`, `MarkdownChunks`.

### A turn

1. `send` writes an `OutboxEntry` to `ChatStore` and shows its row at once
   (same id). A full queue (`Outbox.maxEntries`, 50) refuses; the composer
   keeps the text.
2. `_drain` delivers oldest first, one at a time, only while no reply streams
   and no delete runs.
3. `sending`: files are read (size checked on disk first) and uploaded
   (`image.attach_bytes`, `file.attach`). A restart here re-queues safely.
4. `submitted`: the entry is saved, then `prompt.submit` goes out.
5. Events (`message.delta`, `tool.*`, `message.complete`, ...) flow
   `WebSocketTransport` → `JsonRpcClient` → `HermesClient.events` (seq de-dup,
   replay) → the chat's listener, filtered by runtime id → `ChatReducer` →
   `ChatState`. Widgets rebuild by `ref.watch`.
6. An acknowledged turn leaves the queue. On `OutcomeUnknownFailure`, or after
   a kill while `submitted`, the turn is reconciled after the next resume
   against `session.history`, `inflight.user` and `queued.user`: found means
   delivered, else `failed` ("delivery unconfirmed"). It is never resent.
7. A failed turn holds the queue (order is part of the conversation). Resend,
   edit and discard work on `queued` and `failed` only. A network miss before
   the frame left re-queues, up to `Outbox.maxAutoAttempts` (5).

The queue survives process death. `chatControllerProvider` holds itself alive
while its queue has work, and `OutboxDrainer` builds the chat of every
`ChatStore.pendingTargets()` entry at start and on each `Connected`, so a turn
goes out with its chat closed.

### Storage

`ChatStore` keeps per chat, keyed `<prefix><gateway identity>|<target>`:
`chat.outbox.` (queue), `chat.pendingOutboxes.` (targets with work),
`chat.draft.` (composer text and files), `chat.hidden.` (rows hidden on this
phone), and `nav.lastProfile|<gateway>`. Reads and writes never throw; a bad
row is skipped and logged. Gateway identity is the origin with a lower-case
host. Slash-command rows live in `ChatState` only and are merged back after
each history load (`Transcript.withCommands`); they do not survive a closed
chat.

### One chat per bot

The open session is the bot's "Bot Chat". `startOver` (`/new`, `/reset`,
`/clear`) settles unconfirmed turns, creates the next session with
`parent_session_id`, archives the old one, and moves the rows on screen above
a "New conversation" line. Scrolling near the top calls `loadEarlier`: one hop
back along parent links (compaction parents skipped), rows over REST, read
only. Another client writing the same session (Telegram, desktop, cron) only
sends `sessions.changed`; an idle chat waits
`AppConfig.transcriptFollowDelay` (800 ms), looks the Bot Chat up, and reloads
when the words differ. Every reconnect does the same check, for replies that
landed while the socket was down. An open or resume still on the old socket
when it comes back runs once more after it ends (`openAgain`, `reopenAgain`):
joined, it could fail late and leave the chat empty. A cold resume answers
`hydrating`; its history is shown at once and polled only while it reads
empty (`historyHydrateBudget`): the gateway leaves some stored rows out, so
the rows can stay below `message_count`.

### Questions from the agent

Clarify, approval, sudo and secret arrive as JSON-RPC requests, not events.
`ServerRequestRouter` parks them per runtime session; `pendingRequestProvider`
streams the oldest to `PendingRequestCard`; `answer*` replies through the
router. The router, not `ChatState`, is the source of truth, so a question
survives a closed chat and a reconnect replays it.

### Slash commands

Four, fixed: `/new`, `/restart`, `/update`, `/compact`. A command is the word
alone (`/clear the cache` is a message); any other `/word` goes to the agent.
`/restart` and `/update` confirm first. `/compact` is `session.compress` plus a
history reload; `/restart` and `/update` are dashboard REST actions polled by
`HermesApi.awaitAction`, the log tail growing in the row. Polling stops when
the chat closes; the action goes on at the gateway.

### Transcript and media

`MessageList` is a reversed lazy list of `TranscriptItem` rows. A reply over
`AppConfig.replyChunkChars` (800) is cut between Markdown blocks into several
rows; while streaming only the last row rebuilds. Reply direction (RTL for
Persian, Arabic, Hebrew) is read once from the prose (`markdownDirection`) and
set on every piece. Links open for `http`, `https`, `mailto` only.

Media refs in text (`MEDIA:`, `@image:`, data URLs) resolve to
`/api/files/download` or `/api/files/stream` with auth headers for the
gateway's origin only. A file chip's size is a `Range: bytes=0-0` GET of
the download (the total is in `Content-Range`). `MediaCache` downloads to `<name>.part` and renames
when whole, joins duplicate fetches, and prunes files older than 7 days at
start. Video and audio open the player on first tap. Voice: hold the mic,
the gateway transcribes (`/api/audio/transcribe`), the words are sent.
Location is text (`Location:` / `Latitude:` / `Longitude:` lines) from an
OpenStreetMap picker and the system geocoder (6 s timeout).

Attachment limits (`HermesLimits`): 10 files, 64 MB per turn, 25 MB per image
or audio, 50 MB per file or video. A file left out says why; temp copies left
out are deleted.

## Share flow

Both platforms feed one Dart contract: `initial` (the share that launched the
app) and an event stream of `[{type: text|file|skipped|target, text, path,
mime, name, count, profile}]` (`target`: the bot picked in the share sheet's
top row). `ShareIntakeService` turns items and `pomelu://chat?profile=
<bot>&text=<text>` links into an `IncomingShare`; `pendingShareProvider` keeps
it. The chat shell, only while it is the top route, routes it: a known bot
opens its chat with the composer seeded (`ComposerSeed`); otherwise the target
picker opens. The router never navigates for an external URI
(`refuseExternal`).

- **Android.** `MainActivity.kt` takes `ACTION_SEND` / `SEND_MULTIPLE`, copies
  each `content://` stream of another app into the cache (`SharedFiles.kt`, off
  the UI thread), refuses `file://` and the app's own authorities, reads text
  as `CharSequence`, and strips replayed intents (Recents, saved state). A
  Direct Share names its bot in `EXTRA_SHORTCUT_ID`.
- **iOS.** `ShareExtension` (no compose UI) copies the items into a new folder
  of the App Group inbox, writes `manifest.json` last (`ShareInbox.seal`), then
  opens `pomelu://share` through the responder chain and finishes. That link
  only wakes the app; Dart ignores it. `ShareBridge.swift` reads the inbox at
  start and on every `sceneDidBecomeActive` (and on the wake link while
  active), moves files to `Caches/shared`, and answers `initial` or emits on
  the stream. A share whose wake-up failed arrives at the next app open. A
  share suggestion picked in the sheet is the extension's `intent`
  (`INSendMessageIntent.conversationIdentifier`, the bot).

Caps on both: 50 MB per file, 64 MB per share, 10 files, copies older than 3
days removed at start, names cut to 120 UTF-8 bytes on disk. Left-out files
arrive as one `skipped` item; the picker says so.

## Notifications

Local rows (`flutter_local_notifications`) for what the socket brings, and
push for the bots' messages when the gateway has the Pomelu plugin (below).
`NotificationCenter` listens to `SessionSignals`
(`notification.show/clear`, `background.complete`, runtime id → bot) and to
the router's question arrivals and closes; `NotificationPolicy` (pure)
decides, quiet for the chat on screen (`ActiveViewNotifier`). A question's
row goes once it is answered. A tap opens the chat (`openFromOutside`). Permission is
asked once, after the first `Connected`; Settings offers "Open settings" when
it is blocked. Every row is cleared on sign-out or gateway change.

**Bot messages while away** (`checkMessages`, channel `hermes.messages`):
what a bot wrote in its Bot Chat after the app left the screen (a reply that
landed late, a cron report, a background result) rings once, the newest
message per bot; the row goes when that chat opens. When the app leaves the
screen it stores, through `AwayStore` (uncached preferences, shared with the
background isolate), the time and each bot's `message_count` from the roster:
a changed count is what marks a chat as moved (Hermes stamps `last_active`
at a turn's start, not when its reply lands). A Bot Chat gets such messages
only from a cron job with `deliver: bot-chat`; a job made in an app chat has
no origin, so Hermes sends it to a Telegram home channel or keeps it local.
The [Pomelu plugin](https://github.com/ateymoori/pomelu-hermes-plugin) for
Hermes (a `pre_tool_call` hook on `cronjob_manage` create, plus a prompt
section in `gui` sessions) sets `bot-chat` when no target was chosen. An
idle open chat lets go of its session while the app is away (`_release`,
`session.close`) so the gateway can take the chat over and deliver; it
resumes on return. Without push, two runners share it:

- the app, on `sessions.changed` and on every `Connected` while it is not
  visible (2 s debounce): with "Stay connected", at once, and what came
  while the socket was down once it is back;
- the background check (`workmanager`, `backgroundCheckMain`): Android's
  WorkManager every 15 min with network; iOS background app refresh
  (`BGTaskSchedulerPermittedIdentifiers`, registered in `AppDelegate`), when
  iOS chooses. It dials with the stored settings and credential and
  disposes the client. Secrets are kept "after first unlock, this device"
  so it can read them while the phone is locked; the app re-reads the
  credential on resume, as the check may have renewed it.

**Push** (`PushRegistration`, `PushBridge`). With the
[Pomelu plugin](https://github.com/ateymoori/pomelu-hermes-plugin) installed,
a bot's reply in its Bot Chat rings the phone while the app is away, with no
app code running. On each `Connected`, while Notify me is on and allowed, the
app registers the phone: `PUT /api/plugins/pomelu/devices/{id}` with the
push token and a 32-byte key the phone made (`PROTOCOL.md`). It tells the
plugin when it comes on screen and leaves (`/presence`, again every 5 min on
screen); the plugin pushes only while the app is away (or quiet for 10 min).
The plugin seals each message with the phone's key (AES-256-GCM) and sends
it through the Pomelu push relay (a Cloudflare Worker, `relay/` in the
plugin repo) to APNs or FCM; the relay holds the app's push keys and cannot
read the message. On the phone the native side opens it and posts the bot's
message row, same id and tag as `forMessage`: Android `PushService.kt` (data
message; quiet while the app is in front or Stay connected holds the
socket, so a message rings once), iOS the `NotificationService` extension
(the push's plain "New message" alert shows only if it cannot open it; no
banner while the app is in front). A tap opens the bot's chat (Android: the
`pomelu://chat` link; iOS: `PushBridge` → `taps`, or `launchBot` after a cold
start). While push is active the background check is off and the app posts
the bots' messages itself only with Stay connected. Another account gets a
new phone id and a new key. Notify me off removes the phone from the plugin.
A gateway without the plugin (404) keeps the runners above, and Settings
says how to add it.

- **Android.** "Stay connected" (on by default) runs a `specialUse`
  foreground service that holds the process, started only while the app is in
  front and checked on every resume. After `AppConfig.backgroundRedialBudget`
  (10 min) unreachable in the background, redialling stops
  (`BackgroundRedialGuard`) until the app opens or the network changes.
  Without it, Android 15+ blocks the app's network a few seconds after it
  leaves the screen (the `background` firewall chain) and drops the socket;
  it redials when the app is back.
- **iOS.** Darwin settings, no prompt at launch. iOS suspends the app in the
  background, so the socket and its notifications stop shortly after the app
  leaves the screen. "Stay connected" is not shown.

## Bot Screen

A bot's screen is a headless Linux desktop on the gateway's host that the
agent drives with its computer and browser tools (Hermes "Bot Screen").
`BotScreen` (`botScreenProvider`) holds its status and control (the lease):
read when a chat opens (the header shows the button only for a bot with a
screen), kept by the `display.status` / `display.lease` events of its
`profile_key`, an older lease epoch ignored, read again on each reconnect.

The Screen page (`/screen/:profile`) is always dark, as a picture viewer.
Opening it takes the focus off the composer, so closing it does not raise
the keyboard again. Each profile has its own desktop and lease.
`ScreenSession` drives `ScreenStage`, a web view (`webview_flutter`) with
`assets/bot_screen/screen.html` loaded under the gateway's origin (so the
stream's socket carries the gateway's own Origin). The page dials the
stream itself (`display.observe` → `/api/display/ws?display_ticket=`) and
reports open and close codes on the `Pomelu` channel; the session answers:
4000 (another viewer took control) watch again with a notice, 4001 the
screen stopped, anything else up to `AppConfig.screenReattachAttempts`
tries, then Reconnect. Zoom and pan stay in the page (pinch, two fingers
when zoomed, one finger and double tap while watching). The home view
suits the window: whole on a wide one; on a tall one (portrait, a folded
cover screen) the desktop fills the height (when that is at least 1.25×
closer) and the view follows what changes on the desktop (noVNC's drawn
rects, less the top panel and changes over half the desktop), which is
where the bot works. A pinch or pan stops following; a double tap goes
home again; Whole screen and Fill screen switch between the two. With control, one
finger is the mouse (a drag holds the left button) and two scroll. Drag
and drop picks up on a tap, lets every gesture move the view, and on the
next tap moves the held pointer there in steps before the release (a
desktop starts a drag only on motion); Escape cancels it. A viewer id belongs to the socket that
minted it: after a reconnect the page watches as a new viewer and takes
again the control it held. Control goes back to the bot when the page
closes (a clean close and the release call); while the app is away it is
kept `AppConfig.screenAwayHandBack` (a password copied from another app),
then handed back only if a fresh status shows this page still holds it:
never by force over a viewer that took over meanwhile. Typing goes through
a hidden field (`RemoteKeyboard`, nothing learned or corrected, its caret
pinned to the end) whose changes become keys (`RemoteTyping.diff`); a key
row adds Esc, Tab, Ctrl, Alt and arrows, and a hardware keyboard's Esc, Tab
and arrows go to the desktop too. Paste puts the phone's clipboard on the
desktop's (for its own Ctrl+V) and types it when it is at most
`AppConfig.screenPasteMaxChars`; the desktop's clipboard never comes back
(PROTOCOL.md, "Bot Screen").

Rebuild the page after changing `tool/bot_screen/screen.js` or the noVNC
pin: `cd tool/bot_screen && npm ci && node build.mjs` (commit the asset).

## Errors

`HermesFailure` is sealed: `NetworkFailure` (`OutcomeUnknownFailure`),
`UnauthorizedFailure`, `ForbiddenFailure` (`HostRefusedFailure`),
`ProtocolFailure`, `ServerFailure` (`rpcCode` or `httpStatus`;
`TitleInUseFailure`: `session.title` error 4022 "already in use"),
`NotSupportedFailure` (404 on an optional route: no Retry),
`GatewayTooOldFailure`, `CancelledFailure`. The SDK maps every error to one;
presentation words it with `failureText` (`failureTextFor(l10n, e)` without a
context). Nothing is swallowed: framework and platform errors are logged;
the logger masks tokens and passwords.

## Layout

The shell is two panes from `spacing.sidebarWidth + spacing.chatPaneMin`
(640 dp), else a drawer; a rail when collapsed or when the window is shorter
than `spacing.railMaxHeight`. One `ReadingColumn` holds header, transcript,
cards and composer. The chat header is a row of floating glass capsules
(no bar) the transcript scrolls under, with only the status bar faded out; the bottom layer (request card, slash palette, composer) floats over
the transcript, capped at `spacing.bottomLayerMaxFraction`, and the transcript
pads by both measured heights (`SizeReporter`). Rules: `DESIGN.md` →
"Foldables, tablets and large screens".
