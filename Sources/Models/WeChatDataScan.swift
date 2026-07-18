import Foundation

enum WeChatDataAccessState: Sendable, Equatable {
    case available
    case notFound
    case unavailable
}

struct WeChatDataScan: Sendable, Equatable {
    let locations: [StorageLocation]
    let accessState: WeChatDataAccessState
}
