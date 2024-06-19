//
//  InstrumentProfileUpdateListener.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.09.23.
//

import Foundation

public protocol InstrumentProfileUpdateListener: AnyObject {
    func instrumentProfilesUpdated(_ instruments: [InstrumentProfile])
}
