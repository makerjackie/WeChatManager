import Foundation

struct WeChatDataLocator {
    private let homeDirectory: URL
    private let fileManager: FileManager

    init(
        homeDirectory: URL = .homeDirectory,
        fileManager: FileManager = .default
    ) {
        self.homeDirectory = homeDirectory
        self.fileManager = fileManager
    }

    func locations() -> [StorageLocation] {
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

        accountDirectories(in: modernRoot).forEach { accountURL in
            let accountName = accountURL.lastPathComponent
            appendIfPresent(
                StorageLocation(
                    title: accountName,
                    detail: "账号数据目录",
                    url: accountURL,
                    category: .account,
                    allocatedSize: nil
                ),
                to: &locations
            )
            appendIfPresent(
                StorageLocation(
                    title: "收到的文件 · \(accountName)",
                    detail: "聊天中接收的文档与压缩包",
                    url: accountURL.appending(path: "msg/file"),
                    category: .files,
                    allocatedSize: nil
                ),
                to: &locations
            )
            appendIfPresent(
                StorageLocation(
                    title: "聊天视频 · \(accountName)",
                    detail: "聊天中接收和发送的视频",
                    url: accountURL.appending(path: "msg/video"),
                    category: .videos,
                    allocatedSize: nil
                ),
                to: &locations
            )
            appendIfPresent(
                StorageLocation(
                    title: "账号缓存 · \(accountName)",
                    detail: "可安全移入废纸篓的临时缓存",
                    url: accountURL.appending(path: "cache"),
                    category: .cache,
                    allocatedSize: nil
                ),
                to: &locations
            )
        }

        cacheCandidates(containerRoot: containerRoot).forEach { url in
            appendIfPresent(
                StorageLocation(
                    title: "微信缓存 · \(url.lastPathComponent)",
                    detail: "应用运行产生的临时数据",
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

    func allowedCacheRoots() -> [URL] {
        locations().filter(\.isCache).map(\.url)
    }

    private func accountDirectories(in root: URL) -> [URL] {
        guard let children = try? fileManager.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return children.filter { url in
            let values = try? url.resourceValues(forKeys: [.isDirectoryKey])
            guard values?.isDirectory == true else { return false }
            return fileManager.fileExists(atPath: url.appending(path: "msg").path)
                || fileManager.fileExists(atPath: url.appending(path: "db_storage").path)
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
