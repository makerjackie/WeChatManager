import XCTest
@testable import WeChatManager

final class PatchConfigurationTests: XCTestCase {
    func testDecodesUpstreamConfiguration() throws {
        let json = """
        [
          {
            "version": "12345",
            "targets": [
              {
                "identifier": "multiInstance",
                "entries": [
                  { "arch": "arm64", "addr": "100001000", "asm": "20008052C0035FD6" }
                ]
              }
            ]
          }
        ]
        """

        let configurations = try JSONDecoder().decode(
            [PatchConfiguration].self,
            from: Data(json.utf8)
        )

        XCTAssertEqual(configurations.count, 1)
        XCTAssertEqual(configurations[0].version, "12345")
        XCTAssertEqual(configurations[0].targets[0].identifier, "multiInstance")
        XCTAssertEqual(configurations[0].targets[0].entries[0].address, 0x100001000)
        XCTAssertEqual(
            configurations[0].targets[0].entries[0].replacement,
            Data([0x20, 0x00, 0x80, 0x52, 0xC0, 0x03, 0x5F, 0xD6])
        )
    }

    func testRejectsInvalidHexadecimalInstruction() {
        let json = """
        [{"version":"1","targets":[{"identifier":"multiInstance","entries":[{"arch":"arm64","addr":"1000","asm":"XYZ"}]}]}]
        """

        XCTAssertThrowsError(
            try JSONDecoder().decode([PatchConfiguration].self, from: Data(json.utf8))
        )
    }
}
