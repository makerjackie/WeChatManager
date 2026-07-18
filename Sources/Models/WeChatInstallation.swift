import Foundation

struct WeChatInstallation: Sendable, Equatable {
    let applicationURL: URL
    let version: String
    let build: String
    let teamIdentifier: String?

    var isOfficiallySigned: Bool {
        teamIdentifier == "5A4RE8SF68"
    }
}
