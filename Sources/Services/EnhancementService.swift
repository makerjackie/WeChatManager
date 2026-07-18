import Foundation

actor EnhancementService {
    private let configurationService: UpstreamConfigurationService
    private let privilegedRunner: PrivilegedCommandRunner
    private let commandRunner: CommandRunner
    private let backupRoot: URL
    private let fileManager: FileManager

    init(
        configurationService: UpstreamConfigurationService = UpstreamConfigurationService(),
        privilegedRunner: PrivilegedCommandRunner = PrivilegedCommandRunner(),
        commandRunner: CommandRunner = CommandRunner(),
        backupRoot: URL = URL.applicationSupportDirectory.appending(
            path: "WeChatManager/Backups"
        ),
        fileManager: FileManager = .default
    ) {
        self.configurationService = configurationService
        self.privilegedRunner = privilegedRunner
        self.commandRunner = commandRunner
        self.backupRoot = backupRoot
        self.fileManager = fileManager
    }

    func compatibility(build: String) async -> EnhancementCompatibility {
        do {
            let configurations = try await configurationService.configurations()
            let supportedBuilds = configurations
                .filter { !$0.enhancementOptions(for: .current).isEmpty }
                .map(\.version)
                .sorted { (Int($0) ?? 0) < (Int($1) ?? 0) }
            guard let configuration = configurations.first(where: { $0.version == build }) else {
                return .unavailable(
                    reason: "当前微信暂不支持功能增强。",
                    supportedBuilds: supportedBuilds
                )
            }
            let options = configuration.enhancementOptions(for: .current)
            guard !options.isEmpty else {
                return .unavailable(
                    reason: "当前微信版本不支持这台 Mac 的处理器。",
                    supportedBuilds: supportedBuilds
                )
            }
            return .compatible(options: options, supportedBuilds: supportedBuilds)
        } catch {
            return .unavailable(reason: error.localizedDescription, supportedBuilds: [])
        }
    }

    func hasBackup(for build: String) -> Bool {
        fileManager.fileExists(atPath: backupURL(for: build).path)
    }

    func install(
        installation: WeChatInstallation,
        options: Set<EnhancementOption>
    ) async throws {
        guard !options.isEmpty else {
            throw AppError(message: "请至少选择一个增强功能。")
        }

        let configurations = try await configurationService.configurations()
        guard let configuration = configurations.first(where: { $0.version == installation.build }) else {
            throw AppError(message: "当前微信版本不在兼容列表中，未做任何修改。")
        }

        let selectedTargets = configuration.targets.filter { target in
            options.contains { $0.rawValue == target.identifier }
        }
        guard selectedTargets.count == options.count else {
            throw AppError(message: "上游配置缺少所选增强项，未做任何修改。")
        }

        let backupURL = backupURL(for: installation.build)
        if !fileManager.fileExists(atPath: backupURL.path) {
            guard installation.isOfficiallySigned else {
                throw AppError(message: "当前微信不是腾讯原始签名，且没有可用备份。请先重新安装官方微信。")
            }
            try fileManager.createDirectory(at: backupRoot, withIntermediateDirectories: true)
            try fileManager.copyItem(at: installation.applicationURL, to: backupURL)
        }

        let temporaryRoot = fileManager.temporaryDirectory.appending(
            path: "WeChatManager-\(UUID().uuidString)"
        )
        try fileManager.createDirectory(at: temporaryRoot, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: temporaryRoot) }

        let sourceBinary = installation.applicationURL.appending(path: "Contents/MacOS/WeChat")
        let patchedBinary = temporaryRoot.appending(path: "WeChat")
        try fileManager.copyItem(at: sourceBinary, to: patchedBinary)
        let entries = selectedTargets.flatMap(\.entries)
        _ = try PatchEngine().patch(binaryURL: patchedBinary, entries: entries)

        let appPath = ShellEscaping.quote(installation.applicationURL.path)
        let binaryPath = ShellEscaping.quote(sourceBinary.path)
        let patchedPath = ShellEscaping.quote(patchedBinary.path)
        let command = [
            "/usr/bin/install -m 755 \(patchedPath) \(binaryPath)",
            "/usr/bin/codesign --remove-signature \(appPath) >/dev/null 2>&1 || true",
            "/usr/bin/codesign --force --deep --sign - \(appPath)",
            "/usr/bin/xattr -cr \(appPath)"
        ].joined(separator: "; ")
        try await privilegedRunner.run(shellCommand: command)

        let verification = try await commandRunner.run(
            executableURL: URL(fileURLWithPath: "/usr/bin/codesign"),
            arguments: ["--verify", "--deep", "--strict", installation.applicationURL.path]
        )
        guard verification.terminationStatus == 0 else {
            try? await restore(installation: installation)
            throw AppError(message: "增强后的微信签名校验失败，已尝试恢复备份。")
        }
    }

    func restore(installation: WeChatInstallation) async throws {
        let backupURL = backupURL(for: installation.build)
        guard fileManager.fileExists(atPath: backupURL.path),
              Bundle(url: backupURL)?.bundleIdentifier == AppConstants.weChatBundleIdentifier,
              CodeSignatureInspector().teamIdentifier(for: backupURL)
                == AppConstants.officialWeChatTeamIdentifier else {
            throw AppError(message: "没有找到通过腾讯签名校验的当前版本备份。")
        }

        let destination = ShellEscaping.quote(installation.applicationURL.path)
        let source = ShellEscaping.quote(backupURL.path)
        let command = [
            "/bin/rm -rf \(destination)",
            "/usr/bin/ditto --rsrc --extattr --acl \(source) \(destination)"
        ].joined(separator: "; ")
        try await privilegedRunner.run(shellCommand: command)

        let verification = try await commandRunner.run(
            executableURL: URL(fileURLWithPath: "/usr/bin/codesign"),
            arguments: ["--verify", "--deep", "--strict", installation.applicationURL.path]
        )
        guard verification.terminationStatus == 0 else {
            throw AppError(message: "备份已复制，但微信签名校验没有通过。请重新安装官方微信。")
        }
    }

    private func backupURL(for build: String) -> URL {
        backupRoot.appending(path: "WeChat-\(build).app")
    }
}
