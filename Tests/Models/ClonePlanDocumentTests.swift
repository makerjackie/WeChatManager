import XCTest
@testable import WeChatManager

final class ClonePlanDocumentTests: XCTestCase {
    func testPrefersMostRecentlyModifiedDocument() {
        let older = ClonePlanDocument(
            plans: [makePlan(name: "本机方案", modifiedAt: Date(timeIntervalSince1970: 100))],
            modifiedAt: Date(timeIntervalSince1970: 100)
        )
        let newer = ClonePlanDocument(
            plans: [makePlan(name: "iCloud 方案", modifiedAt: Date(timeIntervalSince1970: 200))],
            modifiedAt: Date(timeIntervalSince1970: 200)
        )

        let preferred = ClonePlanDocument.preferred(local: older, cloud: newer)

        XCTAssertEqual(preferred, newer)
    }

    func testKeepsLocalDocumentWhenCloudIsMissing() {
        let local = ClonePlanDocument(plans: [makePlan(name: "本机方案", modifiedAt: .now)])

        XCTAssertEqual(ClonePlanDocument.preferred(local: local, cloud: nil), local)
    }

    private func makePlan(name: String, modifiedAt: Date) -> ClonePlan {
        ClonePlan(
            id: UUID(),
            name: name,
            items: [ClonePlanItem(index: 1, displayName: "微信分身 1")],
            sourceVersion: "4.1.11",
            sourceBuild: "269110",
            createdAt: modifiedAt,
            modifiedAt: modifiedAt
        )
    }
}
