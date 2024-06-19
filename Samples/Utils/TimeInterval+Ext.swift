//
//  TimeInterval+Ext.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 15.06.23.
//

import Foundation

extension TimeInterval {
    func stringFromTimeInterval() -> String {
        let time = NSInteger(self)
        let miliseconds = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d", hours, minutes, seconds, miliseconds)
    }
}
