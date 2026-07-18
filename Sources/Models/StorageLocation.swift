import Foundation

struct StorageLocation: Identifiable, Sendable, Equatable {
    let title: String
    let detail: String
    let url: URL
    let category: StorageCategory
    var allocatedSize: Int64?

    var id: String { url.standardizedFileURL.path }
    var isCache: Bool { category == .cache }

    func withAllocatedSize(_ size: Int64) -> Self {
        var copy = self
        copy.allocatedSize = size
        return copy
    }
}
