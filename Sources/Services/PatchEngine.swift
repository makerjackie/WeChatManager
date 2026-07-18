/*
 Patch algorithm adapted from sunnyyoung/WeChatTweak.
 Copyright (c) Sunny Young and contributors.
 SPDX-License-Identifier: AGPL-3.0-only
*/

import Foundation
import MachO

struct PatchEngine {
    func patch(binaryURL: URL, entries: [PatchEntry]) throws -> Int {
        guard !entries.isEmpty else {
            throw AppError(message: "没有可应用的补丁指令。")
        }

        let fileHandle = try FileHandle(forUpdating: binaryURL)
        defer { try? fileHandle.close() }

        let fileSize = try fileHandle.seekToEnd()
        try fileHandle.seek(toOffset: 0)
        let magicData = try read(fileHandle, count: 4)
        let magicBigEndian = unsigned32(magicData, offset: 0, byteOrder: .bigEndian)

        let patchedCount: Int
        switch magicBigEndian {
        case UInt32(FAT_MAGIC):
            patchedCount = try patchFatBinary(
                fileHandle,
                fileSize: fileSize,
                entries: entries,
                is64BitTable: false,
                tableByteOrder: .bigEndian
            )
        case UInt32(FAT_CIGAM):
            patchedCount = try patchFatBinary(
                fileHandle,
                fileSize: fileSize,
                entries: entries,
                is64BitTable: false,
                tableByteOrder: .littleEndian
            )
        case UInt32(FAT_MAGIC_64):
            patchedCount = try patchFatBinary(
                fileHandle,
                fileSize: fileSize,
                entries: entries,
                is64BitTable: true,
                tableByteOrder: .bigEndian
            )
        case UInt32(FAT_CIGAM_64):
            patchedCount = try patchFatBinary(
                fileHandle,
                fileSize: fileSize,
                entries: entries,
                is64BitTable: true,
                tableByteOrder: .littleEndian
            )
        default:
            patchedCount = try patchThinSlice(
                fileHandle,
                fileSize: fileSize,
                sliceOffset: 0,
                entries: entries
            )
        }

        guard patchedCount > 0 else {
            throw AppError(message: "补丁中没有适用于当前处理器架构的指令。")
        }
        try fileHandle.synchronize()
        return patchedCount
    }

    private func patchFatBinary(
        _ fileHandle: FileHandle,
        fileSize: UInt64,
        entries: [PatchEntry],
        is64BitTable: Bool,
        tableByteOrder: ByteOrder
    ) throws -> Int {
        try fileHandle.seek(toOffset: 4)
        let countData = try read(fileHandle, count: 4)
        let architectureCount = unsigned32(countData, offset: 0, byteOrder: tableByteOrder)
        guard architectureCount > 0, architectureCount < 64 else {
            throw AppError(message: "Mach-O 架构表无效。")
        }

        var slices: [(cpuType: UInt32, offset: UInt64)] = []
        for _ in 0..<architectureCount {
            let entrySize = is64BitTable ? 32 : 20
            let architectureData = try read(fileHandle, count: entrySize)
            let cpuType = unsigned32(architectureData, offset: 0, byteOrder: tableByteOrder)
            let offset = if is64BitTable {
                unsigned64(architectureData, offset: 8, byteOrder: tableByteOrder)
            } else {
                UInt64(unsigned32(architectureData, offset: 8, byteOrder: tableByteOrder))
            }
            guard offset < fileSize else {
                throw AppError(message: "Mach-O 架构偏移超出文件范围。")
            }
            slices.append((cpuType, offset))
        }

        var patchedCount = 0
        for slice in slices {
            let matchingEntries = entries.filter { $0.arch.cpuType == slice.cpuType }
            guard !matchingEntries.isEmpty else { continue }
            patchedCount += try patchThinSlice(
                fileHandle,
                fileSize: fileSize,
                sliceOffset: slice.offset,
                entries: matchingEntries
            )
        }
        return patchedCount
    }

    private func patchThinSlice(
        _ fileHandle: FileHandle,
        fileSize: UInt64,
        sliceOffset: UInt64,
        entries: [PatchEntry]
    ) throws -> Int {
        try fileHandle.seek(toOffset: sliceOffset)
        let header = try read(fileHandle, count: 32)
        let magic = unsigned32(header, offset: 0, byteOrder: .littleEndian)
        guard magic == UInt32(MH_MAGIC_64) else {
            throw AppError(message: "只支持 64 位 Mach-O 微信程序。")
        }

        let cpuType = unsigned32(header, offset: 4, byteOrder: .littleEndian)
        let loadCommandCount = unsigned32(header, offset: 16, byteOrder: .littleEndian)
        let matchingEntries = entries.filter { $0.arch.cpuType == cpuType }
        guard !matchingEntries.isEmpty else { return 0 }

        var loadCommandOffset = sliceOffset + 32
        var pendingEntries = matchingEntries
        for _ in 0..<loadCommandCount {
            try fileHandle.seek(toOffset: loadCommandOffset)
            let commandHeader = try read(fileHandle, count: 8)
            let command = unsigned32(commandHeader, offset: 0, byteOrder: .littleEndian)
            let commandSize = unsigned32(commandHeader, offset: 4, byteOrder: .littleEndian)
            guard commandSize >= 8,
                  loadCommandOffset + UInt64(commandSize) <= fileSize else {
                throw AppError(message: "Mach-O 加载命令损坏。")
            }

            if command == UInt32(LC_SEGMENT_64) {
                let segment = try read(fileHandle, count: 64)
                let virtualAddress = unsigned64(segment, offset: 16, byteOrder: .littleEndian)
                let virtualSize = unsigned64(segment, offset: 24, byteOrder: .littleEndian)
                let fileOffset = unsigned64(segment, offset: 32, byteOrder: .littleEndian)

                for entry in pendingEntries where entry.address >= virtualAddress {
                    let patchEnd = entry.address + UInt64(entry.replacement.count)
                    guard patchEnd <= virtualAddress + virtualSize else { continue }
                    let targetOffset = sliceOffset + fileOffset + (entry.address - virtualAddress)
                    guard targetOffset + UInt64(entry.replacement.count) <= fileSize else {
                        throw AppError(message: "补丁地址超出微信程序文件范围。")
                    }
                    try fileHandle.seek(toOffset: targetOffset)
                    try fileHandle.write(contentsOf: entry.replacement)
                    pendingEntries.removeAll { $0.address == entry.address && $0.arch == entry.arch }
                }
            }

            loadCommandOffset += UInt64(commandSize)
        }

        guard pendingEntries.isEmpty else {
            throw AppError(message: "没有在微信程序中找到全部补丁地址。")
        }
        return matchingEntries.count
    }

    private func read(_ fileHandle: FileHandle, count: Int) throws -> Data {
        guard let data = try fileHandle.read(upToCount: count), data.count == count else {
            throw AppError(message: "读取 Mach-O 文件时遇到意外结尾。")
        }
        return data
    }

    private func unsigned32(_ data: Data, offset: Int, byteOrder: ByteOrder) -> UInt32 {
        let value = data.withUnsafeBytes { bytes in
            bytes.loadUnaligned(fromByteOffset: offset, as: UInt32.self)
        }
        return switch byteOrder {
        case .bigEndian: UInt32(bigEndian: value)
        case .littleEndian: UInt32(littleEndian: value)
        }
    }

    private func unsigned64(_ data: Data, offset: Int, byteOrder: ByteOrder) -> UInt64 {
        let value = data.withUnsafeBytes { bytes in
            bytes.loadUnaligned(fromByteOffset: offset, as: UInt64.self)
        }
        return switch byteOrder {
        case .bigEndian: UInt64(bigEndian: value)
        case .littleEndian: UInt64(littleEndian: value)
        }
    }
}
