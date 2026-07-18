import Foundation

enum NavigationPage: String, CaseIterable, Identifiable {
    case overview
    case instances
    case plans
    case files
    case enhancements
    case settings

    var id: Self { self }

    var title: String {
        switch self {
        case .overview: "总览"
        case .instances: "分身管理"
        case .plans: "方案与更新"
        case .files: "文件管理"
        case .enhancements: "兼容增强"
        case .settings: "设置"
        }
    }

    var systemImage: String {
        switch self {
        case .overview: "rectangle.grid.2x2"
        case .instances: "square.stack.3d.up"
        case .plans: "arrow.triangle.2.circlepath.icloud"
        case .files: "folder"
        case .enhancements: "wand.and.stars"
        case .settings: "gearshape"
        }
    }
}
