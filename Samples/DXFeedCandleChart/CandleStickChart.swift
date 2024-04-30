//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import SwiftUI
import Charts
import DXFeedFramework

enum Constants {
    static let previewChartHeight: CGFloat = 100
}

extension Decimal {
    var asDouble: Double { Double(truncating: self as NSNumber) }
}

extension StockPrice {
    
    var isClosingHigher: Bool {
        self.open < self.close
    }

    var accessibilityTrendSummary: String {
        "Price movement: \(isClosingHigher ? "up" : "down")"
    }

    var accessibilityDescription: String {
        return "Open: \(self.open.formatted(.currency(code: currency))), Close: \(self.close.formatted(.currency(code: currency))), High: \(self.high.formatted(.currency(code: currency))), Low: \(self.low.formatted(.currency(code: currency)))"
    }
}

extension Array {
  mutating func safeReplace(_ newElement: Element, at:Int) {
      if at >= 0 && at < self.count {
          self[at] = newElement
      } else {
          print("error during replace")
      }
  }
}

enum CandleType: CaseIterable, Identifiable {
    case week, month, year
    var id: Self { self }
    func toDxFeedValue() -> CandlePeriod {
        switch self {
        case .week:
            return CandlePeriod.valueOf(value: 1, type: .week)
        case .month:
            return CandlePeriod.valueOf(value: 1, type: .month)
        case .year:
            return CandlePeriod.valueOf(value: 1, type: .year)
        }
    }
}

struct StockPrice: Identifiable {
    let timestamp: Date
    let open: Decimal
    let high: Decimal
    let low: Decimal
    let close: Decimal
    let currency: String
    var id: Date { timestamp }
}


class CandleList: ObservableObject, SnapshotDelegate {
    func receiveEvents(_ events: [DXFeedFramework.MarketEvent], isSnapshot: Bool) {

        var result = [Candle]()
        events.forEach { event in
            let candle = event.candle
            result.append(candle)
        }
        if isSnapshot {
            DispatchQueue.main.async {
                self.candles = result.map({ candle in
                    let price = StockPrice(timestamp: Date(millisecondsSince1970: candle.time), open: Decimal(candle.open), high: Decimal(candle.high), low: Decimal(candle.low), close: Decimal(candle.close), currency: self.currency)
                    return price
                })
            }

        } else {
            DispatchQueue.main.async {
                result.forEach { candle in
                    let newPrice = StockPrice(timestamp: Date(millisecondsSince1970: candle.time), open: Decimal(candle.open), high: Decimal(candle.high), low: Decimal(candle.low), close: Decimal(candle.close), currency: self.currency)
                    if let index = self.candles.firstIndex(where: { price in
                        price.timestamp == newPrice.timestamp
                    }) {
                        self.candles.safeReplace(newPrice, at: index)
                    }
                }
            }
        }
    }

    let symbol: String = "AAPL"
    public private(set) var currency = ""
    public private(set) var descriptionString = ""

    var endpoint: DXEndpoint!
    var feed: DXFeed!
    var subscription: DXFeedSubscription?
    var snapshotProcessor: SnapshotProcessor!
    
    @Published var candles: [StockPrice]

    init() {
        self.candles = [StockPrice]()
        try? createSubscription()
        fetchInfo()
    }

    func createSubscription() throws {
        endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        feed = endpoint.getFeed()
        subscription = try feed?.createSubscription([Candle.self])
        snapshotProcessor = SnapshotProcessor()
        snapshotProcessor.add(self)
        try subscription?.add(listener: snapshotProcessor)
    }

    func fetchInfo() {
        let reader = DXInstrumentProfileReader()
        let result = try? reader.readFromFile(address: "https://demo:demo@tools.dxfeed.com/ipf?SYMBOL=\(symbol)")
        guard let result = result  else {
            return
        }
        result.forEach { profile in
            currency = profile.currency
            descriptionString = profile.descriptionStr
        }
    }

    func updateDate(date: Date, type: CandleType) {
        let candleSymbol = CandleSymbol.valueOf(symbol, type.toDxFeedValue())
        let symbol = TimeSeriesSubscriptionSymbol(symbol: candleSymbol, date: date)
        try? subscription?.setSymbols([symbol])
    }
}

struct CandleStickChart: View {
    @ObservedObject var list: CandleList
    @State private var selectedPrice: StockPrice?
    @State private var date = Calendar.current.date(byAdding: .month, value: -12, to: Date())!
    @State private var type: CandleType = .month

    init() {
        self.list = CandleList()
        self.list.updateDate(date: self.date, type: self.type)
    }

    var body: some View {
        GeometryReader { reader in
            List {
                Section {
                    DatePicker(
                           "Start Date",
                           selection: $date,
                           displayedComponents: [.date]
                    ).onChange(of: date) { oldValue, newValue in
                        selectedPrice = nil
                        list.updateDate(date: newValue,type: type)
                    }
                    Picker("Type", selection: $type) {
                        Text("Week").tag(CandleType.week)
                        Text("Month").tag(CandleType.month)
                        Text("Year").tag(CandleType.year)
                    }.onChange(of: type) { oldValue, newValue in
                        selectedPrice = nil
                        list.updateDate(date: date, type: newValue)
                    }
                }
                Section {
                    chart.frame(height: reader.size.height/2)
                }
                Section {
                    Text("""
Candles \(String(describing: type))
\(list.descriptionString)
from \(date)
""" )
                        .font(.callout)
                }
            }
        }
    }
    private var chart: some View {
            Chart($list.candles) { binding in
                let price = binding.wrappedValue

                CandleStickMark(
                    timestamp: .value("Date", price.timestamp),
                    open: .value("Open", price.open),
                    high: .value("High", price.high),
                    low: .value("Low", price.low),
                    close: .value("Close", price.close)
                )
                .accessibilityLabel("\(price.timestamp.formatted(date: .complete, time: .omitted)): \(price.accessibilityTrendSummary)")
                .accessibilityValue(price.accessibilityDescription)
                .accessibilityHidden(false)
                .foregroundStyle( price.close >= price.open ? .green : .red)
            }
            .chartYAxis { AxisMarks(preset: .extended) }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    let element = findElement(location: value.location, proxy: proxy, geometry: geo)
                                    if selectedPrice?.timestamp == element?.timestamp {
                                        // If tapping the same element, clear the selection.
                                        selectedPrice = nil
                                    } else {
                                        selectedPrice = element
                                    }
                                }
                                .exclusively(
                                    before: DragGesture()
                                        .onChanged { value in
                                            selectedPrice = findElement(location: value.location, proxy: proxy, geometry: geo)
                                        }
                                )
                        )
                }
            }
            .chartOverlay { proxy in
                ZStack(alignment: .topLeading) {
                    GeometryReader { geo in
                        if let selectedPrice {
                            let dateInterval = Calendar.current.dateInterval(of: .day, for: selectedPrice.timestamp)!
                            let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0

                            let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
                            let lineHeight = geo[proxy.plotAreaFrame].maxY
                            let boxWidth: CGFloat = geo.size.width
                            let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))

                            Rectangle()
                                .fill(.gray.opacity(0.5))
                                .frame(width: 2, height: lineHeight)
                                .position(x: lineX, y: lineHeight / 2)

                            PriceAnnotation(for: selectedPrice, currency: list.currency)
                                .frame(width: boxWidth, alignment: .leading)
                                .background {
                                    RoundedRectangle(cornerRadius: 13)
                                        .foregroundStyle(.thickMaterial)
                                        .padding(.horizontal, -8)
                                        .padding(.vertical, -4)
                                }
                                .offset(x: boxOffset)
                                .gesture(
                                    TapGesture()
                                        .onEnded { _ in
                                            self.selectedPrice = nil
                                        }
                                )
                        }
                    }
                }
            }
            .accessibilityChartDescriptor(self)
            .chartYAxis(.automatic)
            .chartXAxis(.automatic)

    }

    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> StockPrice? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var index: Int? = nil
            for dataIndex in list.candles.indices {
                let nthSalesDataDistance = list.candles[dataIndex].timestamp.distance(to: date)
                if abs(nthSalesDataDistance) < minDistance {
                    minDistance = abs(nthSalesDataDistance)
                    index = dataIndex
                }
            }
            if let index {
                return list.candles[index]
            }
        }
        return nil
    }
}

struct CandleStickMark: ChartContent {
    let timestamp: PlottableValue<Date>
    let open: PlottableValue<Decimal>
    let high: PlottableValue<Decimal>
    let low: PlottableValue<Decimal>
    let close: PlottableValue<Decimal>

    var body: some ChartContent {
        Plot {
            // Composite ChartContent MUST be grouped into a plot for accessibility to work
            BarMark(
                x: timestamp,
                yStart: open,
                yEnd: close,
                width: 4
            )
            BarMark(
                x: timestamp,
                yStart: high,
                yEnd: low,
                width: 1
            )
        }
    }
}

// MARK: - Accessibility

extension CandleStickChart: AXChartDescriptorRepresentable {
    func makeChartDescriptor() -> AXChartDescriptor {

        let dateStringConverter: ((Date) -> (String)) = { date in
            date.formatted(date: .abbreviated, time: .omitted)
        }

        // These closures help find the min/max for each axis
        let lowestValue: ((KeyPath<StockPrice, Decimal>) -> (Double)) = { path in
            return list.candles.map { $0[keyPath: path]} .min()?.asDouble ?? 0
        }
        let highestValue: ((KeyPath<StockPrice, Decimal>) -> (Double)) = { path in
            return list.candles.map { $0[keyPath: path]} .max()?.asDouble ?? 0
        }

        let xAxis = AXCategoricalDataAxisDescriptor(
            title: "Date",
            categoryOrder: list.candles.map { dateStringConverter($0.timestamp) }
        )

        // Add axes for each data point captured in the candlestick
        let closeAxis = AXNumericDataAxisDescriptor(
            title: "Closing Price",
            range: 0...highestValue(\.close),
            gridlinePositions: []
        ) { value in "Closing: \(value.formatted(.currency(code: list.currency)))" }

        let openAxis = AXNumericDataAxisDescriptor(
            title: "Opening Price",
            range: lowestValue(\.open)...highestValue(\.open),
            gridlinePositions: []
        ) { value in "Opening: \(value.formatted(.currency(code: list.currency)))" }

        let highAxis = AXNumericDataAxisDescriptor(
            title: "Highest Price",
            range: lowestValue(\.high)...highestValue(\.high),
            gridlinePositions: []
        ) { value in "High: \(value.formatted(.currency(code: list.currency)))" }

        let lowAxis = AXNumericDataAxisDescriptor(
            title: "Lowest Price",
            range: lowestValue(\.low)...highestValue(\.low),
            gridlinePositions: []
        ) { value in "Low: \(value.formatted(.currency(code: list.currency)))" }

        let series = AXDataSeriesDescriptor(
            name: list.descriptionString,
            isContinuous: false,
            dataPoints: list.candles.map {
                .init(x: dateStringConverter($0.timestamp),
                      y: $0.close.asDouble,
                      additionalValues: [.number($0.open.asDouble),
                                         .number($0.high.asDouble),
                                         .number($0.low.asDouble)])
            }
        )

        return AXChartDescriptor(
            title: list.descriptionString,
            summary: nil,
            xAxis: xAxis,
            yAxis: closeAxis,
            additionalAxes: [openAxis, highAxis, lowAxis],
            series: [series]
        )
    }
}

// MARK: - Preview

struct PriceAnnotation: View {
    let price: StockPrice
    let currency: String

    init(for price: StockPrice, currency: String) {
        self.price = price
        self.currency = currency
    }

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(price.timestamp.formatted(date: .abbreviated, time: .omitted))

            HStack(spacing: 0) {
                Text("Open: \(price.open.formatted(.currency(code: currency)))" ).foregroundColor(.secondary)                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                Text("Close: \(price.close.formatted(.currency(code: currency)))").foregroundColor(.secondary)                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

            }

            HStack(spacing: 0) {
                Text("High: \(price.high.formatted(.currency(code: currency)))").foregroundColor(.secondary)                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                Text("Low: \(price.low.formatted(.currency(code: currency)))").foregroundColor(.secondary)                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

            }
        }
        .lineLimit(1)
        .font(.headline)
        .padding(.vertical)
    }
}

struct CandleStickChart_Previews: PreviewProvider {
    static var previews: some View {
        CandleStickChart()
    }
}
