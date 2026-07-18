import XCTest
@testable import WeChatManager

final class ShellEscapingTests: XCTestCase {
    func testQuotesSingleQuoteForShell() {
        XCTAssertEqual(
            ShellEscaping.quote("/tmp/Jackie's WeChat.app"),
            "'/tmp/Jackie'\\''s WeChat.app'"
        )
    }

    func testQuotesBackslashesAndQuotesForAppleScript() {
        XCTAssertEqual(
            ShellEscaping.appleScriptString("say \"你好\" \\ done"),
            "\"say \\\"你好\\\" \\\\ done\""
        )
    }
}
