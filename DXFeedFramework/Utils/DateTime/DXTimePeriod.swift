//
//  DXTimePeriod.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 20.11.23.
//

import Foundation

/// Value class for period of time with support for ISO8601 duration format.
public class DXTimePeriod {

    /// Time-period of zero.
    public static let zero: DXTimePeriod? = {
        if let timePeriod = NativeTimePeriod.zero() {
            return DXTimePeriod(timePeriod: timePeriod)
        } else {
            return nil
        }
    }()

    /// Time-period of "infinity" (time of Int64.max)
    public static let unlimited: DXTimePeriod? = {
        if let timePeriod = NativeTimePeriod.unlimited() {
            return DXTimePeriod(timePeriod: timePeriod)
        } else {
            return nil
        }
    }()

    private var timePeriod: NativeTimePeriod

    private init(timePeriod: NativeTimePeriod) {
        self.timePeriod = timePeriod
    }

    /// Returns ``TimePeriod`` with  value milliseconds
    /// - Throws: GraalException. Rethrows exception from Java.
    convenience init(value: Int64) throws {
        let timePeriod = try NativeTimePeriod(value: value)
        self.init(timePeriod: timePeriod)
    }
    
    /// Returns TimePeriod represented with a given string.
    ///
    /// Allowable format is ISO8601 duration, but there are some simplifications and modifications available:
    /// Letters are case insensitive.
    /// Letters "P" and "T" can be omitted.
    /// Letter "S" can be also omitted. In this case last number will be supposed to be seconds.
    /// Number of seconds can be fractional. So it is possible to define duration accurate within milliseconds.
    /// Every part can be omitted. It is supposed that it's value is zero then.
    /// String "inf" recognized as unlimited period.
    /// - Throws: GraalException. Rethrows exception from Java.
    convenience init(value: String) throws {
        let timePeriod = try NativeTimePeriod(value: value)
        self.init(timePeriod: timePeriod)
    }
    /// Returns value in milliseconds.
    public func getTime() throws -> Long {
        return try timePeriod.getTime()
    }

    /// Returns value in seconds
    public func getSeconds() throws -> Int32 {
        return try timePeriod.getSeconds()
    }
    
    /// Returns value in nanoseconds.
    public func getNanos() throws -> Long {
        return try timePeriod.getNanos()
    }
}
