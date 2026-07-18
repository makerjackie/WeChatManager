import XCTest
@testable import WeChatManager

final class WeChatClonePlistEditorTests: XCTestCase {
    func testCreatesIsolatedIdentityAndRemovesURLSchemes() {
        let original: [String: Any] = [
            "CFBundleIdentifier": "com.tencent.xinWeChat",
            "CFBundleDisplayName": "WeChat",
            "CFBundleURLTypes": [["CFBundleURLSchemes": ["wechat"]]]
        ]

        let edited = WeChatClonePlistEditor().editedPlist(
            original,
            index: 2,
            displayName: "工作微信",
            version: "4.1.11",
            build: "269110"
        )

        XCTAssertEqual(edited["CFBundleIdentifier"] as? String, "com.makerjackie.WeChatManager.clone.2")
        XCTAssertEqual(edited["CFBundleDisplayName"] as? String, "工作微信")
        XCTAssertEqual(edited["WeChatManagerClone"] as? Bool, true)
        XCTAssertEqual(edited["WeChatManagerCloneIndex"] as? Int, 2)
        XCTAssertEqual(edited["WeChatManagerSourceBuild"] as? String, "269110")
        XCTAssertNil(edited["CFBundleURLTypes"])
    }
}
