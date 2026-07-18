import XCTest
@testable import WeChatManager

final class PermissionGuideStoreTests: XCTestCase {
    @MainActor
    func testGuideIsPresentedUntilCompleted() throws {
        let (defaults, suiteName) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = PermissionGuideStore(defaults: defaults)

        XCTAssertTrue(store.shouldPresentGuide)

        store.markCompleted()

        XCTAssertFalse(store.shouldPresentGuide)
    }

    @MainActor
    func testOlderGuideVersionDoesNotSuppressCurrentGuide() throws {
        let (defaults, suiteName) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(0, forKey: "permissionGuideCompletedVersion")

        XCTAssertTrue(PermissionGuideStore(defaults: defaults).shouldPresentGuide)
    }

    @MainActor
    private func makeDefaults() throws -> (UserDefaults, String) {
        let suiteName = "PermissionGuideStoreTests-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return (defaults, suiteName)
    }
}
