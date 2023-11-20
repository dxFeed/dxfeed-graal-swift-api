//
//  DXTimePeriod.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 20.11.23.
//

import Foundation

public class DXTimePeriod {
    public static let zero: DXTimePeriod? = {
        if let timePeriod = NativeTimePeriod.zero() {
            return DXTimePeriod(timePeriod: timePeriod)
        } else {
            return nil
        }
    }()

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

    convenience init(value: Int64) throws {
        let timePeriod = try NativeTimePeriod(value: value)
        self.init(timePeriod: timePeriod)
    }

    convenience init(value: String) throws {
        let timePeriod = try NativeTimePeriod(value: value)
        self.init(timePeriod: timePeriod)
    }
}
