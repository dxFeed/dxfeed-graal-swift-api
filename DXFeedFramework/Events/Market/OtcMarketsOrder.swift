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

    ///Creates new OTC Markets order event with default values.
    public convenience init(_ eventSymbol: String) {
        self.init(eventSymbol: eventSymbol)
    }

    /// Returns whether this event is available for business within the operating hours of the OTC Link system.
    /// All quotes will be closed at the start of the trading day and will remain closed until the traders open theirs.
    ///
    /// - Returns: true if this event is available for business within the operating hours of the OTC Link system.
    public func isOpen() -> Bool {
        return (otcMarketsFlags & OtcMarketsOrder.OPEN) != 0
    }

    /// Changes whether this event is available for business within the operating hours of the OTC Link system.
    ///
    /// - Parameters:
    ///    - open: true if this event is available for business within the operating hours of the OTC Link system.
    public func setOpen(_ open: Bool) {
        otcMarketsFlags = open ? otcMarketsFlags | OtcMarketsOrder.OPEN : otcMarketsFlags & ~OtcMarketsOrder.OPEN
    }

    /// Returns whether this event is unsolicited.
    ///
    /// - Returns: true if this event is unsolicited.
    public func isUnsolicited() -> Bool {
        return (otcMarketsFlags & OtcMarketsOrder.UNSOLICITED) != 0
    }

    /// Changes whether this event is unsolicited.
    /// - Parameters:
    ///    - unsolicited: true if this event is unsolicited.
    public func setUnsolicited(_ unsolicited: Bool) {
        otcMarketsFlags = unsolicited ? otcMarketsFlags |
        OtcMarketsOrder.UNSOLICITED : otcMarketsFlags & ~OtcMarketsOrder.UNSOLICITED
    }

    /// Returns OTC Markets price type of this OTC Markets order events.
    ///
    /// - Returns: OTC Markets price type of this OTC Markets order events.
    public func getOtcMarketsPriceType() -> OtcMarketsPriceType {
        return OtcMarketsPriceType.valueOf(Int(BitUtil.getBits(flags: otcMarketsFlags, mask: OtcMarketsOrder.OTC_PRICE_TYPE_MASK, shift: OtcMarketsOrder.OTC_PRICE_TYPE_SHIFT)))
    }

    /// Changes OTC Markets price type of this OTC Markets order events.
    /// - Parameters:
    ///    - otcPriceType: otcPriceType OTC Markets price type of this OTC Markets order events.
    public func setOtcMarketsPriceType(_ otcPriceType: OtcMarketsPriceType) {
        otcMarketsFlags = BitUtil.setBits(flags: otcMarketsFlags,
                                          mask: OtcMarketsOrder.OTC_PRICE_TYPE_MASK,
                                          shift: OtcMarketsOrder.OTC_PRICE_TYPE_SHIFT,
                                          bits: Long(otcPriceType.rawValue.code))
    }

    /// Returns whether this event should NOT be considered for the inside price.
    ///
    /// - Returns: true if this event should NOT be considered for the inside price.
    public func isSaturated() -> Bool {
        return (otcMarketsFlags & OtcMarketsOrder.SATURATED) != 0
    }

    /// Changes whether this event should NOT be considered for the inside price.
    /// - Parameters:
    ///    - saturated:saturated true if this event should NOT be considered for the inside price.
    public func setSaturated(_ saturated: Bool) {
        otcMarketsFlags = saturated ?
        otcMarketsFlags | OtcMarketsOrder.SATURATED :
        otcMarketsFlags & ~OtcMarketsOrder.SATURATED
    }


    /// Returns whether this event is in 'AutoEx' mode.
    /// If this event is in 'AutoEx' mode then a response to an OTC Link trade message will be immediate.
    ///
    /// - Returns: true if this event is in 'AutoEx' mode.
    public func isAutoExecution() -> Bool {
        return (otcMarketsFlags & OtcMarketsOrder.AUTO_EXECUTION) != 0
    }

    /// Changes whether this event is in 'AutoEx' mode.
    /// - Parameters:
    ///    - autoExecution: true if this event is in 'AutoEx' mode.
    public func setAutoExecution(_ autoExecution: Bool) {
        otcMarketsFlags = autoExecution ?
        otcMarketsFlags | OtcMarketsOrder.AUTO_EXECUTION :
        otcMarketsFlags & ~OtcMarketsOrder.AUTO_EXECUTION
    }

    /// Returns whether this event represents a NMS conditional.
    /// This flag indicates the displayed ``OrderBase/size`` size
    /// is a round lot at least two times greater than the minimum round lot size in the security
    /// and a trade message relating to the event cannot be sent or filled for less than the displayed size.
    /// - Returns: true if this event represents a NMS conditional.

    public func isNmsConditional() -> Bool {
        return (otcMarketsFlags & OtcMarketsOrder.NMS_CONDITIONAL) != 0
    }


    /// Changes whether this event represents a NMS conditional.
    /// - Parameters:
    ///    - nmsConditional: true if this event represents a NMS conditional.
    public func setNmsConditional(_ nmsConditional: Bool) {
        otcMarketsFlags = nmsConditional ? otcMarketsFlags | OtcMarketsOrder.NMS_CONDITIONAL : otcMarketsFlags & ~OtcMarketsOrder.NMS_CONDITIONAL
    }

    override func baseFieldsToString() -> String {
        super.baseFieldsToString() +
        """
, QAP=\(quoteAccessPayment)\
, open=\(isOpen())\
, unsolicited=\(isUnsolicited())\
, priceType=\(getOtcMarketsPriceType())\
, saturated=\(isSaturated())\
, autoEx=\(isAutoExecution())\
, NMS=\(isNmsConditional())
"""
    }
}
