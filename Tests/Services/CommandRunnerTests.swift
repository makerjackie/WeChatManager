import XCTest
@testable import WeChatManager

final class CommandRunnerTests: XCTestCase {
    func testStopsCommandWhenTimeoutExpires() async throws {
        let runner = CommandRunner()
        let startedAt = Date()

        do {
            _ = try await runner.run(
                executableURL: URL(fileURLWithPath: "/bin/sleep"),
                arguments: ["5"],
                timeout: 0.05
            )
            XCTFail("超时命令不应成功返回")
        } catch is CommandTimeoutError {
            XCTAssertLessThan(Date().timeIntervalSince(startedAt), 2)
        }
    }
}
