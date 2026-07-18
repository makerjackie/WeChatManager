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
            "先了解用途，再交给 macOS 询问。"
        case .applicationAccess:
            "读取官方微信的版本、构建号与签名，用于安全创建分身。"
        case .fileAccess:
            "定位账号文件目录与占用空间，不读取或上传聊天内容。"
        case .appManagement:
            "仅在创建、更新、移除分身或执行兼容增强时修改指定应用。"
        }
    }
}
