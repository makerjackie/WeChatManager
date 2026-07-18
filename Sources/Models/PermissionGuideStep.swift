import Foundation

enum PermissionGuideStep: Int, CaseIterable, Identifiable, Sendable {
    case introduction
    case applicationAccess
    case fileAccess
    case appManagement

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .introduction: "开始"
        case .applicationAccess: "微信应用"
        case .fileAccess: "微信文件"
        case .appManagement: "应用管理"
        }
    }

    var systemImage: String {
        switch self {
        case .introduction: "hand.raised.fill"
        case .applicationAccess: "app.badge.checkmark"
        case .fileAccess: "folder.badge.gearshape"
        case .appManagement: "gearshape.2.fill"
        }
    }

    var summary: String {
        switch self {
        case .introduction:
            "了解权限用途。"
        case .applicationAccess:
            "识别当前微信，用于创建分身。"
        case .fileAccess:
            "按账号整理本机文件。"
        case .appManagement:
            "创建或更新分身时使用。"
        }
    }
}
