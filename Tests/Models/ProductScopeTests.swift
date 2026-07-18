import XCTest
@testable import WeChatManager

final class ProductScopeTests: XCTestCase {
    func testNavigationFocusesOnCloneManagement() {
        XCTAssertEqual(
            NavigationPage.allCases,
            [.overview, .instances, .plans, .enhancements, .settings]
        )
    }

    func testPermissionGuideOnlyContainsRequiredSteps() {
        XCTAssertEqual(
            PermissionGuideStep.allCases,
            [.introduction, .applicationAccess, .appManagement]
        )
    }

    func testAppDoesNotRequestOtherApplicationData() {
        XCTAssertNil(Bundle.main.object(forInfoDictionaryKey: "NSAppDataUsageDescription"))
    }
}
