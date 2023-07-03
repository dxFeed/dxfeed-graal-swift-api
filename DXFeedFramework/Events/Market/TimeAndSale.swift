//
//  TimeAndSale.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 06.06.23.
//

import Foundation

public class TimeAndSale: MarketEvent, CustomStringConvertible {
    public let type: EventCode = .timeAndSale
    public let eventSymbol: String
    public let eventTime: Int64

    public let eventFlags: Int32
    public let index: Int64
    public let timeNanoPart: Int32
    public let exchangeCode: Int16
    public let price: Double
    public let size: Double
    public let bidPrice: Double
    public let askPrice: Double
    public let exchangeSaleConditions: String
    public let flags: Int32
    public let buyer: String
    public let seller: String
    init(eventSymbol: String,
         eventTime: Int64,
         eventFlags: Int32,
         index: Int64,
         timeNanoPart: Int32,
         exchangeCode: Int16,
         price: Double,
         size: Double,
         bidPrice: Double,
         askPrice: Double,
         exchangeSaleConditions: String,
         flags: Int32,
         buyer: String,
         seller: String) {
        self.eventSymbol = eventSymbol
        self.eventTime = eventTime
        self.eventFlags = eventFlags
        self.index = index
        self.timeNanoPart = timeNanoPart
        self.exchangeCode = exchangeCode
        self.price = price
        self.size = size
        self.bidPrice = bidPrice
        self.askPrice = askPrice
        self.exchangeSaleConditions = exchangeSaleConditions
        self.flags = flags
        self.buyer = buyer
        self.seller = seller
    }
    public var description: String {
        """
DXFG_TIME_AND_SALE_T \
eventSymbol: \(eventSymbol) \
eventTime: \(eventTime) \
eventFlags: \(eventFlags), \
index: \(index), \
timeNanoPart: \(timeNanoPart), \
exchangeCode: \(exchangeCode), \
price: \(price), \
size: \(size), \
bidPrice: \(bidPrice), \
askPrice: \(askPrice), \
exchangeSaleConditions: \(exchangeSaleConditions), \
flags: \(flags), \
buyer: \(buyer), \
seller: \(seller)
"""
    }
}
