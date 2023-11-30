//
//  DXDateOffset.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 21.11.23.
//

import Foundation

public class DXDateOffset {
    public let era: Int32
    public let year: Int32
    public let month: Int32
    public let day: Int32
    public let dayOfWeek: Int32
    public let milliseconds: Int32

    public init(era: Int32, year: Int32, month: Int32, day: Int32, dayOfWeek: Int32, milliseconds: Int32) {
        self.era = era
        self.year = year
        self.month = month
        self.day = day
        self.dayOfWeek = dayOfWeek
        self.milliseconds = milliseconds
    }
}
