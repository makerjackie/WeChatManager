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

    static var current: Self {
        #if arch(arm64)
        .arm64
        #elseif arch(x86_64)
        .x86_64
        #else
        fatalError("不支持当前处理器架构")
        #endif
    }
}
