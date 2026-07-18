import Foundation
import Security

@MainActor
struct ClonePlanStoreBackend {
    let data: (String) -> Data?
    let setData: (Data, String) -> Void
    let synchronize: () -> Bool

    static func userDefaults(_ defaults: UserDefaults = .standard) -> Self {
        Self(
            data: defaults.data(forKey:),
            setData: { data, key in defaults.set(data, forKey: key) },
            synchronize: { true }
        )
    }

    static func iCloud(_ store: NSUbiquitousKeyValueStore = .default) -> Self {
        Self(
            data: store.data(forKey:),
            setData: { data, key in store.set(data, forKey: key) },
            synchronize: store.synchronize
        )
    }

    static func iCloudIfEntitled() -> Self? {
        guard let task = SecTaskCreateFromSelf(nil),
              let identifier = SecTaskCopyValueForEntitlement(
                task,
                "com.apple.developer.ubiquity-kvstore-identifier" as CFString,
                nil
              ) as? String,
              !identifier.isEmpty else {
            return nil
        }
        return .iCloud()
    }
}
