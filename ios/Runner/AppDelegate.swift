import Flutter
import Intents
import UIKit
import UserNotifications
import os
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter_local_notifications: banners while the app is open, and taps.
    UNUserNotificationCenter.current().delegate = self
    // The background check for bot messages (Dart: WorkmanagerCheckScheduler)
    // runs in its own engine, with the plugins it reads through. iOS hands a
    // relaunched app its task only if the handler exists before this returns.
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "se.royan.pomelu.messageCheck",
      earliestBeginInSeconds: NSNumber(value: 15 * 60)
    )
    WorkmanagerPlugin.registerLaunchHandlers()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    PushBridge.shared.registered(deviceToken: deviceToken)
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    PushBridge.shared.failed(error)
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  /// A bot's message by push opens its chat; the rest are
  /// flutter_local_notifications'.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    if let bot = response.notification.request.content.userInfo[PushKey.botKey] as? String {
      PushBridge.shared.tapped(bot: bot)
      return completionHandler()
    }
    super.userNotificationCenter(
      center, didReceive: response, withCompletionHandler: completionHandler)
  }

  /// On screen the chat shows the message itself: no banner for a push.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let info = notification.request.content.userInfo
    if info[PushKey.botKey] != nil || info["enc"] != nil { return completionHandler([]) }
    super.userNotificationCenter(
      center, willPresent: notification, withCompletionHandler: completionHandler)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ShareBridge") {
      ShareBridge.register(with: registrar)
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "PushBridge") {
      PushBridge.register(with: registrar)
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "BotSuggestions") {
      FlutterMethodChannel(
        name: "se.royan.pomelu/shortcuts",
        binaryMessenger: registrar.messenger()
      ).setMethodCallHandler(BotSuggestions.handle)
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ReduceTransparency") {
      FlutterEventChannel(
        name: "se.royan.pomelu/reduce_transparency",
        binaryMessenger: registrar.messenger()
      ).setStreamHandler(ReduceTransparencyStream())
    }
  }
}

/// Sends the Reduce Transparency setting now and on every change. Flutter
/// does not expose it, and Liquid Glass must turn solid with it (Dart:
/// `reduceTransparencyProvider`).
final class ReduceTransparencyStream: NSObject, FlutterStreamHandler {
  private var observer: NSObjectProtocol?

  func onListen(
    withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    events(UIAccessibility.isReduceTransparencyEnabled)
    observer = NotificationCenter.default.addObserver(
      forName: UIAccessibility.reduceTransparencyStatusDidChangeNotification,
      object: nil,
      queue: .main
    ) { _ in events(UIAccessibility.isReduceTransparencyEnabled) }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    if let observer { NotificationCenter.default.removeObserver(observer) }
    observer = nil
    return nil
  }
}

/// Tells iOS about each bot as a conversation (an outgoing
/// `INSendMessageIntent`), so the share sheet offers it in its top row; the
/// share extension reads the one picked (`conversationIdentifier`). Dart:
/// `IosAppShortcuts`: `set {items: [{id, title, icon?}]}` replaces the bots,
/// and `used {id}` (the user wrote to one) tells it again, which ranks it
/// higher. Main thread only.
enum BotSuggestions {
  /// Every donation of this app carries it, so a new list replaces the old.
  private static let group = "se.royan.pomelu.bots"
  private static let log = Logger(subsystem: "se.royan.pomelu", category: "BotSuggestions")

  /// The bots of the last `set`, by id.
  private static var bots: [String: (title: String, icon: Data?)] = [:]

  static func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    switch call.method {
    case "set":
      let items = args?["items"] as? [[String: Any]] ?? []
      bots = [:]
      for item in items {
        guard let id = item["id"] as? String, !id.isEmpty else { continue }
        bots[id] = ((item["title"] as? String) ?? id, (item["icon"] as? FlutterStandardTypedData)?.data)
      }
      let ids = items.compactMap { $0["id"] as? String }
      INInteraction.delete(with: group) { _ in
        // The newest donation ranks first: the sidebar's first bot goes last.
        DispatchQueue.main.async { ids.reversed().forEach(donate) }
      }
      result(true)
    case "used":
      if let id = args?["id"] as? String { donate(id) }
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private static func donate(_ id: String) {
    guard let bot = bots[id] else { return }
    let image = bot.icon.map { INImage(imageData: $0) }
    let person = INPerson(
      personHandle: INPersonHandle(value: id, type: .unknown),
      nameComponents: nil,
      displayName: bot.title,
      image: image,
      contactIdentifier: nil,
      customIdentifier: id
    )
    let intent = INSendMessageIntent(
      recipients: [person],
      outgoingMessageType: .outgoingMessageText,
      content: nil,
      speakableGroupName: nil,
      conversationIdentifier: id,
      serviceName: nil,
      sender: nil,
      attachments: nil
    )
    let interaction = INInteraction(intent: intent, response: nil)
    interaction.direction = .outgoing
    interaction.groupIdentifier = group
    interaction.donate { error in
      if let error { log.error("bot \(id) not donated: \(error.localizedDescription)") }
    }
  }
}
