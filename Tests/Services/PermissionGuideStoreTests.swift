import XCTest
@testable import WeChatManager

@MainActor
final class PermissionGuideStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUpWithError() throws {
        suiteName = "PermissionGuideStoreTests-\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
    }

    func testGuideIsPresentedUntilCompleted() {
        let store = PermissionGuideStore(defaults: defaults)

        XCTAssertTrue(store.shouldPresentGuide)

        store.markCompleted()

        XCTAssertFalse(store.shouldPresentGuide)
    }

    func testOlderGuideVersionDoesNotSuppressCurrentGuide() {
        defaults.set(0, forKey: "permissionGuideCompletedVersion")

        XCTAssertTrue(PermissionGuideStore(defaults: defaults).shouldPresentGuide)
    }
}
