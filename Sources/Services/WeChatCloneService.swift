import Foundation

actor WeChatCloneService {
    static let bundleIdentifierPrefix = "com.makerjackie.WeChatManager.clone."

    private let homeDirectory: URL
    private let fileManager: FileManager
    private let commandRunner: CommandRunner
    private let plistEditor = WeChatClonePlistEditor()

    init(
        homeDirectory: URL = .homeDirectory,
        fileManager: FileManager = .default,
        commandRunner: CommandRunner = CommandRunner()
    ) {
        self.homeDirectory = homeDirectory
        self.fileManager = fileManager
        self.commandRunner = commandRunner
    }

    func clones() -> [WeChatClone] {
        candidateApplicationDirectories()
            .flatMap(applications(in:))
            .compactMap(clone(at:))
            .sorted { $0.index < $1.index }
    }

    func createNext(from installation: WeChatInstallation) async throws -> WeChatClone {
        let usedIndices = Set(clones().map(\.index))
        let index = (1...).first { !usedIndices.contains($0) } ?? 1
        return try await create(index: index, from: installation, replacingExisting: false)
    }

    func update(_ clone: WeChatClone, from installation: WeChatInstallation) async throws -> WeChatClone {
        try validateManagedClone(clone)
        return try await create(index: clone.index, from: installation, replacingExisting: true)
    }

    func moveToTrash(_ clone: WeChatClone) throws -> URL {
        try validateManagedClone(clone)
        guard fileManager.fileExists(atPath: clone.applicationURL.path) else {
            throw AppError(message: "微信分身已经不存在。")
        }
        let trashRoot = try resolvedTrashDirectory()
        let destination = uniqueDestination(
            in: trashRoot,
            name: clone.applicationURL.lastPathComponent
        )
        try fileManager.moveItem(at: clone.applicationURL, to: destination)
        return destination
    }

    private func create(
        index: Int,
        from installation: WeChatInstallation,
        replacingExisting: Bool
    ) async throws -> WeChatClone {
        guard index > 0, installation.isOfficiallySigned else {
            throw AppError(message: "只能从腾讯官方签名的微信创建分身。")
        }

        let applicationsDirectory = homeDirectory.appending(path: "Applications")
        try fileManager.createDirectory(at: applicationsDirectory, withIntermediateDirectories: true)
        let destination = applicationsDirectory.appending(path: "微信分身 \(index).app")
        let temporary = applicationsDirectory.appending(
            path: ".微信分身-\(index)-\(UUID().uuidString).app"
        )
        defer { try? fileManager.removeItem(at: temporary) }

        if fileManager.fileExists(atPath: destination.path), !replacingExisting {
            throw AppError(message: "微信分身 \(index) 已存在。")
        }

        try fileManager.copyItem(at: installation.applicationURL, to: temporary)
        try rewriteInfoPlist(
            in: temporary,
            index: index,
            version: installation.version,
            build: installation.build
        )
        try await sign(applicationURL: temporary)

        guard let preparedClone = clone(at: temporary) else {
            throw AppError(message: "微信分身创建后未通过元数据校验。")
        }

        var previousDestination: URL?
        if fileManager.fileExists(atPath: destination.path) {
            let trashRoot = try resolvedTrashDirectory()
            let previous = uniqueDestination(in: trashRoot, name: destination.lastPathComponent)
            try fileManager.moveItem(at: destination, to: previous)
            previousDestination = previous
        }

        do {
            try fileManager.moveItem(at: temporary, to: destination)
        } catch {
            if let previousDestination,
               !fileManager.fileExists(atPath: destination.path) {
                try? fileManager.moveItem(at: previousDestination, to: destination)
            }
            throw error
        }

        return WeChatClone(
            index: preparedClone.index,
            displayName: preparedClone.displayName,
            bundleIdentifier: preparedClone.bundleIdentifier,
            applicationURL: destination,
            sourceVersion: preparedClone.sourceVersion,
            sourceBuild: preparedClone.sourceBuild
        )
    }

    private func rewriteInfoPlist(
        in applicationURL: URL,
        index: Int,
        version: String,
        build: String
    ) throws {
        let plistURL = applicationURL.appending(path: "Contents/Info.plist")
        let data = try Data(contentsOf: plistURL)
        var format = PropertyListSerialization.PropertyListFormat.binary
        guard let plist = try PropertyListSerialization.propertyList(
            from: data,
            options: [.mutableContainersAndLeaves],
            format: &format
        ) as? [String: Any] else {
            throw AppError(message: "无法读取微信 Info.plist。")
        }
        let edited = plistEditor.editedPlist(
            plist,
            index: index,
            version: version,
            build: build
        )
        let editedData = try PropertyListSerialization.data(
            fromPropertyList: edited,
            format: format,
            options: 0
        )
        try editedData.write(to: plistURL, options: .atomic)
    }

    private func sign(applicationURL: URL) async throws {
        _ = try? await commandRunner.run(
            executableURL: URL(fileURLWithPath: "/usr/bin/codesign"),
            arguments: ["--remove-signature", applicationURL.path]
        )
        let signing = try await commandRunner.run(
            executableURL: URL(fileURLWithPath: "/usr/bin/codesign"),
            arguments: ["--force", "--deep", "--sign", "-", applicationURL.path]
        )
        guard signing.terminationStatus == 0 else {
            throw AppError(message: "微信分身签名失败：\(signing.standardError)")
        }
        _ = try? await commandRunner.run(
            executableURL: URL(fileURLWithPath: "/usr/bin/xattr"),
            arguments: ["-cr", applicationURL.path]
        )
        let verification = try await commandRunner.run(
            executableURL: URL(fileURLWithPath: "/usr/bin/codesign"),
            arguments: ["--verify", "--deep", "--strict", applicationURL.path]
        )
        guard verification.terminationStatus == 0 else {
            throw AppError(message: "微信分身签名校验失败：\(verification.standardError)")
        }
    }

    private func candidateApplicationDirectories() -> [URL] {
        [
            homeDirectory.appending(path: "Applications"),
            URL(fileURLWithPath: "/Applications", isDirectory: true)
        ]
    }

    private func applications(in directory: URL) -> [URL] {
        guard let contents = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isApplicationKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        return contents.filter { $0.pathExtension == "app" }
    }

    private func clone(at applicationURL: URL) -> WeChatClone? {
        let plistURL = applicationURL.appending(path: "Contents/Info.plist")
        guard let data = try? Data(contentsOf: plistURL),
              let plist = try? PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil
              ) as? [String: Any],
              plist["WeChatManagerClone"] as? Bool == true,
              let index = plist["WeChatManagerCloneIndex"] as? Int,
              let bundleIdentifier = plist["CFBundleIdentifier"] as? String,
              bundleIdentifier == plistEditor.bundleIdentifier(for: index),
              let displayName = plist["CFBundleDisplayName"] as? String,
              let sourceVersion = plist["WeChatManagerSourceVersion"] as? String,
              let sourceBuild = plist["WeChatManagerSourceBuild"] as? String else {
            return nil
        }
        return WeChatClone(
            index: index,
            displayName: displayName,
            bundleIdentifier: bundleIdentifier,
            applicationURL: applicationURL,
            sourceVersion: sourceVersion,
            sourceBuild: sourceBuild
        )
    }

    private func validateManagedClone(_ clone: WeChatClone) throws {
        guard clone.bundleIdentifier.hasPrefix(Self.bundleIdentifierPrefix),
              self.clone(at: clone.applicationURL) == clone else {
            throw AppError(message: "目标不是由微信多开助手管理的分身。")
        }
    }

    private func resolvedTrashDirectory() throws -> URL {
        guard let trash = fileManager.urls(for: .trashDirectory, in: .userDomainMask).first else {
            throw AppError(message: "找不到废纸篓。")
        }
        return trash
    }

    private func uniqueDestination(in directory: URL, name: String) -> URL {
        let base = directory.appending(path: name)
        guard fileManager.fileExists(atPath: base.path) else { return base }
        return directory.appending(path: "\(name)-\(UUID().uuidString)")
    }
}
