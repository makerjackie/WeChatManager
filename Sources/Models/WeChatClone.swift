import Foundation

struct WeChatClone: Identifiable, Sendable, Equatable {
    let index: Int
    let displayName: String
    let bundleIdentifier: String
    let applicationURL: URL
    let sourceVersion: String
    let sourceBuild: String

    var id: String { bundleIdentifier }
    var isInstalledInApplicationsFolder: Bool {
        applicationURL.deletingLastPathComponent().standardizedFileURL.path == "/Applications"
    }
}
