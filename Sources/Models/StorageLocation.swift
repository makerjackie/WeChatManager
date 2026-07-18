import Foundation

struct StorageLocation: Identifiable, Sendable, Equatable {
    let title: String
    let detail: String
    let url: URL
    let category: StorageCategory
    let accountIdentifier: String?
    var allocatedSize: Int64?

    var id: String { url.standardizedFileURL.path }
    var isCache: Bool { category == .cache }

    init(
        title: String,
        detail: String,
        url: URL,
        category: StorageCategory,
        accountIdentifier: String? = nil,
        allocatedSize: Int64?
    ) {
        self.title = title
        self.detail = detail
        self.url = url
        self.category = category
        self.accountIdentifier = accountIdentifier
        self.allocatedSize = allocatedSize
    }

    func withAllocatedSize(_ size: Int64) -> Self {
        var copy = self
        copy.allocatedSize = size
        return copy
    }
}
