# Contributing to Pomelu

Thank you for your help. Bug reports, fixes, translations of the store text
and tests are welcome.

## Before you start

- **Bugs:** open an issue with the template. Give the app version, device,
  gateway version (`hermes --version`) and steps.
- **New features:** open an issue first. Pomelu is a focused client for one
  Hermes gateway; read the [scope](#scope) below. A pull request outside that
  scope will not be merged.
- **Security problems:** do not open an issue; see [SECURITY.md](SECURITY.md).

## Scope

Pomelu is a **client** of one Hermes Agent gateway (`hermes serve` or
`hermes dashboard`, JSON-RPC over WebSocket at `/api/ws`). It has no agent
logic of its own.

- One gateway connection. Settings: gateway URL with a setup guide, sign-in,
  test connection, theme, notifications, about. Nothing else in Settings.
- The side menu lists **bots** (Hermes profiles). Each bot has exactly one
  chat; a new conversation (`/new`, `/reset`, `/clear`) starts in the same
  chat, and earlier conversations load above it.
- Chat: streamed Markdown, tool activity, attachments both ways, a location
  from a map, stop, the agent's questions and approvals, its plan, read
  aloud, and Report (store policy for generative AI).
- Sharing from other apps and deep links into a chosen bot; the bots in the
  share sheet and the app icon's menu.
- Bot details: skills and tools (read only), instructions, `SOUL.md`
  (editable), cron jobs (pause, resume, run now, delete). Create a bot,
  rename it, change its picture, delete it (never the default bot).
- Bot Screen: watch a bot's own Linux desktop, take over, hand back. Start a
  stopped screen; never stop or install one.
- Out of scope: config editing, creating or editing cron jobs, more than one
  gateway.

## Set up

You need Flutter 3.47 (stable), Xcode for iOS, and Android Studio or the
Android SDK for Android. To test against a real agent, run
[Hermes Agent](https://github.com/NousResearch/hermes-agent) on your computer
(`hermes serve`); see [docs/TESTING.md](docs/TESTING.md) → "Local backend".

```bash
flutter pub get
dart run build_runner build -d   # freezed, json, riverpod
flutter gen-l10n
flutter analyze && dart analyze && flutter test
```

iOS uses Swift Package Manager only: never add a Podfile or CocoaPods.

## Rules for code

Read [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md),
[docs/DESIGN.md](docs/DESIGN.md) and [docs/PROTOCOL.md](docs/PROTOCOL.md)
first. The short version:

- Feature-first folders: `lib/features/<feature>/{data,domain,presentation}`.
  `lib/hermes/` is the gateway SDK: pure Dart, no Flutter imports.
- State with Riverpod 3 (`@riverpod` codegen); models with `freezed` and
  `json_serializable`.
- Nothing hardcoded: strings in `lib/l10n/app_en.arb`, colors, spacing and
  durations in `lib/core/theme/tokens.dart`, network constants in
  `lib/hermes/hermes_constants.dart`.
- Reuse the widgets in `lib/core/ui/`; icons are `CupertinoIcons`.
- Test behavior, one test per user-visible behavior; widget tests mount
  through `test/support/app_host.dart`.
- Keep the docs current when behavior changes.

## Pull requests

1. Fork, branch from `main`, keep the change small and on one topic.
2. `flutter analyze`, `dart analyze` and `flutter test` must pass (CI runs
   them).
3. For UI changes, add a screenshot or a short video (phone and, if it
   changes layout, a foldable or tablet width).
4. Use [Conventional Commits](https://www.conventionalcommits.org/)
   (`feat(chat): …`, `fix(share): …`).

By contributing, you agree that your contribution is licensed under the
[Apache License 2.0](LICENSE), like the rest of the code. Do not commit
secrets, signing keys or `android/key.properties`.

Read the [code of conduct](CODE_OF_CONDUCT.md).
