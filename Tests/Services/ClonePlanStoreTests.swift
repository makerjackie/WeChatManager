import XCTest
@testable import WeChatManager

@MainActor
final class ClonePlanStoreTests: XCTestCase {
    func testSavesPlanLocallyAndToCloud() {
        var localStorage: [String: Data] = [:]
        var cloudStorage: [String: Data] = [:]
        let store = ClonePlanStore(
            localBackend: backend(storage: { localStorage }, update: { localStorage = $0 }),
            cloudBackend: backend(storage: { cloudStorage }, update: { cloudStorage = $0 })
        )
        let plan = makePlan(name: "工作方案")

        let cloudAvailable = store.save([plan])
        let loaded = store.load()

        XCTAssertTrue(cloudAvailable)
        XCTAssertEqual(loaded.plans, [plan])
        XCTAssertFalse(localStorage.isEmpty)
        XCTAssertFalse(cloudStorage.isEmpty)
    }

    func testUsesLocalFallbackWhenCloudIsUnavailable() {
        var localStorage: [String: Data] = [:]
        let unavailableCloud = ClonePlanStoreBackend(
            data: { _ in nil },
            setData: { _, _ in },
            synchronize: { false }
        )
        let store = ClonePlanStore(
            localBackend: backend(storage: { localStorage }, update: { localStorage = $0 }),
            cloudBackend: unavailableCloud
        )
        let plan = makePlan(name: "本机方案")

        XCTAssertFalse(store.save([plan]))
        XCTAssertEqual(store.load().plans, [plan])
    }

    func testNewerLocalPlanIsRetriedToCloud() throws {
        let key = "clonePlanDocument.v1"
        let localPlan = makePlan(name: "本机新方案")
        let cloudPlan = makePlan(name: "云端旧方案")
        let encoder = JSONEncoder()
        var localStorage = [
            key: try encoder.encode(
                ClonePlanDocument(
                    plans: [localPlan],
                    modifiedAt: Date(timeIntervalSince1970: 200)
                )
            )
        ]
        var cloudStorage = [
            key: try encoder.encode(
                ClonePlanDocument(
                    plans: [cloudPlan],
                    modifiedAt: Date(timeIntervalSince1970: 100)
                )
            )
        ]
        let store = ClonePlanStore(
            localBackend: backend(storage: { localStorage }, update: { localStorage = $0 }),
            cloudBackend: backend(storage: { cloudStorage }, update: { cloudStorage = $0 })
        )

        let loaded = store.load()
        let cloudDocument = try XCTUnwrap(
            try JSONDecoder().decode(ClonePlanDocument.self, from: cloudStorage[key] ?? Data())
        )

        XCTAssertEqual(loaded.plans, [localPlan])
        XCTAssertEqual(cloudDocument.plans, [localPlan])
    }

    private func backend(
        storage: @escaping () -> [String: Data],
        update: @escaping ([String: Data]) -> Void
    ) -> ClonePlanStoreBackend {
        ClonePlanStoreBackend(
            data: { key in storage()[key] },
            setData: { data, key in
                var values = storage()
                values[key] = data
                update(values)
            },
            synchronize: { true }
        )
    }

    private func makePlan(name: String) -> ClonePlan {
        ClonePlan(
            id: UUID(),
            name: name,
            items: [ClonePlanItem(index: 1, displayName: "微信分身 1")],
            sourceVersion: "4.1.11",
            sourceBuild: "269110",
            createdAt: Date(timeIntervalSince1970: 100),
            modifiedAt: Date(timeIntervalSince1970: 100)
        )
    }
}
