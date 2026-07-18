import Foundation

struct PatchConfiguration: Decodable, Sendable {
    let version: String
    let targets: [PatchTarget]
}
