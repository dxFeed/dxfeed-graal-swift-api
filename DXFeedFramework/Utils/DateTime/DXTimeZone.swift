//
//  DXTimeZone.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 20.11.23.
//

import Foundation

public class DXTimeZone {
    public static let defaultTimeZone: DXTimeZone? = {
        if let timeZone = NativeTimeZone.defaultTimeZone() {
            return DXTimeZone(timeZone: timeZone)
        } else {
            return nil
        }
    }()

    internal var timeZone: NativeTimeZone

    private init(timeZone: NativeTimeZone) {
        self.timeZone = timeZone
    }
    
    public convenience init(timeZoneID: String) throws {
        self.init(timeZone: try NativeTimeZone(timeZoneID: timeZoneID))
    }
}
