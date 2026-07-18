import Foundation

actor CacheCleaner {
    private let allowedRoots: Set<String>
    private let trashDirectory: URL
    private let fileManager: FileManager

    init(
        allowedRoots: [URL],
        trashDirectory: URL? = nil,
        fileManager: FileManager = .default
    ) throws {
        self.allowedRoots = Set(allowedRoots.map { $0.standardizedFileURL.path })
        self.fileManager = fileManager
        if let trashDirectory {
            self.trashDirectory = trashDirectory
        } else if let systemTrash = fileManager.urls(
            for: .trashDirectory,
            in: .userDomainMask
        ).first {
            self.trashDirectory = systemTrash
        } else {
            throw AppError(message: "找不到废纸篓，缓存没有被移动。")
        }
    }

    func clean(urls: [URL]) throws -> CleanupResult {
        let validated = try validatedTargets(urls)
        let destination = trashDirectory.appending(
            path: "微信多开助手-缓存-\(Date.ISO8601FormatStyle().format(.now))"
                .replacing(":", with: "-")
        )
        try fileManager.createDirectory(at: destination, withIntermediateDirectories: true)

        var movedItemCount = 0
        for (index, source) in validated.enumerated() {
            guard fileManager.fileExists(atPath: source.path) else { continue }
            let targetName = "\(index + 1)-\(source.lastPathComponent)"
            try fileManager.moveItem(at: source, to: destination.appending(path: targetName))
            try fileManager.createDirectory(at: source, withIntermediateDirectories: true)
            movedItemCount += 1
        }

        return CleanupResult(movedItemCount: movedItemCount, destination: destination)
    }

    private func validatedTargets(_ urls: [URL]) throws -> [URL] {
        let unique = Set(urls.map { $0.standardizedFileURL.path })
        guard unique.isSubset(of: allowedRoots) else {
            throw AppError(message: "检测到不在安全清理范围内的路径，操作已取消。")
        }

        return unique
            .sorted { $0.count < $1.count }
            .reduce(into: [URL]()) { result, path in
                guard !result.contains(where: { path.hasPrefix($0.path + "/") }) else { return }
                result.append(URL(fileURLWithPath: path, isDirectory: true))
            }
    }
}
