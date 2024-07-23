//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Reads instrument profiles from the stream using Instrument Profile Format (IPF).
///
/// Please see Instrument Profile Format documentation for complete description.
/// This reader automatically uses data formats as specified in the stream.
///
/// This reader is intended for "one time only" usage: create new instances for new IPF reads.
/// Use {@link InstrumentProfileConnection} if support for streaming updates of instrument profiles is needed.
///
/// For backward compatibility reader can be configured with system property "-Dcom.dxfeed.ipf.complete" to control
/// the strategy for missing "##COMPLETE" tag when reading IPF, possible values are:
///
public class DXInstrumentProfileReader {
    private lazy var native: NativeInstrumentProfileReader? = {
        try? NativeInstrumentProfileReader()
    }()

    public init() {}
    /// Returns last modification time (in milliseconds) from last ``readFromFile(address:)`` operation
    /// or zero if it is unknown.
    public func getLastModified() -> Long {
        return native?.getLastModified() ?? 0
    }
    /// Returns true if IPF was fully read on last {@link #readFromFile} operation.
    public func wasComplete() -> Bool {
        return native?.wasComplete() ?? false
    }

    ///  Reads and returns instrument profiles from specified file.
    ///
    ///  This method recognizes data compression formats "zip" and "gzip" automatically.
    ///  In case of zip the first file entry will be read and parsed as a plain data stream.
    ///  In case of gzip compressed content will be read and processed.
    ///  In other cases data considered uncompressed and will be parsed as is.
    ///
    ///  Authentication information can be supplied to this method as part of URL user info
    ///  like  "http://user:password@host:port/path/file.ipf"
    ///
    ///  This is a shortcut for ``readFromFile(address:user:password:)``
    ///
    ///  This operation updates ``getLastModified()`` and ``wasComplete()``
    ///
    /// - Parameters:
    ///     - address: URL of file to read from
    /// - Returns: List of``InstrumentProfile``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func readFromFile(address: String) throws -> [InstrumentProfile]? {
        return try native?.readFromFile(address: address)
    }

    ///  Reads and returns instrument profiles from specified file.
    ///
    ///  This method recognizes data compression formats "zip" and "gzip" automatically.
    ///  In case of zip the first file entry will be read and parsed as a plain data stream.
    ///  In case of gzip compressed content will be read and processed.
    ///  In other cases data considered uncompressed and will be parsed as is.
    ///
    ///  Authentication information can be supplied to this method as part of URL user info
    ///  like  "http://user:password@host:port/path/file.ipf"
    ///
    ///
    ///  This operation updates ``getLastModified()`` and ``wasComplete()``
    ///
    /// - Parameters:
    ///     - address: URL of file to read from
    ///     - user: the user name
    ///     - password: the password
    /// - Returns: List of``InstrumentProfile``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func readFromFile(address: String, user: String, password: String) throws -> [InstrumentProfile]? {
        return try native?.readFromFile(address: address, user: user, password: password)
    }

    ///  Reads and returns instrument profiles from specified address with a specified token credentials.
    ///
    ///  This method recognizes data compression formats "zip" and "gzip" automatically.
    ///  In case of zip the first file entry will be read and parsed as a plain data stream.
    ///  In case of gzip compressed content will be read and processed.
    ///  In other cases data considered uncompressed and will be parsed as is.
    ///
    ///  Specified token take precedence over authentication information that is supplied to this method
    ///  as part of URL user info like  "http://user:password@host:port/path/file.ipf"
    ///
    ///
    ///  This operation updates ``getLastModified()`` and ``wasComplete()``
    ///
    /// - Parameters:
    ///     - address: URL of file to read from
    ///     - token: the token    
    /// - Returns: List of``InstrumentProfile``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func readFromFile(address: String, token: DXAuthToken) throws -> [InstrumentProfile]? {
        return try native?.readFromFile(address: address, token: token.native)
    }

    /// Converts a specified string address specification into an URL that will be read by ``read(data:address:)`` using Data
    public static func resolveSourceURL(address: String) -> String {
        return NativeInstrumentProfileReader.resolveSourceURL(address: address)
    }

    /// Reads and returns instrument profiles from specified stream(Data)
    ///
    ///  This method recognizes data compression formats "zip" and "gzip" automatically.
    ///  In case of zip the first file entry will be read and parsed as a plain data stream.
    ///  In case of gzip compressed content will be read and processed.
    ///  In other cases data considered uncompressed and will be parsed as is.
    ///
    ///
    ///
    ///  This operation updates ``wasComplete()``
    ///
    /// - Parameters:
    ///     - address: URL of file to read from
    ///     - data: Data with IPF
    ///     - password: the password
    /// - Returns: List of``InstrumentProfile``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func read(data: Data, address: String) throws -> [InstrumentProfile]? {
        return try native?.read(data: data, address: address)
    }

    /// Reads and returns instrument profiles from specified stream(Data)
    ///
    ///  This method recognizes data compression formats "zip" and "gzip" automatically.
    ///  In case of zip the first file entry will be read and parsed as a plain data stream.
    ///  In case of gzip compressed content will be read and processed.
    ///  In other cases data considered uncompressed and will be parsed as is.
    ///
    ///
    ///
    ///  This operation updates ``wasComplete()``
    ///
    /// - Parameters:
    ///     - data: Data with IPF
    ///     - password: the password
    /// - Returns: List of``InstrumentProfile``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func readCompressed(data: Data) throws -> [InstrumentProfile]? {
        return try native?.readCompressed(data: data)
    }

    /// Reads and returns instrument profiles from specified stream(Data)
    ///
    ///  This method recognizes data compression formats "zip" and "gzip" automatically.
    ///  In case of zip the first file entry will be read and parsed as a plain data stream.
    ///  In case of gzip compressed content will be read and processed.
    ///  In other cases data considered uncompressed and will be parsed as is.
    ///
    ///
    ///
    ///  This operation updates ``wasComplete()``
    ///
    /// - Parameters:
    ///     - data: Data with IPF
    ///     - password: the password
    /// - Returns: List of``InstrumentProfile``
    /// - Throws: ``GraalException``. Rethrows exception from Java
    public func read(data: Data) throws -> [InstrumentProfile]? {
        return try native?.read(data: data)
    }
}
