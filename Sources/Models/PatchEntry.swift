import Foundation

struct PatchEntry: Decodable, Sendable {
    let arch: PatchArchitecture
    let address: UInt64
    let replacement: Data

    private enum CodingKeys: String, CodingKey {
        case arch
        case address = "addr"
        case replacement = "asm"
    }

    init(arch: PatchArchitecture, address: UInt64, replacement: Data) {
        self.arch = arch
        self.address = address
        self.replacement = replacement
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        arch = try container.decode(PatchArchitecture.self, forKey: .arch)

        let addressText = try container.decode(String.self, forKey: .address)
        guard let decodedAddress = UInt64(addressText, radix: 16) else {
            throw DecodingError.dataCorruptedError(
                forKey: .address,
                in: container,
                debugDescription: "补丁地址不是有效的十六进制数"
            )
        }
        address = decodedAddress

        let replacementText = try container.decode(String.self, forKey: .replacement)
        guard let decodedReplacement = Data(hexadecimal: replacementText) else {
            throw DecodingError.dataCorruptedError(
                forKey: .replacement,
                in: container,
                debugDescription: "补丁指令不是有效的十六进制数据"
            )
        }
        replacement = decodedReplacement
    }
}
