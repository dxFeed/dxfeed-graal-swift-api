//
//  OrderBase.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 06.10.23.
//

import Foundation

class OrderBase: MarketEvent, IIndexedEvent, CustomStringConvertible {
    var type: EventCode = .orderBase

    var eventSource: IndexedEventSource

    var eventFlags: Int32 = 0

    var index: Long = 0

    var eventSymbol: String

    var eventTime: Int64 = 0
    /*
     * Flags property has several significant bits that are packed into an integer in the following way:
     *   31..15   14..11    10..4    3    2    1    0
     * +--------+--------+--------+----+----+----+----+
     * |        | Action |Exchange|  Side   |  Scope  |
     * +--------+--------+--------+----+----+----+----+
     */

    // ACTION values are taken from OrderAction enum.
    private static let actionMask = 0x0f
    private static let actionShift = 11

    // EXCHANGE values are ASCII chars in [0, 127].
    private static let exchangeMask = 0x7f
    private static let exchangeShift = 4

    // SIDE values are taken from Side enum.
    private static let sideMask = 3
    private static let sideShift = 2

    // SCOPE values are taken from Scope enum.
    private static let scopeMask = 3
    private static let scopeShift = 0
    /*
     * Index field contains source identifier, optional exchange code and low-end index (virtual id or MMID).
     * Index field has 2 formats depending on whether source is "special" (see OrderSource.IsSpecialSourceId()).
     * Note: both formats are IMPLEMENTATION DETAILS, they are subject to change without notice.
     *   63..48   47..32   31..16   15..0
     * +--------+--------+--------+--------+
     * | Source |Exchange|      Index      |  <- "special" order sources (non-printable id with exchange)
     * +--------+--------+--------+--------+
     *   63..48   47..32   31..16   15..0
     * +--------+--------+--------+--------+
     * |     Source      |      Index      |  <- generic order sources (alphanumeric id without exchange)
     * +--------+--------+--------+--------+
     * Note: when modifying formats track usages of getIndex/setIndex, getSource/setSource and isSpecialSourceId
     * methods in order to find and modify all code dependent on current formats.
     */

    /*
     * EventFlags property has several significant bits that are packed into an integer in the following way:
     *    31..7    6    5    4    3    2    1    0
     * +---------+----+----+----+----+----+----+----+
     * |         | SM |    | SS | SE | SB | RE | TX |
     * +---------+----+----+----+----+----+----+----+
     */

    /// Gets or sets time and sequence of this order packaged into single long value
    /// This method is intended for efficient order time priority comparison.
    /// Do not set their property directly.
    public var timeSequence: Int64 = 0
    /// Gets or sets microseconds and nanoseconds time part of this order.
    public var timeNanoPart: Int32 = 0
    /// Gets or sets time of the last ``action``
    public var actionTime: Int64 = 0
    /// Gets or sets order ID if available.
    /// Some actions ``OrderAction/trade``, ``OrderAction/bust``
    /// have no order ID since they are not related to any order in Order book.
    public let orderId: Int64 = 0
    /// Gets or sets order ID if available.
    /// Returns auxiliary order ID if available:.
    /// ``OrderAction/new`` ID of the order replaced by this new order.
    /// ``OrderAction/delete`` - ID of the order that replaces this deleted order.
    /// ``OrderAction/partial`` - ID of the aggressor order.
    /// ``OrderAction/execute`` - ID of the aggressor order.
    public var auxOrderId: Int64 = 0
    /// Gets or sets price of this order event.
    public var price: Double = .nan
    /// Gets or sets size of this order event as floating number with fractions.
    public var size: Double = .nan
    /// Gets or sets executed size of this order.
    public var executedSize: Double = .nan
    /// Gets or sets number of individual orders in this aggregate order.
    public var count: Int64 = 0
    /// Gets or sets implementation-specific flags.
    /// **Do not use this property directly.**
    var flags: Int32 = 0
    /// Gets or sets trade (order execution) ID for events containing trade-related action.
    /// Returns 0 if trade ID not available.
    public var tradeId: Int64 = 0
    /// Gets or sets trade price for events containing trade-related action.
    public var tradePrice: Double = .nan
    /// Gets or sets trade size for events containing trade-related action.
    public var tradeSize: Double = .nan
    
    init(_ eventSymbol: String) {
        self.eventSymbol = eventSymbol
    }

    public var description: String {
"""
DXFG_ORDER_BASE_T \
eventSymbol: \(eventSymbol) \
eventTime: \(eventTime) \
eventFlags: \(eventFlags), \
index: \(index), \
timeSequence: \(timeSequence), \
timeNanoPart: \(timeNanoPart), \
actionTime: \(actionTime), \
orderId: \(orderId), \
auxOrderId: \(auxOrderId), \
price: \(price), \
size: \(size), \
executedSize: \(executedSize), \
count: \(count), \
flags: \(flags), \
tradeId: \(tradeId), \
tradePrice: \(tradePrice), \
tradeSize: \(tradeSize)
"""
        }
    
}


extension OrderBase {
    func hsaSize() -> Bool {
        return size != 0 && !size.isNaN
    }
}
