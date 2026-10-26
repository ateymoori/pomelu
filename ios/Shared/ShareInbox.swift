import Foundation
import os

/// The hand-over between the share extension and the app. The extension
/// copies one share into a folder of the App Group container and writes the
/// folder's manifest last; the app takes every folder that has one. Both
/// targets compile this file, so the two sides cannot disagree on the format.
///
/// The caps mirror Android (`SharedFiles.kt`) and the Dart side
/// (`HermesLimits`): a file the composer would refuse is not worth copying.
enum ShareInbox {
  static let appGroup = "group.se.royan.pomelu"

  /// The extension opens this to bring the app up. Only a wake-up: the inbox
  /// carries the share, and Dart ignores the link.
  static let wakeURL = URL(string: "pomelu://share")!

  /// Largest single file copied.
  static let maxFileBytes: Int64 = 50 * 1024 * 1024

  /// Largest total copied for one share.
  static let maxTotalBytes: Int64 = 64 * 1024 * 1024

  /// Most files copied for one share.
  static let maxFiles = 10

  /// Copies (and unfinished shares) older than this are deleted at start-up.
  static let maxAge: TimeInterval = 3 * 24 * 60 * 60

  /// Longest name of a copy on disk, in UTF-8 bytes, before the UUID prefix.
  /// A file system takes 255; the full display name still goes to Dart.
  static let maxNameBytes = 120

  /// An extension longer than this is part of the name, not a type.
  private static let maxExtensionChars = 16

  private static let manifestName = "manifest.json"
  private static let log = Logger(subsystem: "se.royan.pomelu", category: "ShareInbox")

  /// Pending shares in the App Group container; nil without the entitlement.
  static var root: URL? {
    FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
      .appendingPathComponent("ShareInbox", isDirectory: true)
  }

  static func isWakeURL(_ url: URL) -> Bool {
    url.scheme == wakeURL.scheme && url.host == wakeURL.host
  }

  /// A new, empty folder for one share. The name sorts by time, so the app
  /// hands shares over in the order they were made.
  static func newShareFolder(in root: URL) throws -> URL {
    let millis = Int64(Date().timeIntervalSince1970 * 1000)
    let folder = root.appendingPathComponent("\(millis)-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    return folder
  }

  /// Seals a share: from now on the app may take [folder]. File entries name
  /// a file inside the folder.
  static func seal(_ entries: [SharedEntry], in folder: URL) throws {
    let data = try JSONEncoder().encode(entries)
    try data.write(to: folder.appendingPathComponent(manifestName), options: .atomic)
  }

  /// Moves the files of every sealed share in [root] to [destination] and
  /// returns their entries in order, file paths now absolute. A taken share
  /// is removed; an unsealed one is still being written and stays. A file
  /// that cannot be moved is counted in a `skipped` entry.
  static func takeAll(from root: URL, into destination: URL) -> [SharedEntry] {
    let files = FileManager.default
    guard let folders = try? files.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)
    else { return [] }
    var taken: [SharedEntry] = []
    for folder in folders.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
      guard let data = try? Data(contentsOf: folder.appendingPathComponent(manifestName))
      else { continue }
      defer { try? files.removeItem(at: folder) }
      do {
        try files.createDirectory(at: destination, withIntermediateDirectories: true)
        var lost = 0
        for var entry in try JSONDecoder().decode([SharedEntry].self, from: data) {
          if entry.type == SharedEntry.file, let name = entry.path {
            let target = destination.appendingPathComponent(name)
            do {
              try files.moveItem(at: folder.appendingPathComponent(name), to: target)
              entry.path = target.path
            } catch {
              log.error("could not move a shared file: \(error.localizedDescription)")
              lost += 1
              continue
            }
          }
          taken.append(entry)
        }
        if lost > 0 { taken.append(.skipped(lost)) }
      } catch {
        log.error("unreadable share: \(error.localizedDescription)")
      }
    }
    return taken
  }

  /// Deletes the entries of [folder] last changed more than [maxAge] ago.
  static func removeOld(in folder: URL, maxAge: TimeInterval = maxAge) {
    let files = FileManager.default
    let cutoff = Date().addingTimeInterval(-maxAge)
    let entries = (try? files.contentsOfDirectory(
      at: folder,
      includingPropertiesForKeys: [.contentModificationDateKey],
    )) ?? []
    for entry in entries {
      let changed = try? entry.resourceValues(forKeys: [.contentModificationDateKey])
        .contentModificationDate
      if let changed, changed < cutoff { try? files.removeItem(at: entry) }
    }
  }

  /// The name a copy gets on disk: the last segment of [displayName], with
  /// control characters replaced and at most [maxNameBytes] UTF-8 bytes long.
  /// The extension is kept, so the type can still be told from it.
  static func diskName(_ displayName: String) -> String {
    let last = displayName.split(separator: "/", omittingEmptySubsequences: false).last ?? ""
    let cleaned = String(last.map { $0.isUnsafeInName ? "_" : $0 })
      .trimmingCharacters(in: .whitespaces)
    let base = cleaned.isEmpty ? "shared" : cleaned
    var stem = base
    var ext = ""
    if let dot = base.lastIndex(of: "."), dot > base.startIndex,
       base.distance(from: dot, to: base.endIndex) <= maxExtensionChars {
      stem = String(base[..<dot])
      ext = String(base[dot...])
    }
    return truncated(stem, toBytes: maxNameBytes - ext.utf8.count) + ext
  }

  /// The longest prefix of [text] that fits in [maxBytes] UTF-8 bytes,
  /// never splitting a character.
  private static func truncated(_ text: String, toBytes maxBytes: Int) -> String {
    var out = ""
    var used = 0
    for character in text {
      let bytes = character.utf8.count
      if used + bytes > maxBytes { break }
      out.append(character)
      used += bytes
    }
    return out
  }
}

/// One item of a share, with the fields the Dart `SharedItem` reads.
struct SharedEntry: Codable, Equatable {
  static let text = "text"
  static let file = "file"
  static let skipped = "skipped"
  static let target = "target"

  var type: String
  var text: String?
  /// In a manifest, the file's name inside its share folder; to Dart, the
  /// absolute path of the copy.
  var path: String?
  var mime: String?
  var name: String?
  /// How many files were left out, for a `skipped` entry.
  var count: Int?
  /// The bot picked in the share sheet's top row, for a `target` entry.
  var profile: String?

  static func text(_ text: String) -> Self { .init(type: Self.text, text: text) }

  static func file(path: String, mime: String?, name: String) -> Self {
    .init(type: Self.file, path: path, mime: mime, name: name)
  }

  static func skipped(_ count: Int) -> Self { .init(type: Self.skipped, count: count) }

  static func target(_ profile: String) -> Self { .init(type: Self.target, profile: profile) }

  /// The map the platform channel sends; absent fields are left out.
  var channelValue: [String: Any] {
    let fields: [String: Any?] = [
      "type": type, "text": text, "path": path, "mime": mime, "name": name, "count": count,
      "profile": profile,
    ]
    return fields.compactMapValues { $0 }
  }
}

private extension Character {
  /// A control character, a backslash or DEL: kept out of names on disk.
  var isUnsafeInName: Bool {
    unicodeScalars.contains { $0.value < 0x20 || $0 == "\\" || $0.value == 0x7F }
  }
}
