//
//  Data+Compression.swift
//  BaaS
//
//  Created by Wesley de Groot on 28/12/2018.
//  Copyright © 2018 Wesley de Groot. All rights reserved.
//

import Foundation
import Compression

/**
 * **B**ackend **a**s **a** **S**ervice (_BaaS_)
 *
 * This class is used for the BaaS Server Interface.
 *
 * .
 *
 * **Simple usage**
 *
 *      class myClass: UIViewController, BaaSDelegate {
 *          let db = BaaS.shared
 *
 *          override func viewDidLoad() {
 *              db.delegate = self
 *              db.set(apiKey: "YOURAPIKEY")
 *              db.set(server: "https://yourserver.tld/BaaS")
 *          }
 *      }
 */
extension BaaS {
    /**
     *
     */
    func compress(data: Data) -> Data {
        guard let compressed = data.deflate() else {
            return "".data(using: .utf8)!
        }

        return compressed
    }

    /**
     *
     */
    func decompress(data: Data) -> Data {
        guard let decompressed = data.inflate() else {
            return "".data(using: .utf8)!
        }
        
        return decompressed
    }
}

public extension Data
{
    /**
     *
     */
    fileprivate typealias Config = (
        operation: compression_stream_operation,
        algorithm: compression_algorithm
    )

    /**
     *
     */
    fileprivate func perform(
        config: Config,
        source: UnsafePointer<UInt8>,
        sourceSize: Int,
        preload: Data = Data()
        ) -> Data?
    {
        guard config.operation == COMPRESSION_STREAM_ENCODE || sourceSize > 0 else { return nil }
        
        let streamBase = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
        defer {
            streamBase.deallocate()
        }
        
        var stream = streamBase.pointee
        let status = compression_stream_init(
            &stream,
            config.operation,
            config.algorithm
        )

        guard status != COMPRESSION_STATUS_ERROR else { return nil }
        defer {
            compression_stream_destroy(&stream)
        }
        
        let bufferSize = Swift.max(Swift.min(sourceSize, 64 * 1024), 64)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }

        stream.dst_ptr  = buffer
        stream.dst_size = bufferSize
        stream.src_ptr  = source
        stream.src_size = sourceSize
        var resource = preload
        let flags: Int32 = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)

        while true {
            switch compression_stream_process(&stream, flags) {
            case COMPRESSION_STATUS_OK:
                guard stream.dst_size == 0 else {
                    return nil
                }
                resource.append(buffer, count: stream.dst_ptr - buffer)
                stream.dst_ptr = buffer
                stream.dst_size = bufferSize
            case COMPRESSION_STATUS_END:
                resource.append(buffer, count: stream.dst_ptr - buffer)
                return resource
            default:
                return nil
            }
        }
    }

    /**
     * Compresses the data using the zlib deflate algorithm.
     * - returns: raw deflated data according to [RFC-1951](https://tools.ietf.org/html/rfc1951).
     * - note: Fixed at compression level 5 (best trade off between speed and time)
     */
    func deflate() -> Data?
    {
        return self.withUnsafeBytes {
            (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            let configuration = (
                operation: COMPRESSION_STREAM_ENCODE,
                algorithm: COMPRESSION_ZLIB
            )

            return perform(
                config: configuration,
                source: sourcePtr,
                sourceSize: count
            )
        }
    }
    
    /**
     * Decompresses the data using the zlib deflate algorithm.
     * Self is expected to be a raw deflate
     * stream according to [RFC-1951](https://tools.ietf.org/html/rfc1951).
     * - returns: uncompressed data
     */
    func inflate() -> Data?
    {
        //'withUnsafeBytes' is deprecated: use `withUnsafeBytes<R>(_: (UnsafeRawBufferPointer) throws -> R) rethrows -> R` instead
        return self.withUnsafeBytes {
            (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            let configuration = (
                operation: COMPRESSION_STREAM_DECODE,
                algorithm: COMPRESSION_ZLIB
            )

            return perform(
                config: configuration,
                source: sourcePtr,
                sourceSize: count
            )
        }
    }
}

// Fix for swift 5.
extension Data
{
    func withUnsafeBytes<ResultType, ContentType>(_ body: (UnsafePointer<ContentType>) throws -> ResultType) rethrows -> ResultType
    {
        return try self.withUnsafeBytes({
            (rawBufferPointer: UnsafeRawBufferPointer) -> ResultType in
            return try body(
                rawBufferPointer.bindMemory(to: ContentType.self).baseAddress!
            )
        })
    }
}
