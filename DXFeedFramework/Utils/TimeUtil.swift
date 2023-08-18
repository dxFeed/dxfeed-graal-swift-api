//
//  TimeUtil.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.08.23.
//

import Foundation

class TimeUtil {
    public static let second =  Long(1000)
    public static let minute =  60 * Long(1000)
    static let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm"
        return formatter
    }()

    public static func getMillisFromTime(timeMillis: Long) -> Int {
        return Int(MathUtil.floorMod(timeMillis, second))
    }

    public static func toLocalDateString(millis: Int64) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: Double(millis / 1000)))
    }
}
