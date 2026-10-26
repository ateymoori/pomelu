# Design — Liquid Glass over solid content

The look follows iOS 27 Liquid Glass as Apple's HIG ("Materials") describes
it: glass is the functional layer of controls and navigation that floats
above content, used sparingly; content stays on solid surfaces. The app uses
the regular variant only (it blurs and dims what is behind it, for
legibility); no clear variant. Nothing visual is hardcoded in a
widget: every value comes from `HermesTokens` (`lib/core/theme/tokens.dart`, a
`ThemeExtension`) and `AppTheme` (`lib/core/theme/app_theme.dart`).

## Glass or solid

| Glass (`AppGlass`) | Solid |
|---|---|
| Chat header and page bars: floating capsules and circles (the title, each button) with no slab; the content scrolls under them past a `ScrollEdge` fade | Assistant text, user bubble (`colors.userBubble`) |
| Composer (floating pill) | Tool rows, code blocks, link and media cards |
| Request card, slash palette, find bar, chat error banner | List rows, settings sections (`AppSurface`) |
| Bottom sheets (`AppSheet`): inset from the screen edges, every corner `radii.sheet` (32); a tall sheet sits on the edges, opaque | Sidebar: drawer on `surfaceElevated`, pane on `backdropMid` |
| Icon buttons off glass (a glass disc: the sidebar's, the map's) | Menus and dialogs (Material, `surfaceElevated`), snack bar |
| Location bars over the map | Page background `colors.backdropMid` (white / black) |

Rules:

- Never glass on content, never glass inside glass. A control on any glass
  pane, a bar included, draws no glass of its own: `AppIconButton` checks
  `AppGlass.isOn(context)` and shows a bare glyph (in the composer, the chat
  header; `AppCloseButton` is always bare, on its page bar). A filled
  (accent) button is never glass.
- Content scrolls under glass bars and pads by the bar's measured height;
  never hide it behind one.
- No gradients or decorative shadows outside `GlassSpec`.
- With Increase Contrast (`MediaQuery.highContrast`) or iOS Reduce
  Transparency on, every pane is solid (`glass.solidFill`), no blur. Flutter
  does not expose Reduce Transparency: `AppDelegate.swift` streams it
  (`PlatformChannels.reduceTransparency`), `reduceTransparencyProvider` reads
  it, and `AppChrome` hands it down as `GlassScope`.
- On Android the blur is a plain `BackdropFilter` per pane (no
  `BackdropGroup`, which did not blur there).

## Apple HIG checks

Checked against Apple's HIG pages "Materials", "Toolbars", "Sheets",
"Buttons", "Typography", "Color", "Layout", "Accessibility", "Motion",
"Dark Mode", "Text fields", "Toggles", "Menus", "App icons" and the
"Adopting Liquid Glass" guide:

- Glass only in the functional layer (bars, composer, sheets, floating
  controls), regular variant, used sparingly; content on solid surfaces.
- One glass layer: no glass control on a glass pane.
- Bars (iOS 26+): no slab. Bar buttons float as monochrome glass circles
  (close ✕, save ✓, menu, ⋯, find), never tinted; content fades away under
  them through a soft scroll edge (`ScrollEdge`). Page titles are centred.
  A More sheet only where the pane is too narrow.
- Icons: SF Symbols look-alikes (`CupertinoIcons`) everywhere, never
  Material icons.
- Forms ("Lists and tables"): inset-grouped, as iOS Settings. A
  `surfaces.grouped` page, `FormSection` cards on `groupedCell`, rows split
  by inset hairlines, a header above and a footer below. A text field is
  the row (no frame, no fill), its label at the start of the row (stacked
  above at accessibility text sizes). Buttons in a form are text rows
  (`FormButtonRow`), red for a destructive one.
- Sheets: one at a time (an action sheet closes before the next opens),
  drag handle, Cancel beside every confirm; short sheets float inset with
  every corner round, tall ones sit on the edges and are opaque, their page
  and cards raised as iOS raises them (`groupedElevated`: in dark mode a
  step lighter, so the sheet stands off the dimmed page). On a
  tablet's window every sheet is a centred card (an iPad form sheet): no
  handle, closed by a tap beside it or Escape.
- Accessibility: every icon has a label; Increase Contrast and Reduce
  Transparency make glass solid; reduced motion stills the pulses; text
  scales (Dynamic Type) and honors Bold Text.
- Color ("Color"): light and dark themes, each with an increased-contrast
  variant (`HermesTokens.lightContrast` / `darkContrast`, used as
  `MaterialApp.highContrastTheme`): quiet text 7:1, control edges 4.5:1,
  hairlines 3:1 (`test/core/theme/contrast_test.dart`).
- Buttons ("Buttons"): 44 pt or larger targets (48), at most two prominent
  buttons per view, capsules in rows, one height.
- Fields, toggles, menus ("Text fields", "Toggles", "Menus"): a field is a
  gray fill with no outline and no focus ring (an outline only under
  Increase Contrast); in a form card it is the row itself. A secure field
  has reveal; switches are adaptive with a title and an explanation;
  actions are pull-down menus (`showAppMenu`), never action sheets.
- Motion ("Motion"): 160–360 ms, interruptible, nothing waits for an
  animation; reduced motion stills it.
- App icon ("App icons"): full-bleed art with dark and tinted appearances
  (iOS applies the glass lighting itself); a flat image is allowed, layers
  (Icon Composer) would be a later polish.

Not followed: the glass is drawn by the app, so iOS 27's system glass
slider (clear to tinted) does not change it.

## Tokens

`GlassSpec` (`tokens/glass.dart`): `fill` (tint over the blurred backdrop),
`solidFill`, `rimLight` / `rimDark` (specular rim, light at the top), `shadow`
(floating panes only), `blur` 24, `saturation` 1.8, `rimWidth` 1. Light fill
is white at 72 %, dark `#1C1C1E` at 69 %.

`SurfaceSpec`: `surface` (cards, rows, bubbles; `#F2F2F7` / `#1C1C1E`),
`surfaceElevated` (menus, dialogs, drawer; `#FFFFFF` / `#2C2C2E`),
`surfacePressed`, `outline` (hairline), `borderWidth`, `disabledOpacity`,
`pendingOpacity`.

`HermesColors`: one accent, iOS blue `#0A84FF`, with `onAccent` for labels on
it and `accentText` for links and text buttons (4.5:1). `accentSoft` tints a
selection; `inverseAccent` is the accent on the snack bar. Text:
`textPrimary`, `textSecondary`, `textTertiary`. Status: `success`, `warning`,
`danger` (+ `dangerSoft`, `onDanger`). Controls: `inputOutline` (3:1 edge of a
field or control), `track` (idle progress, skeleton, drag handle), `divider`.
Also `userBubble` / `onUserBubble`, `codeBackground` / `codeText`,
`toolSurface`, `reasoningSurface`, `scrim` / `onScrim` / `scrimSolid`, and
`chart` (context usage parts). The whole Material `ColorScheme` is built from
tokens, so no stock widget shows a seed colour.

`Radii`: `xs` 6, `sm` 10, `md` 12 (cards, fields, rows, menus), `lg` 16 (glass
default, dialogs), `xl` 20, `sheet` 32, `pill` (buttons, chips, segments).
Glass corners are continuous (`RoundedSuperellipseBorder`).

`Spacing`: one scale, 4 / 8 / 12 / 16 / 24 / 32 (`xs` … `xxl`; `xxs` 2 only
between lines of one block). `gutter` 16, sheets inset `xl` (24). Touch target
`minTouch` 48; a text disclosure in a message (Thinking, a tool row)
`inlineRow` 32 across the column. `turnGap` 16 after each turn; parts inside a
turn sit `xs`–`sm` apart. Round buttons side by side: `iconGap` 4. Layout
widths: `sidebarWidth` 280, `chatPaneMin` 360, `sidebarPaneMax` 480,
`readingWidth` 840, `headerWideMin` 480, `railMaxHeight` 480,
`snackBarMaxWidth` 560, `sheetMaxWidth` 640.

`Motion`: `fast` 160, `normal` 240, `slow` 360 ms, `Curves.easeOutCubic`.
Short, eased, interruptible.

`TextScale`: Apple's Dynamic Type ladder (`largeTitle` 34 … `caption2` 11),
body line height 1.55 for replies. Monospace is one style:
`tokens.text.mono(size, height, color)`.

## Platform feel

| | iOS | Android |
|---|---|---|
| UI font | system (SF Pro): `fontFamily` null | Inter 400–700 (bundled, OFL) |
| Page transitions | `CupertinoPageTransitionsBuilder` | `PredictiveBackPageTransitionsBuilder` |
| Confirm dialog | `AlertDialog.adaptive` (system alert) | Material dialog |
| Switches | `SwitchListTile.adaptive` | Material switch |

JetBrains Mono for code on both; the font licenses show on the license page.

## Reusable widgets (`lib/core/ui/`, barrel `ui.dart`)

| Widget | Use |
|---|---|
| `AppGlass` | Glass pane. Default: `radii.lg`, rim, no shadow; `floating: true` adds the shadow. `.capsule`: stadium, floating (chips, pills). `.bar`: square, no rim, no shadow (the map's spot bar). A pane with a rim is a clear `Material`, so `ListTile`s and ink on it need none of their own |
| `AppSurface` | Solid content card: fill, optional hairline (`borderColor`), `radii.md`, no shadow |
| `AppIconButton` | Round 48 dp action; `icon` or `child`; tooltip is the label; glass disc unless `filled` or on glass; `busy` shows the spinner. `.plain`: a bare glyph (optional `color`) for actions inside content |
| `AppCloseButton` | Leading close of a full-screen page |
| `readingAppBar` | Glass bar of a full-screen page, title (and an optional `action`, such as Save) in the reading column; page sets `extendBodyBehindAppBar` |
| `ReadingColumn` | The one column: gutters, then at most `readingWidth`, centred |
| `AppSheet` | Bottom sheet with handle and title (`AppSheet.show`); `height`: `content`, `capped` (`sheetMaxFraction`), both glass; `tall` (`sheetTallFraction`), opaque on the grouped background for cards. A centred card at most `formSheetMaxHeight` tall where `AppSheet.isCentred` (two panes wide, `formSheetMinHeight` tall) |
| `showConfirmDialog`, `confirmDiscard` | Confirm a destructive action; "Discard your changes?" |
| `TextEntrySheet` | One-field sheet: ✕ and ✓ glass circles beside the title, the field the one row of a card |
| `showAppMenu`, `AppMenuItem` | iOS pull-down menu: a glass panel at the widget that asked, icons at the row ends, hairlines, optional title and hints, red for destructive. Every action list (⋯, attach, a file, a message) |
| `FormSection`, `FormRow`, `FormButtonRow`, `CardSlice` | Inset-grouped form: card with header and footer, rows split by hairlines (title, subtitle, value, trailing control, chevron), text-button rows, a long card built lazily in slices |
| `AppSegmented` | iOS segmented control (bot details tabs, theme mode) |
| `ScrollEdge` | Soft fade under a bar of floating glass buttons |
| `EmptyState` | Optional icon, title, message, action; `liveRegion` for failures |
| `ErrorText` | A failure line under what failed: small, `danger`, announced |
| `StatusDot` | Connection or busy dot with label; `.legend(color)`: a chart's color key |
| `AppSpinner` | The one busy ring; still under reduced motion |
| `PulseFade`, `ShimmerLine`, `SkeletonRow` | Idle pulse (`min`, `period`; the stream caret too); skeleton block; placeholder row |
| `RemoveBadge` | Remove mark on a pending attachment, full touch target |
| `FileBadge` | A file's type: a tile in the type's color (`colors.files`: PDF red, Word blue, Excel green, code purple) with the extension, else the kind's glyph. Every file pill and chip |
| `SectionLabel` | Heading over a group of rows, announced as a heading |
| `SizeReporter` | Reports its child's size (the floating layers the transcript pads by) |

Bars, buttons, segmented controls, fields, list rows, tabs, menus and dialogs
are plain Material, styled once in `AppTheme`. The picked segment is an accent
fill. The selected sidebar row has three cues: accent tint, a leading accent
bar (`selectedBar`) and a semibold name. Installed once above the navigator:
`AppChrome` (system bar icons follow the app theme; snack bar width) and
`FoldScope` (the window's fold). Never build a card inline.

## Screens

- **Sidebar.** Logo, app name, `StatusDot` (tap to reconnect). One row per bot:
  avatar (busy ring), name, status or last preview, time. Tap opens the bot's
  one chat. Footer: settings, refresh. Collapsed: `SidebarRail`, one avatar
  per bot. A long press on the app icon lists the first four bots in
  the same order (`botShortcutsProvider`), on Android each with its
  round avatar (picture or letter, no backdrop); one opens its chat. The
  same bots join the system share sheet's top row (Android Direct Share,
  iOS share suggestions), ranked by how often the user writes to them; one
  opens its chat with the share in the composer, skipping the picker.
- **Chat.** No title bar and no slab: the bot's name over its model in a
  glass capsule (a tap opens bot details), then glass buttons for the
  hidden-messages eye (when any), context meter (the percent used, warning
  and danger colors as it fills), screen (when the bot has
  one), find. Below `headerWideMin` the eye and the screen fold into a ⋯
  menu, shown only when one of them is there. Assistant replies are
  Markdown across the column, no bubble (tables: as wide as the column with
  wrapped cells, sideways scroll only when whole words do not fit; rounded
  corners, header in `toolSurface`, every other row in `tableStripe`); reasoning is one collapsed
  "Thinking" row; tool calls are one-line rows (two or more fold into one
  group). User messages are right-aligned bubbles, at most 80 % of the column.
  Pictures are square tiles that open a full-screen viewer. A file from the
  bot is a chip with a `FileBadge` and its size: tap opens it in the phone's
  default app; its ⋯ (or a long
  press) offers Open, Save to Files (a folder the user picks) and Share.
  When no app takes it (an APK), that sheet comes up instead. Long-press
  (or right-click, the menu then at the pointer) a message for copy, quote, share, hide on this phone, delete from here; a
  finished reply of the agent also offers Read aloud (the bot's own voice
  from the gateway; one at a time, a voice note stops it; Stop reading in
  the same menu and the snack bar) and Report (a reason, then the mail
  app opens a mail of the reply to Royan AB).
- **Composer.** One floating glass pill: tiles and file pills on top, the
  field, then attach (+), model and effort, and mic (empty) / send / Stop.
  Hold the mic to talk; slide left to cancel; a screen reader taps twice.
  Typing `/` docks the slash palette above it. Questions from the agent dock
  as a request card (clarify, approval, masked input) above the composer.
  While a turn runs with a plan (the agent's `todo` tool), a glass row above
  them says "Plan · 2 of 5" and the step in work; a tap opens every step
  (done ✓ struck through, in work half-filled, to do ○, sub-steps indented).
  Leaving the app lets go of the field: on return Samsung's keyboard can
  close but keep its inset, which leaves the composer raised. On a hardware
  keyboard Return sends and Shift- or Option-Return starts a new line;
  Command- or Control-Return sends too (Gboard types a plain Return as a
  new line, so on Android that is the one that sends).
- **Settings.** Glass page bar, then gateway URL, sign-in, test, save and
  connect, theme mode, notifications (Notify me; Stay connected on Android
  only), about (versions, licenses, privacy policy, royan.se/pomelu/privacy by default).
- **Screen.** A bot's desktop, full screen and always dark (as the
  picture viewer): ✕, a solid pill with the bot's name and who drives
  ("Bot in control", "You are in control", "Another viewer in control"),
  and ⋯ (Reconnect; Give control to the bot when someone else holds it)
  float on top; a glass capsule at the bottom holds Take over, or Drag
  and drop (tap what to move, pan or zoom, tap where it goes; the pill
  says which tap is next), the keyboard, Paste (the phone's clipboard, typed and on the desktop's
  clipboard) and Hand back; its main button's label shortens before the
  capsule overflows (large text). The desktop fits between them; pinch or
  double tap zooms, Whole screen (in the capsule) zooms out. In control,
  an accent ring edges the desktop, and while the keyboard is up only a
  key row (Esc, Tab, Ctrl, Alt, arrows, Paste, hide) sits above it: the
  capsule comes back with the keyboard down. Snack bars rise above the
  controls. In a window shorter than
  `railMaxHeight` the capsule joins the top row. Off: Start; lost: Reconnect.
  The chat header's screen button (folded into ⋯ below `headerWideMin`)
  shows only for a bot with a screen, its dot lit while a person drives it.
- **Bot details.** Glass sheet, 85 % tall, tabs Skills / Tools (read only),
  Instructions (`SOUL.md`, editable in a full-screen editor), Cron (pause,
  resume, run now, delete).

Content direction follows the text: a Persian reply is laid out right to left
as a whole; code stays left to right.

## Foldables, tablets and large screens

One layout for foldables, iPad and Android tablets, chosen by the window's
size alone (an iPad window in Split View or Stage Manager, an Android
window in split screen, is just a narrower window):

- Two panes from `sidebarWidth + chatPaneMin` (640 dp): a persistent sidebar
  (or rail) beside the chat. Below that the chat is full screen and the
  sidebar is a drawer, never wider than the screen minus one touch target.
- From `wideWindowMin` (1024 dp, a tablet either way up) the side pane is
  `sidebarWidthWide` (320), for more of each bot's last line. The chat's
  column stays `readingWidth`, centred.
- Sheets float centred as cards (see "Sheets" above) where the window takes
  two panes and is at least `formSheetMinHeight` tall; a phone on its side
  keeps the bottom sheet.
- Hardware keyboard and pointer: Return sends (see Composer), Control-Tab
  and Control-Shift-Tab step through the bots, Command (Control off Apple)
  with 1 to 9 opens the bot in that place and with comma the settings,
  Command or Control-F finds, Escape closes find, a sheet or a menu. A
  right-click opens a message's actions at the pointer (on a reply's text,
  the text's own menu, which carries them).
- The sidebar is a rail when the user collapsed it, and always in a window
  shorter than `railMaxHeight` (a phone on its side).
- Hinge aware: `FoldGeometry` reads `MediaQuery.displayFeatures`. Only an
  occluding vertical hinge moves the split (`PaneSplit`), leaving the hinge as
  dead space; a seamless fold (Z Fold inner screen) is ignored. The snap is
  dropped when it would push the sidebar past `sidebarPaneMax` or the chat
  under `chatPaneMin`.
- The chat header folds by its pane width, not the window's.
- The floating bottom layer is capped at `bottomLayerMaxFraction` (0.8) of the
  chat and scrolls above the send row; a request card at most
  `requestMaxFraction` (0.6). Send stays in reach with the keyboard up in
  landscape.
- Posture changes never restart the UI (Android `configChanges`; one
  `GlobalKey` per chat keeps scroll, text and attachments across drawer ⇄ two
  panes).
- iPhone Duo (iOS 27.1): closed 466 × 678 pt (drawer), open 669 × 951 pt
  either way up (two panes). iOS gives Flutter no fold
  (`displayFeatures` is empty), so the width alone decides. The open screen
  ignores orientation locks; lay out by width, read safe-area insets per
  edge (they are not symmetric), never the screen size.
- Test at 360, 640 and 840 dp, and 1024 × 1366 and 1280 × 800 (iPad 13"
  upright, an Android tablet on its side), and on the iPhone Duo closed and
  open.

## Accessibility

- 48 dp targets for every button; inline rows are 32 dp tall but span the
  column.
- Text 4.5:1, control edges and graphics 3:1, on both surface levels
  (`test/core/theme/contrast_test.dart`). Glass keeps text readable through
  its fill; under Increase Contrast it is solid.
- Reduced motion (`context.reduceMotion`): no viewer fade, still spinner and
  pulses, jumps instead of scroll animations.
- Text scale up to 2.0 without clipping. Labels on icon buttons; errors, new
  agent questions, the activity line and the composer status are live
  regions. Message actions are also a custom semantics action. State is never
  colour alone.

## App icon

Android adaptive icon and iOS icon from `dart run flutter_launcher_icons`
(the Pomelu mascot on a clear backdrop, `pomelu_icon.png`; Android
foreground and monochrome layers on a transparent adaptive background; iOS
light icon on white, since Apple rejects alpha, dark clear, tinted grey). The
notification icon is `res/drawable/ic_stat_notify.xml`. Only `pomelu_logo.png`
ships as an app asset.
