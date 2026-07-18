import Foundation

extension Data {
    init?(hexadecimal: String) {
        let characters = Array(hexadecimal.utf8)
        guard characters.count.isMultiple(of: 2) else { return nil }

        self.init()
        reserveCapacity(characters.count / 2)

        for index in stride(from: 0, to: characters.count, by: 2) {
            guard let high = Self.hexadecimalNibble(characters[index]),
                  let low = Self.hexadecimalNibble(characters[index + 1]) else {
                return nil
            }
            append(high << 4 | low)
        }
    }

    private static func hexadecimalNibble(_ character: UInt8) -> UInt8? {
        switch character {
        case 48...57: character - 48
        case 65...70: character - 55
        case 97...102: character - 87
        default: nil
        }
    }
}
