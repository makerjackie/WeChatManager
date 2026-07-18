import Foundation

struct ClonePlanDocument: Codable, Sendable, Equatable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let plans: [ClonePlan]
    let modifiedAt: Date

    init(plans: [ClonePlan], modifiedAt: Date = .now) {
        schemaVersion = Self.currentSchemaVersion
        self.plans = plans
        self.modifiedAt = modifiedAt
    }

    static func preferred(
        local: ClonePlanDocument?,
        cloud: ClonePlanDocument?
    ) -> ClonePlanDocument? {
        switch (local, cloud) {
        case let (local?, cloud?):
            cloud.modifiedAt > local.modifiedAt ? cloud : local
        case let (local?, nil):
            local
        case let (nil, cloud?):
            cloud
        case (nil, nil):
            nil
        }
    }
}
