part of '../tokens.dart';

/// Spacing scale and layout sizes (dp), fractions and counts.
@immutable
class Spacing {
  const Spacing();

  /// A hair (2 dp): between lines of one block and between list rows.
  final double xxs = 2;
  final double xs = 4;
  final double sm = 8;
  final double md = 12;
  final double lg = 16;
  final double xl = 24;
  final double xxl = 32;
  final double gutter = 16;
  final double barHeight = 56;

  /// The band under a bar where the page fades out over scrolled content.
  final double scrollEdgeFade = 24;

  /// Smallest tappable square (Material / WCAG 2.2).
  final double minTouch = 48;

  /// Height of a text disclosure inside a message ("Thinking", a tool row).
  final double inlineRow = 32;

  /// Space after each turn; parts inside a turn sit [xs] or [sm] apart.
  final double turnGap = 16;
  final double sidebarWidth = 280;

  /// The side pane on a wide window ([wideWindowMin] and up, a tablet in
  /// either orientation): room for more of each bot's last line.
  final double sidebarWidthWide = 320;

  /// Window width from which the side pane is [sidebarWidthWide].
  final double wideWindowMin = 1024;

  /// Widest the sidebar grows when it snaps onto a hinge.
  final double sidebarPaneMax = 480;

  /// Narrowest chat pane beside the sidebar: the two-pane layout starts at
  /// [sidebarWidth] + [chatPaneMin].
  final double chatPaneMin = 360;
  final double railWidth = 72;

  /// The one column of bar content, messages and composer: an open Fold
  /// or a phone on its side fills its pane; a tablet keeps a readable line.
  final double readingWidth = 840;
  final double emptyStateWidth = 344;

  /// Widest a sheet grows on a wide window.
  final double sheetMaxWidth = 640;

  /// Window height from which a sheet floats centred as a card (a form
  /// sheet, as on iPad) instead of rising from the bottom edge; the width
  /// must take two panes as well.
  final double formSheetMinHeight = 600;

  /// Tallest a centred sheet grows: a card, never a second screen.
  final double formSheetMaxHeight = 880;

  /// Screen share of a tabbed sheet (bot details).
  final double sheetTallFraction = 0.85;

  /// Accent bar that marks the selected row.
  final double selectedBar = 3;
  final double snackBarMaxWidth = 560;

  /// Space under a snack bar, clear of the floating composer.
  final double snackBarBottomInset = 88;

  /// Share of its column a user bubble may span.
  static const double bubbleWidthFactor = 0.8;

  double get bubbleMaxWidth => readingWidth * bubbleWidthFactor;

  /// Edge of one square picture tile.
  final double mediaTile = 112;

  /// Aspect of a video or link preview before its own is known.
  final double mediaAspect = 16 / 9;

  /// Row share a transcript separator's label may span before it wraps.
  final double separatorLabelFraction = 0.8;

  /// Tallest the slash palette grows before it scrolls.
  final double paletteMaxHeight = 280;
  final double avatar = 36;
  final double avatarSm = 28;

  /// A bot's picture on its edit page.
  final double avatarLg = 96;

  /// Room for the label at the start of a form row ("Password").
  final double formLabelWidth = 112;

  /// Text scale from which a form row stacks its label over the field.
  final double formStackTextScale = 1.35;

  /// A pull-down menu (`showAppMenu`).
  final double menuWidth = 260;

  /// One ready-made picture in the edit page's grid.
  final double characterTile = 56;

  /// The app icon on the license page.
  final double appIcon = 64;
  final double icon = 24;
  final double toolOutputMaxHeight = 220;
  final double attachmentLabelMaxWidth = 160;

  /// Side of a file type badge.
  final double fileBadge = 32;

  /// Vertical drag that closes a full-screen viewer.
  final double dragToDismiss = 120;

  /// Slide that cancels a held voice recording.
  final double slideToCancel = 80;

  /// Distance from the newest message within which the list follows output.
  final double followThreshold = 120;

  /// Gap between the composer outline and its round buttons.
  final double composerInset = 4;

  /// Gap between two round icon buttons side by side.
  final double iconGap = 4;

  /// Distance from the oldest row that loads the conversation before it.
  final double earlierThreshold = 600;

  /// Screen share a content sheet may take.
  final double sheetMaxFraction = 0.7;

  /// Chat-pane share an open request card may take.
  final double requestMaxFraction = 0.6;

  /// Least height of an open request card on a short pane: its title, a row
  /// and its actions.
  double get requestMinHeight => minTouch * 3;

  /// Chat-pane share of the whole bottom layer before it scrolls.
  final double bottomLayerMaxFraction = 0.8;

  /// Viewport share of an inline picture or video.
  final double mediaMaxHeightFraction = 0.6;

  /// Placeholder rows while a list loads.
  final int skeletonRows = 4;

  /// Share of a placeholder row its title block fills.
  final double skeletonTitleShare = 0.6;

  /// Where a jumped-to search hit lands (0 top, 1 bottom).
  final double hitAlignment = 0.3;

  /// Narrowest chat pane that keeps every header action on the bar.
  final double headerWideMin = 480;

  /// Window height under which the two-pane sidebar is a rail.
  final double railMaxHeight = 480;

  /// The Screen page's floating controls, at most.
  final double screenControlsWidth = 480;
}
