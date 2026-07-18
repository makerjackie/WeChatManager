import AppKit
import Foundation

@MainActor
struct WeChatLaunchService {
    private let workspace = NSWorkspace.shared

    func applicationURL() -> URL? {
        let locatedURL = workspace.urlForApplication(
            withBundleIdentifier: AppConstants.weChatBundleIdentifier
        )
        let fallbackURL = URL(fileURLWithPath: "/Applications/WeChat.app", isDirectory: true)
        let applicationURL = locatedURL ?? fallbackURL

        return FileManager.default.fileExists(atPath: applicationURL.path)
            ? applicationURL
            : nil
    }

    func installation() async -> WeChatInstallation? {
        guard let applicationURL = applicationURL() else { return nil }

        let metadata = await Task.detached(priority: .userInitiated) {
            guard let bundle = Bundle(url: applicationURL),
                  bundle.bundleIdentifier == AppConstants.weChatBundleIdentifier else {
                return nil as (version: String, build: String, teamIdentifier: String?)?
            }
            let version = bundle.object(
                forInfoDictionaryKey: "CFBundleShortVersionString"
            ) as? String ?? "未知"
            let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "未知"
            return (
                version: version,
                build: build,
                teamIdentifier: CodeSignatureInspector().teamIdentifier(for: applicationURL)
            )
        }.value
        guard let metadata else { return nil }

        return WeChatInstallation(
            applicationURL: applicationURL,
            version: metadata.version,
            build: metadata.build,
            teamIdentifier: metadata.teamIdentifier
        )
    }

    func runningInstanceCount() -> Int {
        managedRunningApplications().count
    }

    func launchOfficial() async throws {
        guard let installation = await installation() else {
            throw AppError(message: "没有找到微信。请先将微信安装到“应用程序”文件夹。")
        }

        try await launch(applicationURL: installation.applicationURL)
    }

    func launch(applicationURL: URL) async throws {
        guard FileManager.default.fileExists(atPath: applicationURL.path) else {
            throw AppError(message: "要启动的微信应用不存在。")
        }

        guard workspace.open(applicationURL) else {
            throw AppError(message: "微信启动失败，请稍后重试。")
        }
    }

    func isRunning(bundleIdentifier: String) -> Bool {
        workspace.runningApplications.contains { application in
            application.bundleIdentifier == bundleIdentifier
        }
    }

    func terminateAll() {
        managedRunningApplications().forEach { $0.terminate() }
    }

    private func managedRunningApplications() -> [NSRunningApplication] {
        workspace.runningApplications.filter { application in
            guard let bundleIdentifier = application.bundleIdentifier else { return false }
            return bundleIdentifier == AppConstants.weChatBundleIdentifier
                || bundleIdentifier.hasPrefix(WeChatCloneService.bundleIdentifierPrefix)
        }
    }
}
