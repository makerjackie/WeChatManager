import Foundation

struct CleanupResult: Sendable, Equatable {
    let movedItemCount: Int
    let destination: URL
}
