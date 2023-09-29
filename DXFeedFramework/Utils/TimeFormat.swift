//
//  TimeFormat.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 28.09.23.
//

import Foundation

class TimeFormat {
    /// Default format string.
    /// Example:
    /// 20090615-134530.
    static let defaultFormat = "yyyyMMdd-HHmmss"

    /// Format string for only date representation.
    /// Example:
    /// 20090615.
    static let onlyDateFormat = "yyyyMMdd"

    /// Format string with milliseconds.
    static let withMillisFormat = ".SSSS"

    /// Format string with TimeZone.
    static let withTimeZoneFormat = "zzz"

    /// Full ISO format string.
    /// Example:
    /// 2009-06-15T13:45:30.0000000Z.
    static let fullIsoFormat = "o"

    /// Sortable date/time format string.
    /// Example:
    /// 2009-06-15T13:45:30.
    static let sortableFormat = "yyyy-MM-dd'T'HH:mm:ss"

    /// Universal format string.
    /// Example:
    /// 2009-06-15 13:45:30Z.
    static let universalFormat = "yyyy-MM-dd HH:mm:ssZ"

    static let defaultDateTime = "yyyy-MM-dd HH:mm:ss"
    static let defaultDate = "yyyy-MM-dd"

    static let availableFormats = [
        defaultFormat,
        "\(defaultFormat)\(withMillisFormat)",
        "\(defaultFormat)\(withTimeZoneFormat)",
        "\(defaultFormat)Z",
        "\(defaultFormat)\(withMillisFormat)\(withTimeZoneFormat)",
        "\(defaultFormat)\(withMillisFormat)Z",
        onlyDateFormat,
        "\(onlyDateFormat)\(withTimeZoneFormat)",
        "\(onlyDateFormat)Z",
        fullIsoFormat,
        sortableFormat,
        universalFormat,
        "\(defaultDate)Z",
        defaultDate,
        defaultDateTime,
        "\(defaultDateTime)\(withMillisFormat)\(withTimeZoneFormat)"
    ]
}
