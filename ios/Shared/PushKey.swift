import CryptoKit
import Foundation

/// This phone's push key and the messages it opens. The app makes the key
/// (`PushBridge`) and hands it to the Pomelu Hermes plugin, which seals each
/// message with it (AES-256-GCM); the notification extension opens each push
/// with it. The key sits in the App Group's defaults, which both targets
/// read; both compile this file, so they cannot disagree on the format.
enum PushKey {
  static let appGroup = "group.se.royan.pomelu"

  /// Where the extension leaves the bot of a message, for a tap.
  static let botKey = "pomelu.bot"

  private static let defaultsKey = "push.key"

  /// A message as the plugin seals it (`push.py`).
  struct Message: Decodable {
    let bot: String
    let title: String?
    let body: String?
  }

  /// The key, base64; a new one when [renew] (another account) or none yet.
  static func current(renew: Bool) -> String? {
    guard let defaults = UserDefaults(suiteName: appGroup) else { return nil }
    if !renew, let key = defaults.string(forKey: defaultsKey) { return key }
    let key = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0).base64EncodedString() }
    defaults.set(key, forKey: defaultsKey)
    return key
  }

  /// `base64(nonce || ciphertext || tag)` opened; nil for another key.
  static func open(_ sealed: String) -> Message? {
    guard
      let key = UserDefaults(suiteName: appGroup)?.string(forKey: defaultsKey),
      let keyData = Data(base64Encoded: key),
      let raw = Data(base64Encoded: sealed),
      let box = try? AES.GCM.SealedBox(combined: raw),
      let plain = try? AES.GCM.open(box, using: SymmetricKey(data: keyData))
    else { return nil }
    return try? JSONDecoder().decode(Message.self, from: plain)
  }
}
