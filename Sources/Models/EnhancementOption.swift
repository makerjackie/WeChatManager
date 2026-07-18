import Foundation

enum EnhancementOption: String, CaseIterable, Identifiable, Sendable {
    case multiInstance
    case preventRevoke = "revoke"

    var id: Self { self }

    var title: String {
        switch self {
        case .multiInstance: "原生多开增强"
        case .preventRevoke: "保留已撤回消息"
        }
    }

    var detail: String {
        switch self {
        case .multiInstance: "解除微信自身的单实例限制，让“再开一个”在兼容版本上更稳定。"
        case .preventRevoke: "阻止本机客户端移除已收到的消息。该功能可能受微信版本更新影响。"
        }
    }

    var systemImage: String {
        switch self {
        case .multiInstance: "square.on.square"
        case .preventRevoke: "arrow.uturn.backward.message"
        }
    }
}
