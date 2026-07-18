import Foundation

struct StorageAccountGroup: Identifiable, Sendable, Equatable {
    let id: String
    let displayName: String
    let defaultName: String
    let locations: [StorageLocation]

    var primaryLocations: [StorageLocation] {
        locations.filter { $0.category != .account }
    }

    var additionalLocations: [StorageLocation] {
        locations.filter { $0.category == .account }
    }

    static func defaultName(for ordinal: Int) -> String {
        let numerals = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
        guard numerals.indices.contains(ordinal - 1) else {
            return "微信号\(ordinal)"
        }
        return "微信号\(numerals[ordinal - 1])"
    }
}
