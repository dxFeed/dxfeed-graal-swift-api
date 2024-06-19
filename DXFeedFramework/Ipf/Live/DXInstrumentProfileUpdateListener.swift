//
//  DXInstrumentProfileUpdateListener.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.09.23.
//

import Foundation
/// The listener delegate for receiving instrument profiles.
public protocol DXInstrumentProfileUpdateListener: AnyObject {
    /// Invoked when instrument profiles received
    ///
    /// - Parameters:
    ///   - instruments: The collection of received profiles.
    func instrumentProfilesUpdated(_ instruments: [InstrumentProfile])
}
