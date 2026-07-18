import Foundation

enum EnhancementCompatibility: Equatable {
    case checking
    case unavailable(reason: String, supportedBuilds: [String])
    case compatible(options: Set<EnhancementOption>, supportedBuilds: [String])

    var summary: String {
        switch self {
        case .checking: "正在检查兼容性…"
        case let .unavailable(reason, _): reason
        case .compatible: "当前微信版本可使用兼容增强"
        }
    }

    var supportedBuilds: [String] {
        switch self {
        case .checking:
            []
        case let .unavailable(_, supportedBuilds), let .compatible(_, supportedBuilds):
            supportedBuilds
        }
    }
}
