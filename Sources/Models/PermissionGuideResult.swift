import Foundation

enum PermissionGuideResult: Sendable, Equatable {
    case ready(String)
    case unavailable(String)
    case needsAction(String)

    var title: String {
        switch self {
        case .ready: "权限可用"
        case .unavailable: "暂时不需要"
        case .needsAction: "尚未取得权限"
        }
    }

    var detail: String {
        switch self {
        case .ready(let detail), .unavailable(let detail), .needsAction(let detail): detail
        }
    }

    var systemImage: String {
        switch self {
        case .ready: "checkmark.circle.fill"
        case .unavailable: "info.circle.fill"
        case .needsAction: "exclamationmark.triangle.fill"
        }
    }
}
