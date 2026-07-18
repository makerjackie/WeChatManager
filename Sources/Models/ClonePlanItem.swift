import Foundation

struct ClonePlanItem: Codable, Identifiable, Sendable, Equatable {
    let index: Int
    let displayName: String

    var id: Int { index }
}
