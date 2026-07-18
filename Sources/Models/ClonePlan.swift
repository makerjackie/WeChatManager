import Foundation

struct ClonePlan: Codable, Identifiable, Sendable, Equatable {
    let id: UUID
    let name: String
    let items: [ClonePlanItem]
    let sourceVersion: String
    let sourceBuild: String
    let createdAt: Date
    let modifiedAt: Date
}
