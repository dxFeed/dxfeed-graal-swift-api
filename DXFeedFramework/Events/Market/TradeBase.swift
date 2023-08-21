//
//  TradeBase.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import Foundation

public class TradeBase: MarketEvent, ILastingEvent {
    public let type: EventCode

    public var eventSymbol: String
    public var eventTime: Int64

    public var timeSequence: Long
    public var timeNanoPart: Int32
    public var exchangeCode: Int16
    public var price: Double = .nan
    public var change: Double = .nan
    public var size: Double = .nan
    public var dayId: Int32
    public var dayVolume: Double = .nan
    public var dayTurnover: Double = .nan
    internal var flags: Int32
    init(type: EventCode,
         eventSymbol: String,
         eventTime: Int64,
         timeSequence: Int64,
         timeNanoPart: Int32,
         exchangeCode: Int16,
         price: Double,
         change: Double,
         size: Double,
         dayId: Int32,
         dayVolume: Double,
         dayTurnover: Double,
         flags: Int32) {
        self.type = type
        self.eventSymbol = eventSymbol
        self.eventTime = eventTime
        self.timeSequence = timeSequence
        self.timeNanoPart = timeNanoPart
        self.exchangeCode = exchangeCode
        self.price = price
        self.change = change
        self.size = size
        self.dayId = dayId
        self.dayVolume = dayVolume
        self.dayTurnover = dayTurnover
        self.flags = flags
    }
    public var description: String {
        """
DXFG_TRADE_BASE_T \
eventSymbol: \(eventSymbol) \
eventTime: \(eventTime) \
timeSequence: \(timeSequence), \
timeNanoPart: \(timeNanoPart), \
exchangeCode: \(exchangeCode), \
price: \(price), \
change: \(change), \
size: \(size), \
dayId: \(dayId), \
dayVolume: \(dayVolume), \
dayTurnover: \(dayTurnover), \
flags: \(flags)
"""
    }

    func toString() -> String {
        return "\(typeName){\(baseFieldsToString())}"
    }

    var typeName: String {
        let thisType = Swift.type(of: self)
        return String(describing: thisType)
    }
}

public enum Direction: Int32, CaseIterable {
    // swiftlint:disable identifier_name

    case undefined = 0
    case down
    case zeroDown
    case zero
    case zeroUp
    case up
    // swiftlint:enable identifier_name

    static let values: [Direction] = {
        let allvalues = Direction.allCases
        let length = allvalues.count.roundedUp(toMultipleOf: 2)
        print(length)
        var result = [Direction]()
        for index in 0..<length {
            if index >= allvalues.count {
                result.append(.undefined)
            } else {
                result.append(allvalues[index])
            }
        }
        return result
    }()

    static func valueOf(_ value: Int) -> Direction {
        return Direction.values[value]
    }
}

extension TradeBase {
    private static let directionMask = Int32(7)
    private static let directionShift = Int32(1)
    private static let eth = Int32(1)
    public static let maxSequence = Int((1 << 22) - 1)

    public var tickDirection: Direction {
        get {
            Direction.valueOf(Int(BitUtil.getBits(flags: flags,
                                                  mask: TradeBase.directionMask,
                                                  shift: TradeBase.directionShift)))
        }
        set {
            flags = BitUtil.setBits(flags: flags,
                                    mask: TradeBase.directionMask,
                                    shift: TradeBase.directionShift,
                                    bits: newValue.rawValue)
        }
    }

    public var isExtendedTradingHours: Bool {
        get {
            flags & TradeBase.eth != 0
        }
        set {
            flags = newValue ? flags | TradeBase.eth : flags & ~TradeBase.eth
        }
    }

    public func getSequence() -> Int {
        return Int(timeSequence) & TradeBase.maxSequence
    }

    public func setSequence(_ sequence: Int) throws {
        if sequence < 0 && sequence > TradeBase.maxSequence {
            throw ArgumentException.exception("Sequence(\(sequence) is < 0 or > MaxSequence(\(TradeBase.maxSequence)")
        }
        timeSequence = (timeSequence & Long(~TradeBase.maxSequence)) | Int64(sequence)
    }

    public var time: Long {
        get {
            ((timeSequence >> 32) * 1000) + ((timeSequence >> 22) & 0x3ff)
        }
        set {
            timeSequence = Long(TimeUtil.getSecondsFromTime(newValue) << 32) |
            (TimeUtil.getMillisFromTime(newValue) << 22) |
            newValue
        }
    }

    public var timeNanos: Long {
        get {
            TimeNanosUtil.getNanosFromMillisAndNanoPart(time, timeNanoPart)
        }
        set {
            time = TimeNanosUtil.getNanoPartFromNanos(newValue)
            timeNanoPart = Int32(TimeNanosUtil.getNanoPartFromNanos(newValue))
        }
    }

    func baseFieldsToString() -> String {
        return """
\(eventSymbol), \
eventTime=\(TimeUtil.toLocalDateString(millis: eventTime)), \
time=\(TimeUtil.toLocalDateString(millis: time)), \
timeNanoPart=\(timeNanoPart), \
sequence=\(self.getSequence()), \
exchange=\(StringUtil.encodeChar(char: exchangeCode)), \
price=\(price), \
change=\(change), \
size=\(size), \
day=\(DayUtil.getYearMonthDayByDayId(Int(dayId))), \
dayVolume=\(dayVolume), \
dayTurnover=\(dayTurnover), \
direction=\(tickDirection), \
ETH=\(isExtendedTradingHours)
"""
    }
}
