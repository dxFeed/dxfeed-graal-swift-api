//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
/// It is just wrapper aroung Java TimeZone
///
/// TimeZone represents a time zone offset, and also figures out daylight savings.
///
/// Typically, you get a TimeZone using getDefault which creates a TimeZone based on the time zone where the program is running. For example, for a program running in Japan, getDefault creates a TimeZone object based on Japanese Standard Time.
///
/// You can also get a TimeZone using getTimeZone along with a time zone ID. For instance, the time zone ID for the U.S. Pacific Time zone is "America/Los_Angeles". So, you can get a U.S. Pacific Time TimeZone object with.
/// All methods throw exception: GraalException. Rethrows exception from Java.
/// For more details
/// see [For more details see](https://docs.oracle.com/javase/8/docs/api/java/util/TimeZone.html)
public class DXTimeZone {
    public static let defaultTimeZone: DXTimeZone? = {
        if let timeZone = NativeTimeZone.defaultTimeZone() {
            return DXTimeZone(timeZone: timeZone)
        } else {
            return nil
        }
    }()

    internal let timeZone: NativeTimeZone

    private init(timeZone: NativeTimeZone) {
        self.timeZone = timeZone
    }

    public convenience init(timeZoneID: String) throws {
        self.init(timeZone: try NativeTimeZone(timeZoneID: timeZoneID))
    }

    public func id() throws -> String? {
        return try self.timeZone.id()
    }

    public func diplayName() throws -> String? {
        return try self.timeZone.diplayName()
    }

    public func diplayName(dayLight: Int32, style: Int32) throws -> String? {
        return try self.timeZone.diplayName(dayLight: dayLight, style: style)
    }

    public func getDSTSavings() throws -> Int32 {
        return try self.timeZone.getDSTSavings()
    }

    public func useDaylightTime() throws -> Int32 {
        return try self.timeZone.useDaylightTime()
    }

    public func observesDaylightTime() throws -> Int32 {
        return try self.timeZone.observesDaylightTime()
    }

    public func getOffset(date: Int64) throws -> Int32 {
        return try self.timeZone.getOffset(date: date)
    }

    public func getOffset2(offset: DXDateOffset) throws -> Int32 {
        return try self.timeZone.getOffset2(offset: offset)
    }

    public func getRawOffset() throws -> Int32 {
        return try self.timeZone.getRawOffset()
    }

    public func hasSameRules(other: DXTimeZone) throws -> Int32 {
        return try self.timeZone.hasSameRules(other: other.timeZone)
    }

    public func inDaylightTime(date: Int64) throws -> Int32 {
        return try self.timeZone.inDaylightTime(date: date)
    }

    public func setID(id: String) throws -> Bool {
        return try self.timeZone.setID(id: id)
    }

    public func setRawOffset(offsetMillis: Int32) throws -> Bool {
        return try self.timeZone.setRawOffset(offsetMillis: offsetMillis)
    }
}
