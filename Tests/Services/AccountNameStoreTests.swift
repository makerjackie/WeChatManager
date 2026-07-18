import XCTest
@testable import WeChatManager

final class AccountNameStoreTests: XCTestCase {
    @MainActor
    func testPersistsNamesWithoutStoringRawAccountIdentifier() throws {
        let suiteName = "AccountNameStoreTests-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = AccountNameStore(defaults: defaults)

        store.setName("工作微信", for: "wxid_private_identifier")

        XCTAssertEqual(store.names(for: ["wxid_private_identifier"]), [
            "wxid_private_identifier": "工作微信"
        ])
        let persistedDescription = String(describing: defaults.dictionaryRepresentation())
        XCTAssertFalse(persistedDescription.contains("wxid_private_identifier"))

        store.setName(nil, for: "wxid_private_identifier")
        XCTAssertTrue(store.names(for: ["wxid_private_identifier"]).isEmpty)
    }
}
