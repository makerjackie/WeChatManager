import Foundation

enum AppConstants {
    static let weChatBundleIdentifier = "com.tencent.xinWeChat"
    static let officialWeChatTeamIdentifier = "5A4RE8SF68"
    static let developerTeamIdentifier = "PCJ84YD7HQ"
    static let upstreamConfigurationURL = requiredURL(
        "https://raw.githubusercontent.com/sunnyyoung/WeChatTweak/refs/heads/master/config.json"
    )
    static let repositoryURL = requiredURL("https://github.com/makerjackie/WeChatManager")
    static let upstreamRepositoryURL = requiredURL("https://github.com/sunnyyoung/WeChatTweak")

    private static func requiredURL(_ value: String) -> URL {
        guard let url = URL(string: value) else {
            fatalError("应用内置了无效 URL：\(value)")
        }
        return url
    }
}
