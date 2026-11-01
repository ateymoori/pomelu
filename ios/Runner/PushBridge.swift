import Flutter
import UIKit
import UserNotifications
import os

/// iOS end of the push bridge (Dart: `ChannelPushBridge`; Android:
/// `PushBridge.kt`). `register {newKey}` asks Apple for this phone's token
/// and answers `{platform: ios, token, key, sandbox}`, or nil when Apple
/// refuses; `launchBot` answers the bot of the tap that opened the app,
/// once; `clear {bot}` removes that bot's delivered rows. Events: `{type: token}` when Apple gives a new token, `{type: tap,
/// bot}` for a tap while the app runs. The notification extension shows the
/// push; this only routes the tap. Main thread only.
final class PushBridge: NSObject, FlutterPlugin, FlutterStreamHandler {
  static let shared = PushBridge()

  private static let methodChannel = "se.royan.pomelu/push"
  private static let eventChannel = "se.royan.pomelu/push/events"
  private static let log = Logger(subsystem: "se.royan.pomelu", category: "PushBridge")

  private var sink: FlutterEventSink?
  private var waiting: [FlutterResult] = []
  private var token: String?
  private var launchBot: String?

  static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    registrar.addMethodCallDelegate(
      shared,
      channel: FlutterMethodChannel(name: methodChannel, binaryMessenger: messenger),
    )
    FlutterEventChannel(name: eventChannel, binaryMessenger: messenger)
      .setStreamHandler(shared)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "register":
      let newKey = (call.arguments as? [String: Any])?["newKey"] as? Bool ?? false
      guard PushKey.current(renew: newKey) != nil else { return result(nil) }
      waiting.append(result)
      UIApplication.shared.registerForRemoteNotifications()
    case "launchBot":
      result(launchBot)
      launchBot = nil
    case "clear":
      let bot = (call.arguments as? [String: Any])?["bot"] as? String ?? ""
      Self.clearDelivered(bot: bot)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    sink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }

  /// A push row has an id only Apple knows; the extension marks it by thread.
  private static func clearDelivered(bot: String) {
    let center = UNUserNotificationCenter.current()
    center.getDeliveredNotifications { rows in
      let ids = rows.filter { $0.request.content.threadIdentifier == "message/\(bot)" }
        .map(\.request.identifier)
      center.removeDeliveredNotifications(withIdentifiers: ids)
    }
  }

  /// `didRegisterForRemoteNotificationsWithDeviceToken`.
  func registered(deviceToken: Data) {
    let hex = deviceToken.map { String(format: "%02x", $0) }.joined()
    let renewed = token != nil && token != hex
    token = hex
    answer([
      "platform": "ios", "token": hex, "key": PushKey.current(renew: false) as Any,
      "sandbox": Self.sandbox,
    ])
    if renewed { sink?(["type": "token"]) }
  }

  /// `didFailToRegisterForRemoteNotificationsWithError`.
  func failed(_ error: Error) {
    Self.log.error("no APNs token: \(error.localizedDescription, privacy: .public)")
    answer(nil)
  }

  /// A push of [bot] was tapped; before Dart listens, it waits for `launchBot`.
  func tapped(bot: String) {
    if let sink { sink(["type": "tap", "bot": bot]) } else { launchBot = bot }
  }

  private func answer(_ value: Any?) {
    let results = waiting
    waiting = []
    results.forEach { $0(value) }
  }

  /// APNs development or production, as the provisioning profile says: a
  /// debug build is development, App Store and TestFlight builds production
  /// (they carry no profile).
  private static let sandbox: Bool = {
    #if targetEnvironment(simulator)
      return true
    #else
      guard
        let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
        let data = try? Data(contentsOf: url),
        let text = String(data: data, encoding: .isoLatin1),
        let start = text.range(of: "<?xml"), let end = text.range(of: "</plist>"),
        let plist = try? PropertyListSerialization.propertyList(
          from: Data(text[start.lowerBound..<end.upperBound].utf8), format: nil)
          as? [String: Any],
        let entitlements = plist["Entitlements"] as? [String: Any]
      else { return false }
      return entitlements["aps-environment"] as? String == "development"
    #endif
  }()
}
