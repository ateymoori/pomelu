import Intents
import UIKit
import UniformTypeIdentifiers
import os

private let log = Logger(subsystem: "se.royan.pomelu", category: "ShareExtension")

/// The Hermes entry in the system share sheet. It has no compose UI (the app
/// picks the bot, unless the user picked one in the sheet's top row, a
/// share suggestion the app donated): it copies what it was given into the
/// App Group inbox (`ShareInbox`), opens the app at `pomelu://share` and
/// finishes.
///
/// A shared file only lives as long as the request, so every file is copied
/// before the extension completes. When the app cannot be opened the share
/// waits in the inbox and arrives the next time the app becomes active.
final class ShareViewController: UIViewController {
  /// `viewDidAppear` can run again (the sheet re-presents): one hand-over.
  private var started = false

  override func viewDidLoad() {
    super.viewDidLoad()
    let spinner = UIActivityIndicatorView(style: .large)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(spinner)
    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
    spinner.startAnimating()
  }

  /// Starts once the view is on screen: opening the app walks the responder
  /// chain, which reaches the application only from there.
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard !started else { return }
    started = true
    Task { await handOver() }
  }

  /// Copies the share into the inbox, then opens the app and finishes once
  /// the open has answered: finishing first can tear the extension down
  /// before the open goes through.
  private func handOver() async {
    let providers = (extensionContext?.inputItems as? [NSExtensionItem] ?? [])
      .flatMap { $0.attachments ?? [] }
    guard let root = ShareInbox.root else {
      log.error("no App Group container: is the entitlement missing?")
      return finish()
    }
    do {
      let folder = try ShareInbox.newShareFolder(in: root)
      var entries = await ShareCopier(folder: folder).entries(for: providers)
      if entries.isEmpty {
        try? FileManager.default.removeItem(at: folder)
        return finish()
      }
      // A bot of the top row (`BotSuggestions` in the app donated it).
      if let bot = (extensionContext?.intent as? INSendMessageIntent)?.conversationIdentifier,
         !bot.isEmpty {
        entries.insert(.target(bot), at: 0)
      }
      try ShareInbox.seal(entries, in: folder)
      openApp()
    } catch {
      log.error("share hand-over failed: \(error.localizedDescription)")
      finish()
    }
  }

  private func finish() {
    extensionContext?.completeRequest(returningItems: nil)
  }

  /// `UIApplication.shared` is off limits in an extension, and the old
  /// `openURL:` selector does nothing since iOS 18; the application found up
  /// the responder chain still opens a URL.
  private func openApp() {
    var responder: UIResponder? = self
    while let current = responder {
      if let application = current as? UIApplication {
        application.open(ShareInbox.wakeURL, options: [:]) { opened in
          // Not opened: the share waits in the inbox for the next launch.
          if !opened { log.error("could not open the app") }
          self.finish()
        }
        return
      }
      responder = current.next
    }
    log.error("no application in the responder chain")
    finish()
  }
}

/// Turns the share sheet's item providers into inbox entries within the caps:
/// all text and web links as one text entry first, then the files, then a
/// `skipped` entry counting the files left out.
private struct ShareCopier {
  let folder: URL

  private enum Outcome {
    case text(String)
    case copied(SharedEntry, bytes: Int64)
    case tooBig
    case unreadable
  }

  func entries(for providers: [NSItemProvider]) async -> [SharedEntry] {
    var texts: [String] = []
    var files: [SharedEntry] = []
    var skipped = 0
    var budget = ShareInbox.maxTotalBytes
    for provider in providers {
      let limit = min(ShareInbox.maxFileBytes, budget)
      let full = files.count >= ShareInbox.maxFiles
      switch await load(provider, limit: full ? nil : limit) {
      case let .text(text):
        if !text.isEmpty, !texts.contains(text) { texts.append(text) }
      case let .copied(entry, bytes):
        budget -= bytes
        files.append(entry)
      case .tooBig, .unreadable:
        skipped += 1
      }
    }
    var entries = texts.isEmpty ? [] : [SharedEntry.text(texts.joined(separator: "\n"))]
    entries += files
    if skipped > 0 { entries.append(.skipped(skipped)) }
    return entries
  }

  /// Reads one provider. A file type wins over a link and a link over plain
  /// text, so a photo is never sent as its file URL. A nil [limit] means the
  /// file count is used up: text still comes through, a file does not.
  private func load(_ provider: NSItemProvider, limit: Int64?) async -> Outcome {
    let types = provider.registeredTypeIdentifiers.compactMap { UTType($0) }
    if let type = types.first(where: Self.isFile) {
      guard let limit else { return .tooBig }
      return await copyRepresentation(of: provider, type: type, limit: limit)
    }
    let type = types.first { $0.conforms(to: .url) } ?? types.first { $0.conforms(to: .text) }
    guard let type else { return .unreadable }
    let item: NSSecureCoding
    do {
      item = try await provider.loadItem(forTypeIdentifier: type.identifier)
    } catch {
      log.error("unreadable shared item: \(error.localizedDescription)")
      return .unreadable
    }
    switch item {
    case let url as URL where url.isFileURL:
      guard let limit else { return .tooBig }
      return copy(url, suggestedName: provider.suggestedName, limit: limit)
    case let url as URL:
      return .text(url.absoluteString)
    case let text as String:
      return .text(text)
    case let text as NSAttributedString:
      return .text(text.string)
    default:
      // Text as raw data is a document, not a message.
      guard let limit else { return .tooBig }
      return await copyRepresentation(of: provider, type: type, limit: limit)
    }
  }

  private static func isFile(_ type: UTType) -> Bool {
    type.conforms(to: .data) && !type.conforms(to: .url) && !type.conforms(to: .text)
  }

  /// The provider's file for [type]. The system deletes it when the handler
  /// returns, so the copy happens inside the handler.
  private func copyRepresentation(
    of provider: NSItemProvider,
    type: UTType,
    limit: Int64,
  ) async -> Outcome {
    let suggestedName = provider.suggestedName
    return await withCheckedContinuation { done in
      _ = provider.loadFileRepresentation(forTypeIdentifier: type.identifier) { url, error in
        guard let url else {
          log.error("unreadable shared file: \(error?.localizedDescription ?? "")")
          return done.resume(returning: .unreadable)
        }
        done.resume(returning: copy(url, suggestedName: suggestedName, limit: limit))
      }
    }
  }

  /// Copies [source] into the share folder under a UUID-prefixed safe name.
  /// The copy is stamped now, so the age clean-up counts from the share.
  private func copy(_ source: URL, suggestedName: String?, limit: Int64) -> Outcome {
    let scoped = source.startAccessingSecurityScopedResource()
    defer { if scoped { source.stopAccessingSecurityScopedResource() } }
    var target: URL?
    do {
      let values = try source.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
      guard values.isRegularFile == true else { return .unreadable }
      let bytes = Int64(values.fileSize ?? 0)
      guard bytes <= limit else {
        log.info("skipped a shared file of \(bytes) bytes (limit \(limit))")
        return .tooBig
      }
      let name = Self.displayName(suggestedName, of: source)
      let fileName = "\(UUID().uuidString)-\(ShareInbox.diskName(name))"
      let destination = folder.appendingPathComponent(fileName)
      target = destination
      try FileManager.default.copyItem(at: source, to: destination)
      try FileManager.default.setAttributes(
        [.modificationDate: Date()],
        ofItemAtPath: destination.path,
      )
      let mime = UTType(filenameExtension: source.pathExtension)?.preferredMIMEType
      return .copied(.file(path: fileName, mime: mime, name: name), bytes: bytes)
    } catch {
      log.error("could not copy a shared file: \(error.localizedDescription)")
      if let target { try? FileManager.default.removeItem(at: target) }
      return .unreadable
    }
  }

  /// The provider's name (often without an extension) with the file's
  /// extension, or else the file's own name.
  private static func displayName(_ suggested: String?, of file: URL) -> String {
    guard let suggested, !suggested.isEmpty else { return file.lastPathComponent }
    let ext = file.pathExtension
    if ext.isEmpty || (suggested as NSString).pathExtension.lowercased() == ext.lowercased() {
      return suggested
    }
    return "\(suggested).\(ext)"
  }
}
