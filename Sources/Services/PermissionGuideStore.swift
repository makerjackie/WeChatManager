import Foundation

@MainActor
struct PermissionGuideStore {
    private static let completedVersionKey = "permissionGuideCompletedVersion"
    private static let currentVersion = 1
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var shouldPresentGuide: Bool {
        defaults.integer(forKey: Self.completedVersionKey) < Self.currentVersion
    }

    func markCompleted() {
        defaults.set(Self.currentVersion, forKey: Self.completedVersionKey)
    }
}
