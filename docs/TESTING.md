# Testing

## Commands

```bash
flutter pub get
dart run build_runner build -d
flutter gen-l10n
flutter analyze && dart analyze && flutter test
```

`riverpod_lint` runs under `dart analyze` only: `flutter analyze` alone passes
code the Riverpod rules reject. `flutter test` today: 559 pass, 1 skipped (the
live gateway test). Update the count here when it changes.

## Policy

- One test per user-visible behavior or protocol rule. No tests of constants,
  getters, private helpers, or the same path twice.
- SDK tests use the JSON fixtures in `test/fixtures/` (generic sample data
  only, never real bots, sessions, names or paths).
- Wait with `pumpEventQueue()` or a stream (`client.states`), never a
  wall-clock poll. Where time matters (heartbeat, backoff, deadlines) use
  `fakeAsync`.
- A test file stays under ~300 lines; a big suite shares a `*_harness.dart`
  (setup only, no tests).
- `test/flutter_test_config.dart` turns the logger off, so a green run is
  quiet.

## Layout

| Where | What |
|---|---|
| `test/hermes/` | SDK: client, replay, auth, HTTP, transport, RPC, API, router, models, redaction. `support/loopback_gateway.dart` is a real local HTTP + WebSocket server the test scripts; `support/fake_ws.dart` is a fake socket behind `WsConnector` for `fakeAsync` |
| `test/features/<feature>/` | notifiers, pure rules, feature widgets |
| `test/core/`, `test/widgets/` | contrast ratios, fold geometry, logger, failure text, shared widgets, accessibility and layout audits |
| `test/app/` | notification-tap routing |
| `test/integration/` | live gateway, read only (below) |
| `maestro/` | end to end on a device |

Helpers in `test/support/`:

- `app_host.dart`: `appHost` / `pumpApp` mount a widget as the app shows it
  (theme, `dark:`, strings, `ProviderScope` with `overrides:` or a
  `container:`, `width` / `height`, `textScale`, `direction`). Use it, not a
  `MaterialApp` of your own.
- `memory_stores.dart`: `MemorySecretStore` and `memoryStoreOverrides()`.
  **Every test that builds a chat spreads `memoryStoreOverrides()`**:
  `keyValueStoreProvider` has no default.
- `fake_gateway.dart`: `FakeClient` (`goOnline`, `goOffline`, `emit`),
  `FakeApi`, `target`. `scripted_api.dart`: `ScriptedApi` (answer, throw or
  hold each call; records what was asked) and `bootChat` / `chatOf` /
  `stateOf`.
- `fake_web_view.dart`: `FakeWebViewPlatform` (set as
  `WebViewPlatform.instance`) mounts a web view in a widget test, keeps the
  scripts it ran and plays the page's messages (`FakeWebView.send`).
  `test/features/bot_screen/screen_harness.dart` fakes a gateway with a Bot
  Screen (viewer ids per socket, lease epochs).
- `fake_bot_api.dart` (bot details), `fake_channel.dart` (JSON-RPC),
  `fixtures.dart`, `throwing.dart` (`throwInjected`).

Platform parts are faked by overriding `platformInfoProvider` (the host VM is
`AppPlatform.other`) and the seam providers (`notificationGatewayProvider`,
`connectionServiceControllerProvider`, `shareIntakeServiceProvider`,
`awayStoreProvider`, `backgroundCheckSchedulerProvider`).

## Local backend

> **Your real chats.** A gateway started from your normal `~/.hermes` serves
> your real bots: `smoke.yaml`, `share_text.yaml` and `share_image.yaml` send
> real turns into them. Run the flows against a gateway with its own home
> (`HERMES_HOME=<scratch dir> hermes serve --port <port>`, with a copy of the
> config and keys it needs), or pass `-e BOT=<a bot kept for tests>`.


The Hermes desktop app runs a loopback `hermes serve` on a random port with no
auth gate. Find it:

```bash
PORT=$(lsof -nP -iTCP -sTCP:LISTEN | awk '/Python.*127.0.0.1:/{sub(".*:","",$9);print $9}' | while read p; do curl -s -m 2 "http://127.0.0.1:$p/api/status" | grep -q '"profiles"' && echo $p && break; done)
```

Or start one: `hermes serve --port 9119` (`PORT=9119`).

- **Android emulator:** `adb reverse tcp:$PORT tcp:$PORT`, then gateway URL
  `http://127.0.0.1:$PORT` (same port both sides, so the `Host` guard
  matches).
- **iOS simulator:** it shares the host network: `http://127.0.0.1:$PORT`
  works as is, no bridge.

The app reads the session token off `GET /` by itself. A non-loopback bind
always needs sign-in (`dashboard.basic_auth` in `~/.hermes/config.yaml`). To
test sign-in without touching `~/.hermes`, run a temporary gated gateway with
env credentials:

```bash
cd <hermes-agent checkout>
HERMES_DASHBOARD_BASIC_AUTH_USERNAME=hermestest \
HERMES_DASHBOARD_BASIC_AUTH_PASSWORD='choose-one' \
HERMES_DASHBOARD_BASIC_AUTH_SECRET="$(openssl rand -base64 32)" \
./venv/bin/python -m hermes_cli.main serve --host "$(ipconfig getifaddr en0)" --port 9120 --skip-build --isolated
```

Use `http://<LAN IP>:9120`. For tests that change state (cron actions, SOUL
saves, many sessions), use a throwaway home: `HERMES_HOME=<scratch dir>
hermes serve --port 9120 --skip-build`. Never `hermes serve --stop`: it stops
every gateway. Never press Run now or Delete on a real cron job, and back up
a real `SOUL.md` (`cp -p`, `shasum -a 256`) before a live save test.

## Live SDK test

```bash
flutter test test/integration --dart-define=HERMES_URL=http://127.0.0.1:$PORT
# gated:
flutter test test/integration --dart-define=HERMES_URL=http://<LAN IP>:9120 \
  --dart-define=HERMES_USER=hermestest --dart-define=HERMES_PASSWORD='choose-one'
```

Read only: connects, lists bots, resumes a session, loads history, and checks
that the client answers every server request the gateway offers.

## Devices

| | Android | iOS |
|---|---|---|
| Device | Pixel 10 Pro Fold emulator, Android 17 (`emulator-5554`) | iPhone Duo simulator, iOS 27.1 (Xcode 27.1) |
| Run | `flutter run -d emulator-5554` | `flutter run -d "iPhone Duo"` |
| Gateway | `adb reverse` (above) | `http://127.0.0.1:$PORT` directly |
| Screenshot | `android screen capture -o <path>` (always `-o`) | `xcrun simctl io booted screenshot <path>` |
| Narrow screen | `adb shell wm size 904x2152; adb shell wm density 420` (344 dp), `wm size reset; wm density reset` after | a smaller simulator |
| Tablet | AVD `medium_tablet` (`android emulator create medium_tablet`), 1280 × 800 dp, landscape first; portrait: `adb shell settings put system user_rotation 1` | iPad Pro 13-inch (M5), iOS 27.0; turn it with Maestro `setOrientation` |

Simulator UDID: `xcrun simctl list devices available | grep "iPhone Duo"`.

### Tablets and hardware keys

- Maestro taps work on the iPad simulator; AXe taps do not, and AXe keys
  (`axe key`, `axe key-combo --modifiers 225 --key 40`, `axe type`) drop at
  random: check what arrived in the field (`axe describe-ui`, `AXValue`).
  Escape is `axe key 41`.
- Android: `adb shell input keyevent 66` and a hardware Return both go to
  Gboard first, which types a new line; the app never sees the key.
  `adb shell input keycombination 113 66` (Control-Enter) reaches the app.

### iPhone Duo open (inner screen)

Maestro and AXe (`axe describe-ui`, `axe tap`) read the inner screen but
send every touch to the cover screen, and `simctl io screenshot` without
`--display` captures the cover. Apple has no fold or posture command: fold
and open in Device Hub by hand. What works without touches:

- Screenshot a screen: `xcrun simctl io $UDID enumerate` lists the ports
  (inner 2007 × 2853, cover 1398 × 2034); pass the port UUID as
  `screenshot --display=<uuid>`.
- Set state through the app's preferences, then relaunch: `C=$(xcrun simctl
  get_app_container $UDID se.royan.pomelu data)`, then `xcrun simctl spawn
  $UDID defaults write "$C/Library/Preferences/se.royan.pomelu" <key>
  -string <value>` with the keys in `PreferenceKeys` (`gateway.url`,
  `nav.lastProfile|<gateway url>` picks the open bot, `sidebar.collapsed`).
  A plain `defaults write se.royan.pomelu` misses the app's container.
- `simctl openurl pomelu://…` asks "Open in Pomelu?", which nothing can tap.

## Maestro

```bash
# Android
maestro --device emulator-5554 test -e URL=http://127.0.0.1:$PORT maestro/smoke.yaml
# iOS (app installed by flutter run first)
maestro --device <udid> test -e URL=http://127.0.0.1:$PORT maestro/smoke.yaml
```

Flows, order, share triggers and platform notes: `maestro/README.md`. They need
a device and a gateway, so they run by hand, not in `flutter test`. CLI
screenshots take a bare name and land in `--test-output-dir`.

## By hand

No flow covers these:

- Recovery: cut the link under the running app (Android: `adb reverse
  --remove-all`; iOS: stop the gateway), expect "Reconnecting…" or "Offline",
  restore it, expect "Connected" and queued turns going out.
- Server killed and restarted with a new signing secret: silent re-sign-in.
- Fold and unfold (emulator posture controls): no restart, text and scroll
  kept.
- An image from the agent (`MEDIA:` or `@image:`) renders inline.
- Questions: ask the agent to "use the clarify tool" (one, multi-select,
  three in one call, "Other"), skip one, stop during one; a clarify in another
  chat rings the phone and the row goes when answered; "run `rm -rf
  /tmp/hermes-test-dir`" shows the approval card.
- Delete from here and Hide on this phone in a chat of three exchanges.
- Other clients: write to the same bot from Telegram; new messages appear
  within seconds.
- Bot messages while away (demo gateway only): open the app, press Home,
  wait until the debug build has handled it (about 10 s), then write a turn
  into a demo bot from a second client (a short Python `websockets` script:
  `session.list` by title → `session.resume` → `prompt.submit`). With "Stay
  connected" the bot's reply rings within seconds (`dumpsys notification
  --noredact | grep hermes.messages`). The background check alone: cut the
  link (`adb reverse --remove tcp:<port>`), write the turn, restore the link,
  and let the job run. WorkManager refuses a forced periodic run before its
  time (`cmd jobscheduler run -f` logs "Delaying execution"), so a test build
  adds a one-off task. iOS: `BGTaskScheduler`'s
  `_simulateLaunchForTaskWithIdentifier:` from an Xcode or lldb session
  attached to the app (macOS asks for permission to attach).
- Bot Screen (a gateway with one; the local macOS gateway has none): open
  a bot's screen, watch, pinch and double tap, Take over, type with the key
  row (only it over the keyboard), Drag and drop a window or file, Hand back; Take over from a second viewer (Hermes desktop app) drops
  the phone to watching; close while in control and check the lease went
  back (`ssh <host> 'cat ~/.hermes/bot-desktop/lease.json'`). Never stop a
  screen or restart the gateway that hosts it.
- Voice: hold the mic while the computer speaks (`say "..."`).
- Read aloud: a long reply's menu → Read aloud; the bar stays until it
  ends; Stop reading in the bar or the menu; a voice note started meanwhile
  stops it. On Android `dumpsys audio | grep u/pid:<uid>` shows the player.
- App icon menu: long-press the icon, pick a bot (Android without touches:
  `adb shell dumpsys shortcut` lists them with a `bitmapPath` each;
  `am start -a android.intent.action.VIEW -d 'pomelu://chat?profile=<bot>'`
  opens one as a pick does).
- Share sheet's top row: send a few messages to a bot (the system ranks
  the row by them), then share a photo from Gallery or Photos: the bot is
  in the top row, and a tap opens its chat with the photo attached.
  Android without the ranking: `am start -a android.intent.action.SEND -t
  text/plain --es android.intent.extra.TEXT hi --es
  android.intent.extra.shortcut.ID <bot> -n se.royan.pomelu/.MainActivity`
  (then clear the text from the composer).
- Plan: ask a bot for a task of several steps ("plan it with your todo
  list"); the plan row counts the steps and goes when the turn ends.
- Context meter: the parts match `/context` in the same chat.
- iOS: Increase Contrast (Settings → Accessibility → Display) makes every
  glass pane solid; a share from Photos or Files reaches the picker.

Scrolling smoothness: only on a profile build (`flutter build apk --profile`,
or `flutter run --profile` on a real iPhone); debug and emulator raster times
mean nothing.

## App Review video

App Review gets a video instead of a login (no public demo gateway). To make
a new one: a demo gateway with its own `HERMES_HOME` (demo bots, a cheap
model), the iPhone 18 Pro Max simulator, the app installed fresh, then:

```bash
P=<simulator udid>
xcrun simctl status_bar $P override --time 9:41 --batteryState charged --batteryLevel 100
maestro --device $P test <a flow with: launchApp clearState, stopApp>
xcrun simctl io $P recordVideo --codec=h264 --force demo.mov & R=$!
maestro --device $P test -e URL=http://127.0.0.1:$PORT -e BOT="Sleep Coach" maestro/app_review_demo.yaml
kill -INT $R
ffmpeg -ss <app start> -i demo.mov -vf scale=886:-2,fps=30 -c:v libx264 -crf 24 -pix_fmt yuv420p -an demo.mp4
```

Attach the MP4 in App Store Connect → App Review → Attachment.

## Definition of done

Both platforms:

1. `flutter analyze` and `dart analyze` clean; `flutter test` green; the count
   above updated.
2. `flutter pub outdated`: every direct package on its latest stable, or the
   reason in the commit.
3. Docs current (`ARCHITECTURE.md`, `DESIGN.md`, `PROTOCOL.md`, this file).
4. Commit and push each finished, green change.

Android, on the Fold emulator with the local gateway:

5. Runs folded (drawer) and unfolded (two panes), light and dark.
6. Maestro in order: `smoke`, `slash_palette`, `rotate`, `reconnect`,
   `location_sheet`, `bot_details`, `share_text`, `share_from_files` +
   `share_image`.
7. The by-hand recovery check.

iOS, on the iPhone Duo simulator:

8. `flutter build ios --simulator --debug` succeeds (no Podfile appears:
   SwiftPM only) and the app runs, light and dark.
9. Maestro: `smoke`, `slash_palette`, `rotate`, `reconnect`,
   `location_sheet`, `bot_details`, and `share_text` via a link (`maestro/README.md`).
10. A share from Photos to Hermes lands in the picker with the picture
    attached; Settings shows no "Stay connected".

Release builds: the fastlane lanes in `ios/fastlane` and `android/fastlane`.
