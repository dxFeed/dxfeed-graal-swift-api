//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

public class OtcMarketsOrder: Order {
    private static let serialVersionUID: Long = 0

    // ========================= private static =========================

    /*
     /// OTC Markets flags property has several significant bits that are packed into an integer in the following way:
     ///   31..7          6                5             4          3       2          1          0
     /// +-------+-----------------+---------------+-----------+--------+-------+-------------+------+
     /// |       | NMS Conditional | AutoExecution | Saturated | OTC Price Type | Unsolicited | Open |
     /// +-------+-----------------+---------------+-----------+--------+-------+-------------+------+
     /// |                Extended Quote Flags                 |             Quote Flags             |
     /// +-----------------------------------------------------+-------------------------------------+
     */
    // swiftlint:disable identifier_name
    private static let NMS_CONDITIONAL: Long = 1 << 6
    private static let AUTO_EXECUTION: Long = 1 << 5
    private static let SATURATED: Long = 1 << 4

    // OTC_PRICE_TYPE values are taken from OtcMarketsPriceType enum.
    private static let OTC_PRICE_TYPE_MASK: Long = 3
    private static let OTC_PRICE_TYPE_SHIFT: Long = 2

    private static let UNSOLICITED: Long = 1 << 1
    private static let OPEN: Long = 1
    // swiftlint:enable identifier_name

    /// Returns Quote Access Payment (QAP) of this OTC Markets order.
    /// QAP functionality allows participants to dynamically set access fees or rebates,
    /// in real-time and on a per-security basis through OTC Dealer or OTC FIX connections.
    /// Positive integers (1 to 30) indicate a rebate, and negative integers (-1 to -30) indicate an access fee.
    /// 0 indicates no rebate or access fee.
    private var quoteAccessPayment: Long = 0
    var otcMarketsFlags: Long = 0

    /// Creates new OTC Markets order event with default values.
    public convenience init(_ eventSymbol: String) {
        self.init(eventSymbol: eventSymbol)
    }

    /// Gets or sets a value indicating whether this event is available for business within the operating hours of the OTC Link system.
    /// All quotes will be closed at the start of the trading day and will remain closed until the traders open theirs.
    public var isOpen: Bool {
        get {
            (otcMarketsFlags & OtcMarketsOrder.OPEN) != 0
        }
        set {
            otcMarketsFlags = newValue ?
            otcMarketsFlags | OtcMarketsOrder.OPEN :
            otcMarketsFlags & ~OtcMarketsOrder.OPEN
        }
    }

    /// Gets or sets a value indicating whether this event is unsolicited.
    public var isUnsolicited: Bool {
        get {
            (otcMarketsFlags & OtcMarketsOrder.UNSOLICITED) != 0
        }
        set {
            otcMarketsFlags = newValue ? otcMarketsFlags |
            OtcMarketsOrder.UNSOLICITED :
            otcMarketsFlags & ~OtcMarketsOrder.UNSOLICITED
        }
    }

    /// Gets or sets OTC Markets price type of this OTC Markets order events.
    public var otcMarketsPriceType: OtcMarketsPriceType {
        get {
            return OtcMarketsPriceType.valueOf(
                Int(BitUtil.getBits(flags: otcMarketsFlags,
                                    mask: OtcMarketsOrder.OTC_PRICE_TYPE_MASK,
                                    shift: OtcMarketsOrder.OTC_PRICE_TYPE_SHIFT)))
        }
        set {
            otcMarketsFlags = BitUtil.setBits(flags: otcMarketsFlags,
                                              mask: OtcMarketsOrder.OTC_PRICE_TYPE_MASK,
                                              shift: OtcMarketsOrder.OTC_PRICE_TYPE_SHIFT,
                                              bits: Long(newValue.rawValue.code))
        }
    }

    /// Gets or sets a value indicating whether this event should NOT be considered for the inside price.
    public var isSaturated: Bool {
        get {
            (otcMarketsFlags & OtcMarketsOrder.SATURATED) != 0
        }
        set {
            otcMarketsFlags = newValue ?
            otcMarketsFlags | OtcMarketsOrder.SATURATED :
            otcMarketsFlags & ~OtcMarketsOrder.SATURATED
        }
    }

    /// Gets or sets a value indicating whether this event is in 'AutoEx' mode.
    /// If this event is in 'AutoEx' mode then a response to an OTC Link trade message will be immediate.
    public var isAutoExecution: Bool {
        get {
            (otcMarketsFlags & OtcMarketsOrder.AUTO_EXECUTION) != 0
        }
        set {
            otcMarketsFlags = newValue ?
            otcMarketsFlags | OtcMarketsOrder.AUTO_EXECUTION :
            otcMarketsFlags & ~OtcMarketsOrder.AUTO_EXECUTION
        }
    }

    /// Gets or sets a value indicating whether this event represents a NMS conditional.
    /// This flag indicates the displayed ``OrderBase/size`` size
    /// is a round lot at least two times greater than the minimum round lot size in the security
    /// and a trade message relating to the event cannot be sent or filled for less than the displayed size.
    public var isNmsConditional: Bool {
        get {
            (otcMarketsFlags & OtcMarketsOrder.NMS_CONDITIONAL) != 0
        }
        set {
            otcMarketsFlags = newValue ?
            otcMarketsFlags | OtcMarketsOrder.NMS_CONDITIONAL :
            otcMarketsFlags & ~OtcMarketsOrder.NMS_CONDITIONAL
        }
    }

    override func baseFieldsToString() -> String {
        super.baseFieldsToString() +
        """
, QAP=\(quoteAccessPayment)\
, open=\(isOpen)\
, unsolicited=\(isUnsolicited)\
, priceType=\(otcMarketsPriceType)\
, saturated=\(isSaturated)\
, autoEx=\(isAutoExecution)\
, NMS=\(isNmsConditional)
"""
    }
}
