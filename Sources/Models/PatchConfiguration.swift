import Foundation

struct PatchConfiguration: Decodable, Sendable {
    let version: String
    let targets: [PatchTarget]

    func enhancementOptions(for architecture: PatchArchitecture) -> Set<EnhancementOption> {
        let identifiers = Set(
            targets
                .filter { target in target.entries.contains { $0.arch == architecture } }
                .map(\.identifier)
        )
        return Set(EnhancementOption.allCases.filter { identifiers.contains($0.rawValue) })
    }
}
