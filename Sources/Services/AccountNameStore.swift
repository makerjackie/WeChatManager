import CryptoKit
import Foundation

@MainActor
struct AccountNameStore {
    private static let storageKey = "storageAccountDisplayNames"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func names(for identifiers: [String]) -> [String: String] {
        let storedNames = defaults.dictionary(forKey: Self.storageKey) as? [String: String] ?? [:]
        return identifiers.reduce(into: [:]) { result, identifier in
            if let name = storedNames[storageKey(for: identifier)] {
                result[identifier] = name
            }
        }
    }

    func setName(_ name: String?, for identifier: String) {
        var storedNames = defaults.dictionary(forKey: Self.storageKey) as? [String: String] ?? [:]
        let key = storageKey(for: identifier)
        if let name {
            storedNames[key] = name
        } else {
            storedNames.removeValue(forKey: key)
        }
        defaults.set(storedNames, forKey: Self.storageKey)
    }

    private func storageKey(for identifier: String) -> String {
        SHA256.hash(data: Data(identifier.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
