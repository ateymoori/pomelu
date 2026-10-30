import UserNotifications

/// Opens a bot's message that came by push: the push carries it sealed
/// (`enc`), with a plain "New message" alert that shows only when it cannot
/// be opened. The bot's name and words replace it, grouped per bot like the
/// app's own message rows, and the bot is kept for a tap (`PushBridge`).
final class NotificationService: UNNotificationServiceExtension {
  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
    guard
      let content = request.content.mutableCopy() as? UNMutableNotificationContent,
      let sealed = request.content.userInfo["enc"] as? String,
      let message = PushKey.open(sealed)
    else { return contentHandler(request.content) }
    content.title = message.title.flatMap { $0.isEmpty ? nil : $0 } ?? message.bot
    content.body = message.body ?? ""
    content.threadIdentifier = "message/\(message.bot)"
    content.userInfo = [PushKey.botKey: message.bot]
    contentHandler(content)
  }
}
