import XCTest

@testable import Runner

/// The share hand-over between the extension and the app (`ShareInbox`).
final class ShareInboxTests: XCTestCase {
  private var root: URL!
  private var cache: URL!

  override func setUpWithError() throws {
    let base = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    root = base.appendingPathComponent("inbox", isDirectory: true)
    cache = base.appendingPathComponent("shared", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: root.deletingLastPathComponent())
  }

  func testSealedShareMovesIntoTheCacheInOrder() throws {
    let first = try ShareInbox.newShareFolder(in: root)
    try Data("hi".utf8).write(to: first.appendingPathComponent("a-note.txt"))
    try ShareInbox.seal(
      [.text("look"), .file(path: "a-note.txt", mime: "text/plain", name: "note.txt")],
      in: first,
    )
    let second = try ShareInbox.newShareFolder(in: root)
    try ShareInbox.seal([.text("later")], in: second)

    let taken = ShareInbox.takeAll(from: root, into: cache)

    let moved = cache.appendingPathComponent("a-note.txt").path
    XCTAssertEqual(
      taken,
      [
        .text("look"),
        .file(path: moved, mime: "text/plain", name: "note.txt"),
        .text("later"),
      ],
    )
    XCTAssertTrue(FileManager.default.fileExists(atPath: moved))
    XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: root.path), [])
  }

  func testUnsealedShareStaysForLater() throws {
    let folder = try ShareInbox.newShareFolder(in: root)
    try Data("hi".utf8).write(to: folder.appendingPathComponent("a.txt"))

    XCTAssertEqual(ShareInbox.takeAll(from: root, into: cache), [])
    XCTAssertTrue(FileManager.default.fileExists(atPath: folder.path))
  }

  func testMissingFileIsCountedAsSkipped() throws {
    let folder = try ShareInbox.newShareFolder(in: root)
    try ShareInbox.seal([.file(path: "gone.bin", mime: nil, name: "gone.bin")], in: folder)

    XCTAssertEqual(ShareInbox.takeAll(from: root, into: cache), [.skipped(1)])
  }

  func testChannelValueLeavesOutAbsentFields() {
    let value = SharedEntry.skipped(2).channelValue
    XCTAssertEqual(value.count, 2)
    XCTAssertEqual(value["type"] as? String, "skipped")
    XCTAssertEqual(value["count"] as? Int, 2)
  }

  func testDiskNameIsSafeAndKeepsTheExtension() {
    XCTAssertEqual(ShareInbox.diskName("../dir/a\u{1}b\\c.pdf"), "a_b_c.pdf")
    XCTAssertEqual(ShareInbox.diskName("  "), "shared")
    let long = ShareInbox.diskName(String(repeating: "é", count: 200) + ".jpeg")
    XCTAssertTrue(long.hasSuffix(".jpeg"))
    XCTAssertLessThanOrEqual(long.utf8.count, ShareInbox.maxNameBytes)
  }

  func testOldEntriesAreRemoved() throws {
    let file = root.appendingPathComponent("old.txt")
    try Data().write(to: file)
    try FileManager.default.setAttributes(
      [.modificationDate: Date(timeIntervalSinceNow: -ShareInbox.maxAge - 60)],
      ofItemAtPath: file.path,
    )
    let fresh = root.appendingPathComponent("new.txt")
    try Data().write(to: fresh)

    ShareInbox.removeOld(in: root)

    XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
    XCTAssertTrue(FileManager.default.fileExists(atPath: fresh.path))
  }
}
