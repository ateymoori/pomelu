# Maestro flows

End-to-end flows against a real gateway. Find its port first
(`docs/TESTING.md` → "Local backend" sets `PORT`).

```bash
# Android emulator: bridge the port, then run
adb reverse tcp:$PORT tcp:$PORT
maestro --device emulator-5554 test -e URL=http://127.0.0.1:$PORT maestro/smoke.yaml

# iOS simulator: shares the host network, no bridge; install with flutter run first
UDID=$(xcrun simctl list devices available | awk -F'[()]' '/iPhone Duo/{print $2; exit}')
maestro --device $UDID test -e URL=http://127.0.0.1:$PORT maestro/smoke.yaml
```

Both apps are `se.royan.pomelu`, so one `appId` serves both platforms.

> **Your real chats.** A gateway started from your normal `~/.hermes` serves
> your real bots: `smoke.yaml`, `share_text.yaml` and `share_image.yaml` send
> real turns into them. Run the flows against a gateway with its own home
> (`HERMES_HOME=<scratch dir> hermes serve --port <port>`, with a copy of the
> config and keys it needs), or pass `-e BOT=<a bot kept for tests>`.

## Flows

| Flow | Checks | Needs | Platform |
|---|---|---|---|
| `connect.yaml` | clears the app, sets the URL, tests, saves, "Connected" | `-e URL=...`; run by `smoke.yaml` | both |
| `app_review_demo.yaml` | the App Review video: setup, bot list, streamed reply, Report menu, bot details tabs | `-e URL=... -e BOT=<name>`, a demo gateway (sends a turn) | iOS |
| `smoke.yaml` | connect, open the default bot (or `-e BOT=<name>`), send, streamed reply "PONG" | `-e URL=...` | both |
| `slash_palette.yaml` | `/` lists exactly `/new`, `/restart`, `/update`, `/compact`; a prefix filters; an unknown word says "No matching command". Runs nothing | configured app | both |
| `rotate.yaml` | landscape and back keep the chat and the composer text | configured app | both |
| `reconnect.yaml` | stop and start the app: it finds the gateway again | configured app | both |
| `location_sheet.yaml` | attach → Location: the map opens and closes. Shares nothing | configured app | both |
| `bot_details.yaml` | the gear opens the sheet and its four tabs. Read only | configured app | both |
| `share_text.yaml` | a shared text opens the picker; picking a bot seeds the composer | trigger (below), `BOT` | both |
| `share_image.yaml` | a shared picture is attached and sends without failing | trigger (below), `BOT` | both |
| `share_from_files.yaml` | shares `picture.png` from the Files app (trigger for `share_image.yaml`) | Pictures folder open in Files | Android |
| `share_from_photos.yaml` | shares the first picture in Photos through the share extension (trigger for `share_image.yaml`) | a picture in Photos | iOS |

"Configured app": `smoke.yaml` ran once on this device, so the gateway is
saved and the last bot opens by itself. Later flows do not clear the app.

No flow runs `/restart`, `/update` or `/compact`, presses Run now or Delete on
a cron job, or edits instructions. A matcher that stops finding its node is
fixed in the flow in the same change as the UI.

## Share flows

The picker rows have no stable id, so the flow taps the bot by display name.
`BOT` defaults to `default`; pass another with `-e BOT="<name>"`. Trigger the
share, then run the flow.

**Text, Android** (share intent):

```bash
adb shell 'am start -a android.intent.action.SEND -t text/plain --es android.intent.extra.TEXT hello_share -n se.royan.pomelu/.MainActivity'
maestro --device emulator-5554 test maestro/share_text.yaml
```

**Text, iOS** (a link naming no known bot falls to the picker; accept the
system prompt if one shows):

```bash
xcrun simctl openurl $UDID "pomelu://chat?profile=nobody&text=hello_share"
maestro --device $UDID test maestro/share_text.yaml
```

**Image, Android.** The system photo picker is not scripted, and adb cannot
grant a media URI on Android 17, so share from the Files app:

```bash
adb push picture.png /sdcard/Pictures/picture.png
adb shell am start -a android.intent.action.VIEW -t vnd.android.document/directory \
  -d "content://com.android.externalstorage.documents/document/primary%3APictures"
maestro --device emulator-5554 test maestro/share_from_files.yaml
maestro --device emulator-5554 test maestro/share_image.yaml
```

**Image, iOS.** Share the first picture in Photos through the extension:

```bash
xcrun simctl addmedia $UDID picture.png   # if Photos is empty
maestro --device $UDID test maestro/share_from_photos.yaml
maestro --device $UDID test maestro/share_image.yaml
```

On the Fold emulator, open Files on the main display (`am start --display 0
...`) or Maestro reads the other one.

The share extension copies the picture into the App Group inbox and wakes the
app. Caps on both platforms: 50 MB per file, 64 MB per share, 10 files.

## Not scripted

- Folding and unfolding: the emulator's posture controls.
- Cutting the link under a running app: Maestro cannot run `adb` or stop the
  gateway. See "By hand" in `docs/TESTING.md`.
- Airplane mode: the emulator and the simulator use the host's network.

## Notes

- Android 17: avoid `hideKeyboard` (it sends Back and pops the route); tap
  another element. The Gboard stylus dialog can steal the first input on a
  fresh emulator; dismiss it once.
- `back` is Android only.
- A list row or a tab is one node whose text holds more than its title (a
  description, "Tab 1 of 4"): match it with `(?s)<title>.*`.
- A cold start is slow; flows wait for "Attach" and for animations to end.
