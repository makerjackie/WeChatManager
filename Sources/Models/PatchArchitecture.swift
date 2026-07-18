import Darwin
import Foundation

enum PatchArchitecture: String, Decodable, Sendable {
    case arm64
    case x86_64

    var cpuType: UInt32 {
        switch self {
        case .arm64: UInt32(CPU_TYPE_ARM64)
        case .x86_64: UInt32(CPU_TYPE_X86_64)
        }
    }
}
