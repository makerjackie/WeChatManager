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
        case .multiInstance: "让“再开一个”更稳定。"
        case .preventRevoke: "在本机保留已撤回的消息。"
        }
    }

    var systemImage: String {
        switch self {
        case .multiInstance: "square.on.square"
        case .preventRevoke: "arrow.uturn.backward.message"
        }
    }
}
