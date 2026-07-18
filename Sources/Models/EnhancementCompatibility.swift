import Foundation

enum EnhancementCompatibility: Equatable {
    case checking
    case unavailable(reason: String)
    case compatible(options: Set<EnhancementOption>)

    var summary: String {
        switch self {
        case .checking: "正在检查兼容性…"
        case let .unavailable(reason): reason
        case .compatible: "当前微信版本可使用兼容增强"
        }
    }
}
