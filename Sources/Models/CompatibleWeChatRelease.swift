import Foundation

struct CompatibleWeChatRelease: Equatable, Sendable {
    let version: String
    let build: String
    let sha256: String
    let officialDownloadURL: URL
    let archiveReleaseURL: URL

    var displayName: String {
        "微信 " + version
    }

    static let recommended = CompatibleWeChatRelease(
        version: "4.1.5.28",
        build: "32288",
        sha256: "8a7227f2094ece0053ee6d4157197c66fb521213a5004ed9b0cd1e85e8135696",
        officialDownloadURL: requiredURL(
            "https://dldir1.qq.com/weixin/Universal/Mac/xWeChatMac_universal_4.1.5.28_32288.dmg"
        ),
        archiveReleaseURL: requiredURL(
            "https://github.com/canc3s/wechat-versions/releases/tag/v4.1.5.28-mac"
        )
    )

    static func label(for build: String) -> String {
        switch build {
        case "31927": "微信 4.1.5.15（31927）"
        case "31960": "微信 4.1.5（31960）"
        case "32281": "微信 4.1.5.26（32281）"
        case "32288": "微信 4.1.5.28（32288）"
        case "34371": "微信 4.1.7.1（34371）"
        default: "微信构建 " + build
        }
    }

    private static func requiredURL(_ value: String) -> URL {
        guard let url = URL(string: value) else {
            fatalError("应用内置了无效 URL：\(value)")
        }
        return url
    }
}
