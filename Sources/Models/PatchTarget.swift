import Foundation

struct PatchTarget: Decodable, Sendable {
    let identifier: String
    let entries: [PatchEntry]
}
