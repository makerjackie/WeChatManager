import XCTest
@testable import WeChatManager

final class PermissionGuideResultTests: XCTestCase {
    func testReadyAndUnavailableResultsContinueAutomatically() {
        XCTAssertTrue(PermissionGuideResult.ready("已允许").canContinue)
        XCTAssertTrue(PermissionGuideResult.unavailable("当前不需要").canContinue)
    }

    func testNeedsActionResultStaysOnCurrentStep() {
        XCTAssertFalse(PermissionGuideResult.needsAction("请重试").canContinue)
    }
}
