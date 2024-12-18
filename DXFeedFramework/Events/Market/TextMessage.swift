//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

public class TextMessage: MarketEvent {
    public class override var type: EventCode { .textMessage }

    /// Gets or sets time and sequence of this series packaged into single long value.
    ///
    /// This method is intended for efficient series time priority comparison.
    /// **Do not use this method directly**
    ///
    /// Change ``time`` and/or  ``setSequence(_:)``
    public internal(set) var timeSequence: Long = 0

    /// Content of message.
    public var text: String?

    /// Initializes a new instance of the ``TextMessage`` class.
    public required init(_ symbol: String) {
        super.init()
        self.eventSymbol = symbol
    }

    /// Gets sequence number of the last trade to distinguish trades that have the same ``time``.
    ///
    /// This sequence number does not have to be unique and
    /// does not need to be sequential. Sequence can range from 0 to ``MarketEventConst/maxSequence``.
    public func getSequence() -> Int {
        return Int(timeSequence) & Int(MarketEventConst.maxSequence)
    }

    /// Sets sequence number of the last trade to distinguish trades that have the same ``time``.
    ///
    /// This sequence number does not have to be unique and
    /// does not need to be sequential. Sequence can range from 0 to ``MarketEventConst/maxSequence``.
    ///
    /// - Throws: ``ArgumentException/exception(_:)``
    public func setSequence(_ sequence: Int) throws {
        if sequence < 0 && sequence > MarketEventConst.maxSequence {
            throw ArgumentException.exception(
                "Sequence(\(sequence) is < 0 or > MaxSequence(\(MarketEventConst.maxSequence)"
            )
        }
        timeSequence = (timeSequence & Long(~MarketEventConst.maxSequence)) | Long(sequence)
    }

    /// Gets or sets time of the last trade.
   /// Time is measured in milliseconds between the current time and midnight, January 1, 1970 UTC.
    public var time: Long {
        get {
            ((timeSequence >> 32) * 1000) + ((timeSequence >> 22) & 0x3ff)
        }
        set {
            timeSequence = Long(TimeUtil.getSecondsFromTime(newValue) << 32) |
            (Long(TimeUtil.getMillisFromTime(newValue)) << 22) |
            Long(getSequence())
        }
    }

    public override func toString() -> String {
        return """
TextMessage{\(eventSymbol), \
eventTime=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: eventTime)) ?? ""), \
time=\((try? DXTimeFormat.defaultTimeFormat?.withMillis?.format(value: time)) ?? ""), \
sequence=\(getSequence()), \
attachment=\(text ?? "null value")}
"""
    }

}
