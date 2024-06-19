//
//  TimeUtil.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 18.08.23.
//

import Foundation

class TimeUtil {
    static let second =  Long(1000)
    static let minute =  60 * second
    static let hour = 60 * minute
    static let day = 24 * hour

    static let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm"
        return formatter
    }()

    static func getMillisFromTime(_ timeMillis: Long) -> Int {
        return Int(MathUtil.floorMod(timeMillis, second))
    }

    static func toLocalDateString(millis: Int64) -> String {
        return "\(dateFormatter.string(from: Date(timeIntervalSince1970: Double(millis / 1000)))) \(millis % 1000)"
    }

    static func toLocalDateStringWithoutMillis(millis: Int64) -> String {
        return "\(dateFormatter.string(from: Date(timeIntervalSince1970: Double(millis / 1000))))"
    }

    static func getSecondsFromTime(_ timeMillis: Long) -> Int {
        if timeMillis >= 0 {
            return min(Int(timeMillis / second), Int.max)
        } else {
            return max(Int((timeMillis + 1) / second) - 1, Int.min)
        }
    }

}
