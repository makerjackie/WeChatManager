import XCTest
@testable import WeChatManager

final class StorageScannerTests: XCTestCase {
    func testCountsAllocatedFileSizeRecursively() async throws {
        let root = FileManager.default.temporaryDirectory.appending(
            path: "StorageScannerTests-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(
            at: root.appending(path: "nested"),
            withIntermediateDirectories: true
        )
        try Data(repeating: 0x41, count: 8_192).write(to: root.appending(path: "first.bin"))
        try Data(repeating: 0x42, count: 4_096).write(to: root.appending(path: "nested/second.bin"))

        let size = try await StorageScanner().allocatedSize(of: root)

        XCTAssertGreaterThanOrEqual(size, 12_288)
    }
}
