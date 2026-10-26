import '../domain/remote_input.dart';

/// The live view of a bot's screen: the page's web view, driven by
/// [ScreenSession]. The seam a test fakes.
abstract interface class ScreenSurface {
  /// Shows the stream at [stream]; sends input only without [viewOnly].
  Future<void> attach(Uri stream, {required bool viewOnly});

  /// Ends the stream. [handBack] tells the gateway this viewer is done, so
  /// control it held goes back to the bot; otherwise the gateway keeps it.
  Future<void> detach({required bool handBack});

  /// Input on or off: on only while this page has control.
  Future<void> setViewOnly({required bool viewOnly});

  /// A still of the screen while the stream comes up; null hides it.
  Future<void> poster(String? dataUrl);

  /// [backspaces], then [text], with [modifiers] held around them.
  Future<void> type(int backspaces, String text, Set<ScreenModifier> modifiers);

  /// One [key], with [modifiers] held around it.
  Future<void> press(ScreenKey key, Set<ScreenModifier> modifiers);

  /// Puts [text] on the desktop's clipboard (its own Paste).
  Future<void> setClipboard(String text);

  /// Drag on: the next tap picks up, the tap after drops. Off lets go of
  /// a pick without a drop.
  Future<void> drag({required bool on});

  /// Back to the whole desktop.
  Future<void> fit();

  /// The desktop filling a tall window, following what changes on it.
  Future<void> fill();
}
