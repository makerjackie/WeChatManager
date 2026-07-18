import XCTest
@testable import WeChatManager

final class StorageAccountGroupTests: XCTestCase {
    func testCreatesFriendlyDefaultAccountNames() {
        XCTAssertEqual(StorageAccountGroup.defaultName(for: 1), "微信号一")
        XCTAssertEqual(StorageAccountGroup.defaultName(for: 2), "微信号二")
        XCTAssertEqual(StorageAccountGroup.defaultName(for: 11), "微信号11")
    }
}
