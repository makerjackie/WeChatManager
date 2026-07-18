import XCTest
@testable import WeChatManager

final class WeChatDataLocatorTests: XCTestCase {
    private var temporaryHome: URL!

    override func setUpWithError() throws {
        temporaryHome = FileManager.default.temporaryDirectory.appending(
            path: "WeChatDataLocatorTests-\(UUID().uuidString)"
        )
        try FileManager.default.createDirectory(at: temporaryHome, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let temporaryHome {
            try? FileManager.default.removeItem(at: temporaryHome)
        }
    }

    func testFindsModernAccountFilesVideosAndCache() async throws {
        let accountRoot = temporaryHome.appending(
            path: "Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/wxid_example"
        )
        for relativePath in ["msg/file", "msg/video", "cache", "db_storage"] {
            try FileManager.default.createDirectory(
                at: accountRoot.appending(path: relativePath),
                withIntermediateDirectories: true
            )
        }

        let scan = await WeChatDataLocator(homeDirectory: temporaryHome).scan()
        let locations = scan.locations

        XCTAssertEqual(scan.accessState, .available)
        XCTAssertTrue(locations.contains { $0.category == .root })
        XCTAssertTrue(locations.contains { $0.category == .account })
        XCTAssertTrue(locations.contains { $0.category == .files })
        XCTAssertTrue(locations.contains { $0.category == .videos })
        XCTAssertTrue(locations.contains { $0.category == .cache })
        XCTAssertEqual(Set(locations.map(\.id)).count, locations.count)
        let accountLocations = locations.filter { $0.accountIdentifier != nil }
        XCTAssertTrue(accountLocations.allSatisfy { $0.accountIdentifier == "wxid_example" })
        XCTAssertTrue(accountLocations.allSatisfy { !$0.title.contains("wxid_example") })
        XCTAssertTrue(accountLocations.allSatisfy { !$0.detail.contains("wxid_example") })
    }

    func testDoesNotInventMissingLocations() async {
        let scan = await WeChatDataLocator(homeDirectory: temporaryHome).scan()
        XCTAssertTrue(scan.locations.isEmpty)
        XCTAssertEqual(scan.accessState, .notFound)
    }
}
