//
//  Gzip.swift
//  Snitch
//
//  Created by BOniani on 16/11/2026.
//

import Foundation

/// Unzips gzip data, such as the batches analytics SDKs upload, with Apple's built-in
/// DEFLATE decoder.
enum Gzip {
    /// The unzipped bytes, or `nil` when `data` isn't complete gzip data.
    static func unzip(_ data: Data) -> Data? {
        let bytes = [UInt8](data)
        guard let start = deflateStart(in: bytes) else { return nil }
        // The last 8 bytes are a checksum and the original size, not compressed data.
        let deflate = Data(bytes[start..<(bytes.count - 8)])
        return try? (deflate as NSData).decompressed(using: .zlib) as Data
    }

    // A 10-byte header, then the optional fields its flags announce (RFC 1952).
    private static func deflateStart(in bytes: [UInt8]) -> Int? {
        guard bytes.count > 18, bytes[0] == 0x1f, bytes[1] == 0x8b, bytes[2] == 8 else { return nil }
        let flags = bytes[3]
        var index = 10
        if flags & 0x04 != 0 {
            index += 2 + Int(bytes[index]) + Int(bytes[index + 1]) << 8
        }
        for flag: UInt8 in [0x08, 0x10] where flags & flag != 0 {
            while index < bytes.count, bytes[index] != 0 { index += 1 }
            index += 1
        }
        if flags & 0x02 != 0 {
            index += 2
        }
        return index < bytes.count - 8 ? index : nil
    }
}
