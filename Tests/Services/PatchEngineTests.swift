import MachO
import XCTest
@testable import WeChatManager

final class PatchEngineTests: XCTestCase {
    func testPatchesArm64ThinMachOAtVirtualAddress() throws {
        let binaryURL = FileManager.default.temporaryDirectory.appending(
            path: "PatchEngineTests-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: binaryURL) }
        try makeThinMachO().write(to: binaryURL)
        let replacement = Data([0x20, 0x00, 0x80, 0x52, 0xC0, 0x03, 0x5F, 0xD6])
        let entry = PatchEntry(
            arch: .arm64,
            address: 0x1010,
            replacement: replacement
        )

        let count = try PatchEngine().patch(binaryURL: binaryURL, entries: [entry])
        let patched = try Data(contentsOf: binaryURL)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(patched.subdata(in: 0x110..<(0x110 + replacement.count)), replacement)
    }

    func testRejectsAddressOutsideSegments() throws {
        let binaryURL = FileManager.default.temporaryDirectory.appending(
            path: "PatchEngineBoundsTests-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: binaryURL) }
        try makeThinMachO().write(to: binaryURL)
        let entry = PatchEntry(
            arch: .arm64,
            address: 0x5000,
            replacement: Data([0x00])
        )

        XCTAssertThrowsError(try PatchEngine().patch(binaryURL: binaryURL, entries: [entry]))
    }

    private func makeThinMachO() -> Data {
        var data = Data()
        data.appendLittleEndian(UInt32(MH_MAGIC_64))
        data.appendLittleEndian(UInt32(CPU_TYPE_ARM64))
        data.appendLittleEndian(UInt32(0))
        data.appendLittleEndian(UInt32(MH_EXECUTE))
        data.appendLittleEndian(UInt32(1))
        data.appendLittleEndian(UInt32(72))
        data.appendLittleEndian(UInt32(0))
        data.appendLittleEndian(UInt32(0))

        data.appendLittleEndian(UInt32(LC_SEGMENT_64))
        data.appendLittleEndian(UInt32(72))
        data.append(Data(repeating: 0, count: 16))
        data.appendLittleEndian(UInt64(0x1000))
        data.appendLittleEndian(UInt64(0x100))
        data.appendLittleEndian(UInt64(0x100))
        data.appendLittleEndian(UInt64(0x100))
        data.appendLittleEndian(UInt32(7))
        data.appendLittleEndian(UInt32(5))
        data.appendLittleEndian(UInt32(0))
        data.appendLittleEndian(UInt32(0))

        data.append(Data(repeating: 0xAA, count: 0x200 - data.count))
        return data
    }
}

private extension Data {
    mutating func appendLittleEndian<T: FixedWidthInteger>(_ value: T) {
        var littleEndianValue = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndianValue) { append(contentsOf: $0) }
    }
}
