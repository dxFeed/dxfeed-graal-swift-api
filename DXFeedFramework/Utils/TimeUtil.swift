//
//  TimeUtil.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.08.23.
//

import Foundation

public class TimeUtil {
    static let second =  Long(1000)
    static let minute =  60 * second
    static let hour = 60 * minute
    static let day = 24 * hour

    static let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        return formatter
    }()
    static let dateFormatterWithMillis = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm.SSS"
        return formatter
    }()

    public static func getMillisFromTime(_ timeMillis: Long) -> Int {
        return Int(MathUtil.floorMod(timeMillis, second))
    }

    public static func toLocalDateString(millis: Int64) -> String {
        let timeInterval = Double(millis) / 1000
        return (dateFormatterWithMillis.string(from: Date(timeIntervalSince1970: timeInterval)))
    }

    public static func toLocalDateStringWithoutMillis(millis: Int64) -> String {
        let timeInterval = Double(millis) / 1000
        return (dateFormatter.string(from: Date(timeIntervalSince1970: timeInterval)))
    }

    public static func getSecondsFromTime(_ timeMillis: Long) -> Int {
        if timeMillis >= 0 {
            return min(Int(timeMillis / second), Int.max)
        } else {
            return max(Int((timeMillis + 1) / second) - 1, Int.min)
        }
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
    public static func parse(_ string: String) -> Date? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed == "0" {
            return Date(timeIntervalSince1970: 0)
        }
        let formatter = DateFormatter()
        for format in TimeFormat.availableFormats {

            if format == TimeFormat.sortableFormat {
                print("format ")
            }
            formatter.dateFormat = format
            if let date = formatter.date(from: trimmed) {
                return date
            }
        }
        if let date = ISO8601DateFormatter().date(from: trimmed) {
            return date
        }

        if let msValue = Long(string) {
            return Date(millisecondsSince1970: msValue)
        }
        return nil
    }

}
