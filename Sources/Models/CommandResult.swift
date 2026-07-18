import Foundation

struct CommandResult: Sendable, Equatable {
    let standardOutput: String
    let standardError: String
    let terminationStatus: Int32
}
