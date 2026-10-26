import Flutter
import UIKit
import os

/// iOS end of the share-sheet bridge, with the channel contract of Android's
/// `MainActivity.kt`: `initial` answers the share that opened the app (once),
/// later shares go out on the event channel, each as a list of
/// `{type, text?, path?, mime?, name?, count?}` maps.
///
/// The share extension leaves each share in the App Group inbox
/// (`ShareInbox`) and opens `pomelu://share`. That link only wakes the app:
/// it is left for `app_links` (Dart ignores it), and the inbox is read again
/// whenever the scene becomes active, so a share whose wake-up failed still
/// arrives the next time the app is opened. Files move into Caches/shared.
///
/// All state is touched on the main thread; file work runs on [io].
final class ShareBridge: NSObject, FlutterPlugin, FlutterStreamHandler,
  FlutterSceneLifeCycleDelegate
{
  private static let methodChannel = "se.royan.pomelu/share"
  private static let eventChannel = "se.royan.pomelu/share/events"
  private static let log = Logger(subsystem: "se.royan.pomelu", category: "ShareBridge")

  private let io = DispatchQueue(label: "se.royan.pomelu.share")
  private let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("shared", isDirectory: true)

  private var sink: FlutterEventSink?

  /// A share nobody has asked for yet (the app was still starting).
  private var pending: [[String: Any]]?

  /// Dart's `initial` call, parked while the inbox is still being read.
  private var initialWaiter: FlutterResult?

  /// Inbox reads in flight.
  private var reading = 0

  static func register(with registrar: FlutterPluginRegistrar) {
    let bridge = ShareBridge()
    let messenger = registrar.messenger()
    registrar.addMethodCallDelegate(
      bridge,
      channel: FlutterMethodChannel(name: methodChannel, binaryMessenger: messenger),
    )
    FlutterEventChannel(name: eventChannel, binaryMessenger: messenger)
      .setStreamHandler(bridge)
    registrar.addSceneDelegate(bridge)
    bridge.readInbox(cleaningUp: true)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "initial" else { return result(FlutterMethodNotImplemented) }
    if let ready = pending {
      pending = nil
      result(ready)
    } else if reading > 0 {
      initialWaiter?(nil)
      initialWaiter = result
    } else {
      result(nil)
    }
  }

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink,
  ) -> FlutterError? {
    sink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    readInbox()
  }

  /// An app that is already active gets no `sceneDidBecomeActive`. Never
  /// claims the URL: `app_links` must still see it.
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    if URLContexts.contains(where: { ShareInbox.isWakeURL($0.url) }) { readInbox() }
    return false
  }

  /// Takes every sealed share from the inbox. At start-up, old copies and
  /// shares the extension never finished go first.
  private func readInbox(cleaningUp: Bool = false) {
    guard let root = ShareInbox.root else {
      return Self.log.error("no App Group container: is the entitlement missing?")
    }
    reading += 1
    io.async { [cache] in
      if cleaningUp {
        ShareInbox.removeOld(in: cache)
        ShareInbox.removeOld(in: root)
      }
      let items = ShareInbox.takeAll(from: root, into: cache).map(\.channelValue)
      DispatchQueue.main.async { self.shareReady(items) }
    }
  }

  private func shareReady(_ items: [[String: Any]]) {
    reading -= 1
    if items.isEmpty {
      if reading == 0 { finishWaiter(nil) }
      return
    }
    Self.log.info("share of \(items.count) items")
    if initialWaiter != nil {
      finishWaiter(items)
    } else if let sink {
      sink(items)
    } else {
      pending = (pending ?? []) + items
    }
  }

  private func finishWaiter(_ items: [[String: Any]]?) {
    guard let waiter = initialWaiter else { return }
    initialWaiter = nil
    waiter(items)
  }
}
