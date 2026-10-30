# Gateway protocol (what this client relies on)

Hermes `hermes serve`: REST under `{base}/api/...` and JSON-RPC 2.0 over a
WebSocket at `{base}/api/ws`. Checked against Hermes 0.22.2. The SDK in
`lib/hermes/` implements exactly this; constants are in
`hermes_constants.dart`.

## Versions

- `GET /api/status` → `version`. Older than `HermesProtocol.minGatewayVersion`
  (0.21.5) is refused once per gateway process, after `gateway.ready`
  (`GatewayTooOldFailure`, no redial). A version that cannot be read is let
  through. `release_date` lags the version: never order by it.
- Optional REST routes (skills, toolsets, `SOUL.md`, cron list, restart,
  update, update check, speech to text) may be missing on an older gateway: a
  404 there is `NotSupportedFailure` ("Not supported by this gateway version",
  no Retry). A 404 for one item (a job, a session) is a `ServerFailure`.

## Transport and auth

| Leg | Endpoint | Un-gated (loopback) | Gated |
|---|---|---|---|
| REST | `{base}/api/...` | `X-Hermes-Session-Token: <token>` | `Authorization: Bearer <access>` |
| Socket | `ws(s)://{host}{prefix}/api/ws` | `?token=<token>` | subprotocols `hermes-gateway-v1`, `hermes-gateway-ticket.<ticket>` |

- `{base}` may carry a proxy prefix; paths resolve under it. An id used as a
  path segment must not be empty, `.` or `..`.
- The gate is on for any non-loopback bind. A phone on the LAN always signs
  in, unless it reaches a loopback gateway through `adb reverse` (or the iOS
  simulator, which shares the host network).
- Credentials go to the gateway's origin only. Every credential names the
  origin that issued it; HTTP and the dial refuse one bound elsewhere. REST
  follows no redirect (a 3xx is a `ServerFailure`). A download sends auth
  headers only to the gateway's origin, writes `<path>.part` and renames when
  whole.

### Discovery and sign-in

1. `GET /api/status` (public): `version`, `auth_required`, `auth_providers`,
   `profiles`.
2. Un-gated: `GET /` embeds `window.__HERMES_SESSION_TOKEN__="…"`; the SDK reads
   it (`HermesAuth.discoverSessionCredential`). The token is per process: a 401
   reads it again.
3. Gated: `GET /api/auth/providers`; `POST /auth/password-login {provider,
   username, password, next:""}` → cookies `hermes_session_at` (access, used as
   bearer), `hermes_session_rt` (refresh), `hermes_session_provider`. Cookie
   values may be in double quotes: one pair is stripped.
4. Renewal: `POST /auth/native/refresh {refresh_token, provider}`. A 401 on a
   REST call renews once and retries once. Only a 401 or 403 **on the
   refresh** means "sign in again"; unreachable, 5xx, 429 do not. A refused
   refresh token is not offered again; one dial renews at most once. Then the
   app re-runs password login with the stored password, at most 3 in a row.
5. Gated socket: `POST /api/auth/ws-ticket` → `{ticket, ttl_seconds: 30}`,
   single use, minted before every dial.

### Socket refusals

All refusals happen before accept (auth `4401`; Host / Origin and peer guards
`4403`); uvicorn turns each into an HTTP 403 handshake. On a 403 the client
asks `GET /api/status`: the Host guard answers plain HTTP to a wrong host with
**400**, so 400 means `HostRefusedFailure` (no redial, no re-sign-in);
anything else is `AuthRequired`. Close codes 4401/4403/4408 also count as auth
failures. Test connection shows the close reason, secrets removed.

## Framing and liveness

One JSON-RPC object per text frame; client ids are integers. Notifications are
`method: "event"` with the name in `params.type`:

```json
{"jsonrpc":"2.0","method":"event","params":{"type":"message.delta","session_id":"a1b2c3d4","seq":42,"payload":{"text":"Hel"}}}
```

Session-less events (`gateway.ready`, `sessions.changed`, `session.reclaimed`)
have `session_id: ""` and no `seq`.

- Handshake: the server speaks first, `gateway.ready {replay_epoch, ...}`,
  within 10 s or the socket is dropped. The client then sends
  `client.capabilities {server_requests: true}` (5 s cap; `-32601` is fine)
  and only then reports `Connected`. Without it the gateway never asks the
  app a question.
- Heartbeat: `gateway.ping` every 15 s; 45 s without any inbound frame drops
  the socket. While `image.attach_bytes` or `file.attach` is in flight, no
  ping is sent; `GET /api/status` per beat stands in, with a 2 min deadline.
- Frames of 512 KiB or more are encoded or decoded on a short-lived isolate,
  in order.
- Half-open probe: RPC `ping` (5 s); `-32601` still means alive.
- Reconnect: full-jitter backoff from 300 ms, doubling, ceiling 15 s (60 s
  after 10 redials in a row); it resets only after 10 s up past
  `gateway.ready`.
- Redial now (app back in front, network changed): drops a dial under way
  and dials at once; what the dropped dial opens later is closed. A dial
  begun in the background hangs until its 15 s timeout.
- A written request with no answer (timeout, drop) is `OutcomeUnknownFailure`:
  the gateway may have acted. A frame that never left is `NetworkFailure`.

## Replay after reconnect

Every session event carries `seq`. The client keeps a watermark per watched
session and drops repeats. A session gets its watermark when first watched:
`session.events.since {session_id, last_seen: 0x7fffffff}` replays nothing and
answers `latest_seq`. On each `gateway.ready`:

1. `replay_epoch` changed (backend restarted): clear watermarks, reload every
   watched transcript.
2. Else per watched session `session.events.since {session_id, last_seen}`;
   live frames of that session are parked meanwhile (at most 2000; more
   reloads the transcript). `truncated: true` reloads too.
3. `session.activate {session_id, cols, omit_messages: true}` rebinds the
   session to the socket and returns `open_requests`.

A replay call that fails on the link is tried once more. A timeout reloads the
transcript (or reopens the session) on the same socket; only frames that never
left drop the socket. A refused `session.activate` (`4007`: no longer live) is
reported as a lost session and the chat resumes it again.

## Ids

`session_id` is the runtime handle, new on every resume: it addresses
`prompt.submit`, attachments, `session.history`, `interrupt`, `title`,
`compress`, `undo`. `stored_session_id` is durable: lists, `session.resume`,
REST. Error `4001` (session not found) → resume again and retry once.

**Source.** Sessions carry `source: "gui"`, Hermes' label for a graphical
chat client: no platform hint, no Desktop-only tools (`desktop` adds
`desktop_ui`, whose tools wait on the Desktop renderer). A Bot Chat row
whose source Hermes does not know as local (the app's old `mobile`) is moved
aside by the gateway the first time it delivers into the Bot Chat (a cron
`deliver: bot-chat`, another bot): renamed `Bot Chat (mobile <id>)`, a new
gateway-owned `local-…` row takes the title, with no link back
(`gateway/session_bot.py` `displaceable_bot_chat`). Earlier conversations
follow it (below).

**Messages the bot starts.** Only a cron job with `deliver: bot-chat[:<profile>]`
writes into a Bot Chat; `send_message` cannot target one. A `gui` session has
no cron origin, so a job made there without a target goes to a home channel
(`origin_fallback`) or stays `local`, and Hermes' own create notice suggests
`telegram`. The Pomelu Hermes plugin routes such jobs to `bot-chat`.
Hermes delivers only into a Bot Chat its gateway owns. A chat the app made
(`session.create`, a new conversation) is adopted on the first delivery,
which Hermes refuses (`runtime_coordination_required`, "another session
writer holds the Bot Chat") while `hermes serve` holds it open for the app.
So the app sends `session.close {session_id}` for an idle chat when it leaves
the screen (or when a turn ends while it is away), and resumes it when it is
back.

**Push (Pomelu plugin).** The plugin's dashboard routes, behind the
dashboard's normal sign-in; 404 means no plugin (or an unknown phone):

| Route | Body | Meaning |
|---|---|---|
| `PUT /api/plugins/pomelu/devices/{id}` | `{platform: ios\|android, token, key, sandbox}` | add or renew this phone; `key` is 32 bytes, base64; `sandbox` is APNs development. Also turns the plugin on for every bot |
| `PUT /api/plugins/pomelu/devices/{id}/presence` | `{visible}` | the app came on screen or left |
| `DELETE /api/plugins/pomelu/devices/{id}` | — | no more pushes to this phone |

A push carries `base64(nonce(12) || ciphertext || tag(16))` of
`{"v": 1, "bot", "title", "body"}` (`body` cut to 240 characters, a file-only
reply is a paperclip). iOS: APNs `alert` with `mutable-content`, the sealed
text in `enc`, `apns-collapse-id` per phone and bot. Android: an FCM data
message `{enc}`, high priority.

## Methods used

| Purpose | Call |
|---|---|
| bots | `profiles.list {include_sessions: true}`; avatar `profiles.get_asset {name, asset: "avatar"}` |
| bot changes | As Hermes Desktop. New: `profiles.create {name}` (an id Hermes accepts, from the name; the gateway's model and keys). Name: `profiles.configure {name, ui_meta: {"hermes-bots": {...entry, title}}, ui_meta_expected_revisions}`, the entry re-read from `profiles.list {include_sessions: false}` and redone on `applied.ui_meta_conflicts` (3 tries). Picture: `profiles.set_asset {name, asset: "avatar", data}` (JPEG/PNG/WebP, 2 MB) or `{clear: true}`. Delete: `DELETE /api/profiles/{name}` (not the default bot) |
| bot chat | `session.list {profile, title: "Bot Chat", limit: 5, include_hidden: true}` → resume; none: `session.create {profile, title, hidden: true, follow_profile_config: true, cols, source: "gui"}` + `session.title` |
| open | `session.resume {session_id: <stored>, profile, cols: 96, source: "gui", defer_history: true, omit_messages: true}`, then `session.history {session_id: <runtime>}`, polled while a hydrating (`hydrating: true`) session reads empty (history drops some stored rows, so it can stay below `message_count`). The resume answer carries `inflight`, `queued`, `open_requests`, `info.usage` |
| send | stage `image.attach_bytes {session_id, filename, content_base64}` (25 MB) or `file.attach {session_id, name, path, data_url}` (50 MB) → refs; then `prompt.submit {session_id, profile, text}`. At most 10 files, 64 MB per turn, checked before encoding. Never resent blindly |
| stop | `session.interrupt` → `message.complete {status: "interrupted"}` |
| new conversation | `session.create {..., parent_session_id: <old stored>}`, `session.archive {session_id, profile}` on the old one, `session.title` on the new. On failure the new one is archived and the old restored (`archived: false`) |
| earlier conversations | REST `GET /api/sessions/{id}?profile=` → `parent_session_id` (a parent with `end_reason: compression` is the same conversation); rows `GET /api/sessions/{id}/messages?profile&limit=500&order=latest&inline_images=false`. At a root with no parent: the newest row of `GET /api/sessions?profile&sources=gui,mobile&archived=include&limit=100&offset` titled `Bot Chat (…` that started before it (a Bot Chat the gateway moved aside; a compacted one is listed as its tip) |
| compact | `session.compress {session_id}` (up to 3 min) → `{status, before_*, after_*, summary}` or `{lock_held: true}` |
| context | `session.context_breakdown {session_id}` → categories, `context_max`, `context_used`, `context_source`, `context_files` (estimates; `context_max: 0` = no live agent). A `usage` map carries `context_*` only once the agent has made a call in this gateway process (not after a resume or restart); until then the header ring shows the breakdown's estimate, else an empty, still ring |
| model, effort | `model.options {session_id, profile}`; `slash.exec {session_id, command: "model <id> --provider <slug>"}` (ids must match `^[\w.:/@+-]+$`, no leading `-`); `config.set {session_id, key: "reasoning", value, scope: "session"}` |
| delete from here | `session.undo {session_id}` → `{removed}`, repeated until the chosen user row is gone from `session.history` |
| voice | `POST /api/audio/transcribe?profile= {data_url, mime_type}` → `{transcript}` (empty = no speech) |
| read aloud | `POST /api/audio/speak?profile= {text}` → `{data_url, mime_type, provider}` (the bot's `tts` settings, free Edge voice by default; Markdown cleaned and long text chunked by Hermes; up to 3 min); 400 with `detail` when no voice is set up |
| media | `GET /api/files/download?path=` (images, files; with `Range: bytes=0-0` only the size, in `Content-Range`); `GET /api/files/stream?path=` (audio, video; Range) |
| skills, tools | `GET /api/skills?profile=`, `GET /api/tools/toolsets?profile=` (read only; only `enabled` items are shown) |
| SOUL.md | `GET /api/profiles/{name}/soul` → `{content, exists}`; `PUT ... {content}` (atomic; reaches new sessions) |
| cron | `GET /api/cron/jobs?profile=`; `POST /api/cron/jobs/{id}/pause`, `/resume`, `/trigger` (answers when the run ends, up to 10 min; 409 when running); `DELETE /api/cron/jobs/{id}`. Never create or edit |
| restart | `POST /api/gateway/restart`, then poll `GET /api/actions/gateway-restart/status?lines=40` every 2 s until `exit_code` (up to 5 min) |
| update | `GET /api/hermes/update/check?force=true`; when `update_available` and `can_apply`: `POST /api/hermes/update`, then poll `hermes-update` status (up to 30 min) |

`awaitAction` polls through the dashboard's own restart: a failed poll is
skipped (up to 150 in a row), 401s included while the client renews. A 403,
404 or malformed answer ends the wait. 30 polls of "not running, no exit code"
in a row is an unknown outcome. The gateway's command catalog is not used;
`slash.exec` only runs `model ...`.

## Bot Screen

A bot's own desktop on the gateway's host (Hermes 0.22.5,
`tui_gateway/contracts/display.py`). Every call names its bot (`profile`), or
the gateway answers for its launch profile. Errors are code 5300
(`data.code: viewer_mismatch` for a viewer id this socket did not mint).

| Purpose | Call |
|---|---|
| status | `display.status {profile}` → `{supported, installed, running, blocker, lease, profile_key, ...}`; `-32601`: no screen (older gateway) |
| start | `display.start {profile}` (answers once up, up to 2 min). Never `display.stop` or `display.install` |
| still | `display.thumbnail {profile}` → `{data_url}`; null while off or while a human has control |
| watch | `display.observe {profile, viewer_id?}` → status plus `{ticket, viewer_id}`; a viewer id this socket minted is kept, any other replaced. The ticket (single use, 30 s) opens `ws(s)://{host}{prefix}/api/display/ws?display_ticket=<ticket>`: raw RFB 3.8, binary frames, no other auth |
| take over | `display.lease.acquire {profile, viewer_id}` → `{lease}` |
| hand back | `display.lease.release {profile, viewer_id}`, or `{profile, force: true}` for another viewer's or a lost one's |

The lease is `{holder: agent | human, viewer_hash, epoch}`; a viewer holds it
when `viewer_hash` is the first 12 hex digits of SHA-256 of its viewer id.
`epoch` grows on every change. While a human holds it the agent's screen
tools refuse and the gateway drops input from every other viewer.

Clipboard: the holder's paste reaches the desktop (RFB ClientCutText, at
most 256 KiB, Xvnc `-MaxCutText`); the desktop's clipboard never reaches a
viewer (Xvnc `-SendCutText=0`, a Hermes rule), so copying from the screen
to the phone is not possible.

Stream close codes: 4000 another viewer took control, 4001 the screen is
not running, 4401 ticket spent or late, 1003 a text frame or a paste over
256 KiB. The client closing with 1000 or 1001 hands its control back; any
other code (the app uses 4100) or a dropped link keeps it.

Events (session-less, every client, every bot of the process):
`display.status` (a full status) and `display.lease` (`{profile_key,
lease}`), matched to a bot by `profile_key`. The gateway starts sending them
once any client has called `display.status` in that process.

## Events

Reduced into the chat (`ChatReducer`): `message.start`, `message.delta
{text}`, `message.interim`, `message.complete {text, status: complete |
interrupted | error, error, reasoning, usage}`, `reasoning.delta`,
`reasoning.available`, `thinking.delta` (a status label, not reasoning),
`tool.generating`, `tool.start {tool_id, name, context, args}`,
`tool.progress` (older gateways), `tool.complete {tool_id, result, summary,
duration_s}`, `todo.updated {todos: [{id, content, status, parent?}],
revision}` (the agent's whole plan; an older revision is dropped; shown only
while the turn runs, and a resume carries it as `todo_state`), `status.update`, `session.info {running, title, model, usage}`,
`session.title`, `session.usage`, `session.resume_progress`, `error`,
`request.cancel {id}`, `session.reclaimed`, `sessions.changed`.

Synthetic, from the client: `x.replay_truncated` (reload), `x.session_lost`
(resume again).

Read outside the chat (`SessionSignals`): `session.info` (runtime id → stored
id and profile, for notification taps), `notification.show {text, level, key,
ttl_ms}`, `notification.clear {key}`, `background.complete {task_id, text}`.

`sessions.changed` is the only sign that another process (Telegram, desktop,
cron) wrote a session; the app re-reads the open chat when idle, and, while
it is away, checks each bot's `canonical_session.message_count`
(`profiles.list`) for new messages to notify. That count moves on every
message; `last_active` stays at the start of the turn.

History rows are flat `{role, text, timestamp, row_id, reasoning?}` and tool
rows `{role: "tool", name, context, args}`. Attachments become `"[image]"`.
Agent media arrives as `MEDIA: <path>` lines, `@image:<path>` refs or data
URLs.

**Reasoning quirk.** For a model with no reasoning tokens,
`reasoning.available` is the answer itself. `ChatMessage.visibleReasoning`
drops reasoning equal to (or a prefix of) the answer.

## Server requests

The agent's questions are JSON-RPC **requests** from the server (`id` +
`method`); the agent blocks until the client answers with the same `id`. Ids
are strings (`srq-<12 hex>`); `params.session_id` is the runtime id.

| Method | Client |
|---|---|
| `clarify {questions[1–5], answers?}` | card |
| `approval {command, description, choices[], allow_permanent?, smart_denied?}` | card |
| `sudo {command}`, `secret {env_var, prompt}` | masked card |
| `vault.unlock_prompt`, `vault.save_login`, `vault.code`, `display.install.sudo` | `{"value": ""}` (skipped) |
| `terminal.read`, `preview.read`, `window.read`, `preview.act`, `tour`, `setup_beat`, `theme.apply`, `theme.pick` | error **4404** (not shown here, so a desktop on the same session can take it) |
| anything else | error `-32601` |

The client must answer every method it is offered in `client.capabilities`,
or the agent waits out its deadline (clarify: 300 s).

- **clarify.** Drop questions with a blank `qid` or text, and blank or over
  8000-char choices; no choice left = free text; nothing usable → error
  `-32602`. ` (Recommended)` on a choice is styled, never stripped. Every
  question with choices also takes an "Other" answer.
- **approval.** `choices` ⊆ `once, session, always, deny`; empty =
  `["once", "deny"]`; `allow_permanent: false` hides `always`.

Answers (one frame, on the socket the request came or was replayed on):

| Request | Result |
|---|---|
| clarify | `{"answers": {"<qid>": <string or null>}}`; multi-select is a JSON-encoded array in a string; skipped = `null`; `{}` cancels the request |
| approval | `{"choice": "once" \| "session" \| "always" \| "deny"}` |
| sudo, secret | `{"value": "<text>"}`; `""` = skipped |

A JSON-RPC error answer means "no answer". `request.cancel {id}` withdraws a
request (timeout, interrupt, another client answered). A request written while
the socket was down comes back in `open_requests` (from `session.resume`,
`session.activate`, `session.events.since`; `params.answers` holds locked
answers). That list is complete for the session: unlisted ones are dropped.
After a reconnect, requests of unwatched sessions are forgotten. Not used:
`clarify.lock`, `approval.respond`.

Reference: Hermes `tui_gateway/server_requests.py`,
`tui_gateway/contracts/server_requests.py`.
