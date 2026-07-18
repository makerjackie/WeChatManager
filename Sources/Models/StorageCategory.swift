import Foundation

enum StorageCategory: String, Sendable {
    case root
    case account
    case files
    case videos
    case cache
    case legacy

    var title: String {
        switch self {
        case .root: "微信数据"
        case .account: "账号数据"
        case .files: "收到的文件"
        case .videos: "聊天视频"
        case .cache: "可清理缓存"
        case .legacy: "旧版微信数据"
        }
    }

    var systemImage: String {
        switch self {
        case .root: "externaldrive"
        case .account: "person.crop.circle"
        case .files: "doc"
        case .videos: "film"
        case .cache: "trash.slash"
        case .legacy: "archivebox"
        }
    }
}
