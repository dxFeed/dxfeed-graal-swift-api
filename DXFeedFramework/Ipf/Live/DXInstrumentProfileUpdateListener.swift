//
//  DXInstrumentProfileUpdateListener.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.09.23.
//

import Foundation

public protocol DXInstrumentProfileUpdateListener: AnyObject {
    func instrumentProfilesUpdated(_ instruments: [InstrumentProfile])
}
