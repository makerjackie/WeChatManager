import Foundation

struct UserMessage: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
}
