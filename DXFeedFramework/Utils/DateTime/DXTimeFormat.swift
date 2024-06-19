//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Utility class for parsing and formatting dates and times in ISO-compatible format.
///
public class DXTimeFormat {

    /// An instance of TimeFormat that corresponds to default timezone
    public static let defaultTimeFormat: DXTimeFormat? = {
        if let timeFormat = NativeTimeFormat.defaultTimeFormat() {
            return DXTimeFormat(timeFormat: timeFormat)
        } else {
            return nil
        }
    }()

    ///  An instance of TimeFormat that corresponds to GMT timezone
    public static let gmtTimeFormat: DXTimeFormat? = {
        if let timeFormat = NativeTimeFormat.gmtTimeFormat() {
            return DXTimeFormat(timeFormat: timeFormat)
        } else {
            return nil
        }
    }()

    internal var timeFormat: NativeTimeFormat

    private init(timeFormat: NativeTimeFormat) {
        self.timeFormat = timeFormat
    }

    /// An instance of TimeFormat With Millis that corresponds to default timezone
    public lazy var withMillis: DXTimeFormat? = {
        return try? DXTimeFormat(withMillis: self)
    }()

    /// Returns TimeFormat instance for a specified timezone.
    /// - Throws: GraalException. Rethrows exception from Java.
    public convenience init(timeZone: DXTimeZone) throws {
        let timeFormat = try NativeTimeFormat(timeZone: timeZone.timeZone)
        self.init(timeFormat: timeFormat)
    }

    /// Returns TimeFormat instance that also includes timezone into string
    /// - Throws: GraalException. Rethrows exception from Java.
    public convenience init(withTimeZone timeFormat: DXTimeFormat) throws {
        let timeFormat = try NativeTimeFormat(withTimeZone: timeFormat.timeFormat)
        self.init(timeFormat: timeFormat)
    }

    /// Returns TimeFormat instance that also includes milliseconds into string
    /// - Throws: GraalException. Rethrows exception from Java.
    public convenience init(withMillis timeFormat: DXTimeFormat) throws {
        let timeFormat = try NativeTimeFormat(withMillis: timeFormat.timeFormat)
        self.init(timeFormat: timeFormat)
    }

    /// Returns TimeFormat instance that produces full ISO8610 string of "yyyy-MM-dd'T'HH:mm:ss.SSSX".
    /// - Throws: GraalException. Rethrows exception from Java.
    public convenience init(fullIso timeFormat: DXTimeFormat) throws {
        let timeFormat = try NativeTimeFormat(fullIso: timeFormat.timeFormat)
        self.init(timeFormat: timeFormat)
    }

}

public extension DXTimeFormat {
    /// Converts the specified string representation of a date and time
    ///
    /// If no time zone is specified in the parsed string, the string is assumed to denote a local time,
    /// and converted to current Date.
    ///
    /// It accepts the following formats.
    ///
    /// **0**
    ///
    ///  is parsed as zero time in UTC.
    ///
    /// **long-value-in-milliseconds**
    ///
    /// The value in milliseconds since Unix epoch since Unix epoch.
    /// It should be positive and have at least 9 digits
    /// (otherwise it could not be distinguished from date in format 'yyyymmdd').
    /// Each date since 1970-01-03 can be represented in this form.
    ///
    ///
    /// **date**[time][timezone]
    /// If time is missing it is supposed to be '00:00:00'.
    ///
    ///
    /// **date** is one of:
    ///
    ///     yyyy-MM-dd
    ///
    ///     yyyyMMdd
    ///
    ///
    /// **time** is one of:
    ///
    ///     HH:mm:ss[.sss]
    ///
    ///     HHmmss[.sss]
    ///
    ///
    /// **timezone** is one of:
    ///
    ///     [+-]HH:mm
    ///
    ///     [+-]HHmm
    ///
    ///     Z for UTC.
    ///
    /// - Parameters:
    ///    - string: String value to parse.
    /// -  Returns: Timeinterval since 1 Jan 1970, in milliseconds
    func parse(_ value: String) throws -> Long? {
        return try NativeTimeUtil.parse(timeFormat: timeFormat, value: value)
    }

    /// Converts the specified string representation of a date and time
    ///
    /// If no time zone is specified in the parsed string, the string is assumed to denote a local time,
    /// and converted to current Date.
    ///
    /// It accepts the following formats.
    ///
    /// **0**
    ///
    ///  is parsed as zero time in UTC.
    ///
    /// **long-value-in-milliseconds**
    ///
    /// The value in milliseconds since Unix epoch since Unix epoch.
    /// It should be positive and have at least 9 digits
    /// (otherwise it could not be distinguished from date in format 'yyyymmdd').
    /// Each date since 1970-01-03 can be represented in this form.
    ///
    ///
    /// **date**[time][timezone]
    /// If time is missing it is supposed to be '00:00:00'.
    ///
    ///
    /// **date** is one of:
    ///
    ///     yyyy-MM-dd
    ///
    ///     yyyyMMdd
    ///
    ///
    /// **time** is one of:
    ///
    ///     HH:mm:ss[.sss]
    ///
    ///     HHmmss[.sss]
    ///
    ///
    /// **timezone** is one of:
    ///
    ///     [+-]HH:mm
    ///
    ///     [+-]HHmm
    ///
    ///     Z for UTC.
    ///
    /// - Parameters:
    ///    - string: String value to parse.
    /// -  Returns: Date parsed from value.
    func parse(_ value: String) throws -> Date? {
        let result =  try NativeTimeUtil.parse(timeFormat: timeFormat, value: value)
        return Date(millisecondsSince1970: result)
    }

    /// Converts object into string according to the format like yyyyMMdd-HHmmss
    ///
    /// - Parameters:
    ///   - value: time date and time to format.
    /// - Returns: string representation of data and time.
    /// - Throws: GraalException. Rethrows exception from Java.
    func format(value: Long) throws -> String? {
        return try NativeTimeUtil.format(timeFormat: timeFormat, value: value)
    }
}
