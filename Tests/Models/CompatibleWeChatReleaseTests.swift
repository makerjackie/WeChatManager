import XCTest
@testable import WeChatManager

final class CompatibleWeChatReleaseTests: XCTestCase {
    func testRecommendedReleaseUsesExactOfficialBuildDownload() {
        let release = CompatibleWeChatRelease.recommended

        XCTAssertEqual(release.version, "4.1.5.28")
        XCTAssertEqual(release.build, "32288")
        XCTAssertEqual(release.officialDownloadURL.host, "dldir1.qq.com")
        XCTAssertTrue(release.officialDownloadURL.lastPathComponent.contains(release.build))
        XCTAssertEqual(release.sha256.count, 64)
    }

    func testKnownBuildsHaveFriendlyVersionLabels() {
        XCTAssertEqual(
            CompatibleWeChatRelease.label(for: "32288"),
            "微信 4.1.5.28（32288）"
        )
        XCTAssertEqual(
            CompatibleWeChatRelease.label(for: "99999"),
            "微信构建 99999"
        )
    }
}
