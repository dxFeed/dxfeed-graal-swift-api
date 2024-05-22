//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
import DXFeedFramework
import SwiftUI

extension Candle {
    func max() -> Double {
        return Swift.max(Swift.max(self.open, self.close),
                         Swift.max(self.high, self.low))
    }

    func min() -> Double {
        return Swift.min(Swift.min(self.open, self.close),
                         Swift.min(self.high, self.low))
    }
}

class CandleChartModel: ObservableObject {
    static let maxCout = 150
    let symbol: String
    public private(set) var currency = ""
    public private(set) var descriptionString = ""

    var endpoint: DXEndpoint!
    var feed: DXFeed!
    var subscription: DXFeedSubscription?
    var snapshotProcessor: SnapshotProcessor!

    @Published var candles: [CandleModel]
    @Published var xScrollPosition: String = ""
    @Published var xAxisLabels = [String]()
    var xValues = [String]()

    var maxValue: Double = 0
    var minValue: Double = Double.greatestFiniteMagnitude
    var type = CandlePickerType.year

    var loadingInProgress = false
    init(symbol: String,
         endpoint: DXEndpoint?,
         ipfAddress: String) {
        self.symbol = symbol
        self.candles = [CandleModel]()
        try? createSubscription(endpoint: endpoint)
        fetchInfo(ipfAddress: ipfAddress)
    }

    func createSubscription(endpoint: DXEndpoint?) throws {
        if let endpoint = endpoint {
            self.endpoint = endpoint
        } else {
            self.endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        }
        feed = self.endpoint.getFeed()
        subscription = try feed?.createSubscription([Candle.self])
        snapshotProcessor = SnapshotProcessor()
        snapshotProcessor.add(self)
        try subscription?.add(listener: snapshotProcessor)
    }

    func fetchInfo(ipfAddress: String) {
        DispatchQueue.global(qos: .background).async {
            let reader = DXInstrumentProfileReader()
            let address = ipfAddress + self.symbol
            let result = try? reader.readFromFile(address: address)
            guard let result = result  else {
                return
            }
            result.forEach { profile in
                self.currency = profile.currency
                self.descriptionString = profile.descriptionStr
            }
        }
    }

    func updateDate(type: CandlePickerType) {
        print("start load \(Date()) \(type)")
        loadingInProgress = true
        self.type = type
        let date = type.calcualteStartDate()
        candles = [CandleModel]()
        let candleSymbol = CandleSymbol.valueOf(symbol, type.toDxFeedValue())
        let symbol = TimeSeriesSubscriptionSymbol(symbol: candleSymbol, date: date)
        try? subscription?.setSymbols([symbol])
    }

    func fakeLoading() {
        loadingInProgress = true
        self.xScrollPosition = "\(Calendar.current.date(byAdding: .day, value: -1, to: Date())!.timeIntervalSince1970)"
        loadingInProgress = false
    }

    private static func visiblePointsOnScreen(type: CandlePickerType, valuesCount: Int) -> Int {
        switch type {
        case .month:
            return min(valuesCount, 30)
        case .week:
            return min(valuesCount, 30)
        case .year:
            return min(valuesCount, 30)
        case .minute:
            return min(valuesCount, 30)
        case .day:
            return min(valuesCount, 30)
        case .hour:
            return min(valuesCount, 30)
        }
    }

    func visibleDomains() -> Int {
        let valuesCount = self.candles.count
        if valuesCount == 0 {
            return 1
        }
        let pointsOnScreen = CandleChartModel.visiblePointsOnScreen(type: type, valuesCount: valuesCount)
        return pointsOnScreen
    }

    private static func calculateXaxisValues(with type: CandlePickerType, values: [CandleModel]) -> [String] {
        var visiblePages: Double = 1
        let valuesCount = values.count
        if #available(iOS 17.0, *) {
            let pointsOnScreen = CandleChartModel.visiblePointsOnScreen(type: type, valuesCount: valuesCount)
            visiblePages = Double(valuesCount)/Double(pointsOnScreen)
        }
        // initial case, to avoid showing lines on empty screen
        if values.count == 0 {
            return [String]()
        }

        let maxInterval = Int(visiblePages.isNaN ? 1 : visiblePages) * 4
        let stringValues = stride(from: 0, to: valuesCount, by: valuesCount / maxInterval).map { position in
            values[position].stringtimeStamp
        }
        return stringValues
    }
}

extension CandleChartModel: SnapshotDelegate {
    func receiveEvents(_ events: [DXFeedFramework.MarketEvent], isSnapshot: Bool) {
        let result = events.map { marketEvent in
            marketEvent.candle
        }
        DispatchQueue.main.async {
            if isSnapshot {
                self.loadingInProgress = false
                var maxValue = Double.zero
                var minValue = Double.greatestFiniteMagnitude
                let firstNElements = result.prefix(CandleChartModel.maxCout)
                let temp = firstNElements.map { candle in
                    maxValue = max(maxValue, candle.max())
                    minValue = min(minValue, candle.min())
                    let price = CandleModel(candle: candle, currency: self.currency)
                    return price
                }
                self.maxValue = maxValue
                self.minValue = minValue
                self.xAxisLabels = CandleChartModel.calculateXaxisValues(with: self.type, values: temp)
                self.candles = temp
                let xValues = Array(temp.map({ stock in
                    stock.stringtimeStamp
                }).reversed())
                self.xValues = xValues
                // scroll to last page
                let pointsOnScreen = CandleChartModel.visiblePointsOnScreen(type: self.type, valuesCount: temp.count)
                self.xScrollPosition = temp[pointsOnScreen - 1].stringtimeStamp
            } else {
                result.forEach { candle in
                    self.maxValue = max(self.maxValue, candle.max())
                    self.minValue = min(self.minValue, candle.min())
                    let newPrice = CandleModel(candle: candle, currency: self.currency)
                    if let index = self.candles.firstIndex(where: { price in
                        price.timestamp == newPrice.timestamp
                    }) {
                        self.candles.safeReplace(newPrice, at: index)
                    }
                }
            }
        }
    }
}
