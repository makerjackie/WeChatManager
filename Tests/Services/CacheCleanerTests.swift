import XCTest
@testable import WeChatManager

final class CacheCleanerTests: XCTestCase {
    func testMovesOnlyAllowedCacheToTrashAndRecreatesDirectory() async throws {
        let root = FileManager.default.temporaryDirectory.appending(
            path: "CacheCleanerTests-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: root) }
        let cache = root.appending(path: "cache")
        let trash = root.appending(path: "trash")
        try FileManager.default.createDirectory(at: cache, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: trash, withIntermediateDirectories: true)
        try Data("temporary".utf8).write(to: cache.appending(path: "item.dat"))

        let cleaner = try CacheCleaner(allowedRoots: [cache], trashDirectory: trash)
        let result = try await cleaner.clean(urls: [cache])

        XCTAssertEqual(result.movedItemCount, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: cache.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: cache.appending(path: "item.dat").path))
        let movedItems = try FileManager.default.contentsOfDirectory(
            at: result.destination,
            includingPropertiesForKeys: nil
        )
        XCTAssertEqual(movedItems.count, 1)
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: movedItems[0].appending(path: "item.dat").path)
        )
    }

    func testRejectsPathOutsideAllowlist() async throws {
        let root = FileManager.default.temporaryDirectory.appending(
            path: "CacheCleanerAllowlistTests-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: root) }
        let allowed = root.appending(path: "allowed-cache")
        let unrelated = root.appending(path: "Documents")
        let trash = root.appending(path: "trash")
        for directory in [allowed, unrelated, trash] {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        let cleaner = try CacheCleaner(allowedRoots: [allowed], trashDirectory: trash)

        do {
            _ = try await cleaner.clean(urls: [unrelated])
            XCTFail("应当拒绝安全范围外的目录")
        } catch {
            XCTAssertTrue(FileManager.default.fileExists(atPath: unrelated.path))
        }
    }
}
