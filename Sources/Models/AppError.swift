import Foundation

struct AppError: LocalizedError, Sendable {
    let message: String

    var errorDescription: String? { message }
}
