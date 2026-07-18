import Foundation

actor WeChatDataLocator {
    private let homeDirectory: URL
    private let fileManager: FileManager
    private let commandRunner: CommandRunner

    init(
        homeDirectory: URL = .homeDirectory,
        fileManager: FileManager = .default,
        commandRunner: CommandRunner = CommandRunner()
    ) {
        self.homeDirectory = homeDirectory
        self.fileManager = fileManager
        self.commandRunner = commandRunner
    }

    func locations() async -> [StorageLocation] {
        var locations: [StorageLocation] = []
        let containerRoot = homeDirectory.appending(
            path: "Library/Containers/com.tencent.xinWeChat/Data"
        )
        let modernRoot = containerRoot.appending(path: "Documents/xwechat_files")

        appendIfPresent(
            StorageLocation(
                title: "微信数据总目录",
                detail: "微信 4.x 的账号、聊天文件与数据库入口",
                url: modernRoot,
                category: .root,
                allocatedSize: nil
            ),
            to: &locations
        )

        let accountURLs = await accountDirectories(in: modernRoot)
        accountURLs.forEach { accountURL in
            let accountIdentifier = accountURL.lastPathComponent
            appendIfPresent(
                StorageLocation(
                    title: "账号数据",
                    detail: "数据库、索引与账号配置",
                    url: accountURL,
                    category: .account,
                    accountIdentifier: accountIdentifier,
                    allocatedSize: nil
                ),
                to: &locations
            )
            appendIfPresent(
                StorageLocation(
                    title: "收到的文件",
                    detail: "聊天中接收的文档、表格与压缩包",
                    url: accountURL.appending(path: "msg/file"),
                    category: .files,
                    accountIdentifier: accountIdentifier,
                    allocatedSize: nil
                ),
                to: &locations
            )
            appendIfPresent(
                StorageLocation(
                    title: "聊天视频",
                    detail: "聊天中接收和发送的视频文件",
                    url: accountURL.appending(path: "msg/video"),
                    category: .videos,
                    accountIdentifier: accountIdentifier,
                    allocatedSize: nil
                ),
                to: &locations
            )
            appendIfPresent(
                StorageLocation(
                    title: "临时缓存",
                    detail: "可移入废纸篓的临时数据",
                    url: accountURL.appending(path: "cache"),
                    category: .cache,
                    accountIdentifier: accountIdentifier,
                    allocatedSize: nil
                ),
                to: &locations
            )
        }

        cacheCandidates(containerRoot: containerRoot).forEach { url in
            appendIfPresent(
                StorageLocation(
                    title: "共享缓存",
                    detail: "微信运行时产生的公共临时数据",
                    url: url,
                    category: .cache,
                    allocatedSize: nil
                ),
                to: &locations
            )
        }

        let legacyRoot = containerRoot.appending(
            path: "Library/Application Support/com.tencent.xinWeChat"
        )
        appendIfPresent(
            StorageLocation(
                title: "旧版微信数据",
                detail: "微信 3.x 及更早版本的数据入口",
                url: legacyRoot,
                category: .legacy,
                allocatedSize: nil
            ),
            to: &locations
        )

        return deduplicated(locations)
    }

    func allowedCacheRoots() async -> [URL] {
        await locations().filter(\.isCache).map(\.url)
    }

    private func accountDirectories(in root: URL) async -> [URL] {
        guard let result = try? await commandRunner.run(
            executableURL: URL(fileURLWithPath: "/bin/ls"),
            arguments: ["-1A", root.path],
            timeout: 3
        ), result.terminationStatus == 0 else {
            return []
        }

        let names = result.standardOutput.split(whereSeparator: \.isNewline).map(String.init)
        return names.compactMap { name -> URL? in
            guard !name.hasPrefix(".") else { return nil }
            let url = root.appending(path: name, directoryHint: .isDirectory)
            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory),
                  isDirectory.boolValue else {
                return nil
            }
            return fileManager.fileExists(atPath: url.appending(path: "msg").path)
                || fileManager.fileExists(atPath: url.appending(path: "db_storage").path)
                ? url
                : nil
        }
        .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
    }

    private func cacheCandidates(containerRoot: URL) -> [URL] {
        [
            containerRoot.appending(path: "Library/Caches"),
            containerRoot.appending(path: "Documents/Caches"),
            containerRoot.appending(path: "Documents/cacheDir")
        ]
    }

    private func appendIfPresent(
        _ location: StorageLocation,
        to locations: inout [StorageLocation]
    ) {
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: location.url.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            return
        }
        locations.append(location)
    }

    private func deduplicated(_ locations: [StorageLocation]) -> [StorageLocation] {
        var seenPaths = Set<String>()
        return locations.filter { location in
            seenPaths.insert(location.id).inserted
        }
    }
}
