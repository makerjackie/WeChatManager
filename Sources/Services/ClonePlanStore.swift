import Foundation

@MainActor
final class ClonePlanStore: NSObject {
    private static let documentKey = "clonePlanDocument.v1"

    private let localBackend: ClonePlanStoreBackend
    private let cloudBackend: ClonePlanStoreBackend?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    var onExternalChange: (() -> Void)?

    init(
        localBackend: ClonePlanStoreBackend = .userDefaults(),
        cloudBackend: ClonePlanStoreBackend? = ClonePlanStoreBackend.iCloudIfEntitled()
    ) {
        self.localBackend = localBackend
        self.cloudBackend = cloudBackend
        super.init()
        if cloudBackend != nil {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(cloudStoreDidChange),
                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: nil
            )
        }
    }

    func load() -> (plans: [ClonePlan], cloudAvailable: Bool) {
        let localDocument = decode(localBackend.data(Self.documentKey))
        let cloudAvailable = cloudBackend?.synchronize() ?? false
        let cloudDocument = cloudAvailable
            ? decode(cloudBackend?.data(Self.documentKey))
            : nil
        let document = ClonePlanDocument.preferred(
            local: localDocument,
            cloud: cloudDocument
        )

        if let document, document == cloudDocument, document != localDocument {
            write(document, to: localBackend)
        } else if let document,
                  cloudAvailable,
                  document == localDocument,
                  document != cloudDocument,
                  let cloudBackend {
            write(document, to: cloudBackend)
            _ = cloudBackend.synchronize()
        }

        return (
            plans: document?.plans.sorted { $0.modifiedAt > $1.modifiedAt } ?? [],
            cloudAvailable: cloudAvailable
        )
    }

    @discardableResult
    func save(_ plans: [ClonePlan]) -> Bool {
        let document = ClonePlanDocument(plans: plans)
        write(document, to: localBackend)

        guard let cloudBackend else { return false }
        write(document, to: cloudBackend)
        return cloudBackend.synchronize()
    }

    private func decode(_ data: Data?) -> ClonePlanDocument? {
        guard let data,
              let document = try? decoder.decode(ClonePlanDocument.self, from: data),
              document.schemaVersion == ClonePlanDocument.currentSchemaVersion else {
            return nil
        }
        return document
    }

    private func write(_ document: ClonePlanDocument, to backend: ClonePlanStoreBackend) {
        guard let data = try? encoder.encode(document) else { return }
        backend.setData(data, Self.documentKey)
    }

    @objc
    private func cloudStoreDidChange(_ notification: Notification) {
        _ = notification
        onExternalChange?()
    }
}
