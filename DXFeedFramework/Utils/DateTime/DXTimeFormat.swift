//
//  DXTimeFormat.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 20.11.23.
//

import Foundation

public class DXTimeFormat {
    public static let defaultTimeFormat: DXTimeFormat? = {
        if let timeFormat = NativeTimeFormat.defaultTimeFormat() {
            return DXTimeFormat(timeFormat: timeFormat)
        } else {
            return nil
        }
    }()

    public static let gmtTimeFormat: DXTimeFormat? = {
        if let timeFormat = NativeTimeFormat.gmtTimeFormat() {
            return DXTimeFormat(timeFormat: timeFormat)
        } else {
            return nil
        }
    }()

    private var timeFormat: NativeTimeFormat

    private init(timeFormat: NativeTimeFormat) {
        self.timeFormat = timeFormat
    }

    public convenience init(timeZone: DXTimeZone) throws {
        let timeFormat = try NativeTimeFormat(timeZone: timeZone.timeZone)
        self.init(timeFormat: timeFormat)
    }

    public convenience init(withTimeZone timeFormat: DXTimeFormat) throws {
        let timeFormat = try NativeTimeFormat(withTimeZone: timeFormat.timeFormat)
        self.init(timeFormat: timeFormat)
    }

    public convenience init(withMillis timeFormat: DXTimeFormat) throws {
        let timeFormat = try NativeTimeFormat(withMillis: timeFormat.timeFormat)
        self.init(timeFormat: timeFormat)
    }

    public convenience init(fullIso timeFormat: DXTimeFormat) throws {
        let timeFormat = try NativeTimeFormat(fullIso: timeFormat.timeFormat)
        self.init(timeFormat: timeFormat)
    }
}
