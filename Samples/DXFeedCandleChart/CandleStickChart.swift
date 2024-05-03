//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import SwiftUI
import Charts
import DXFeedFramework

extension Decimal {
    var asDouble: Double { Double(truncating: self as NSNumber) }

    func formatted(currency: String) -> String {
        return self.formatted(.currency(code: currency))
    }
}

extension Double {
    func formatted(currency: String) -> String {
        return self.formatted(.currency(code: currency))
    }
}

extension StockPrice {

    var isClosingHigher: Bool {
        self.open <= self.close
    }

    var accessibilityTrendSummary: String {
        "Price movement: \(isClosingHigher ? "up" : "down")"
    }

    var accessibilityDescription: String {
        return """
Open: \(self.open.formatted(currency: currency)), \
Close: \(self.close.formatted(currency: currency)), \
High: \(self.high.formatted(currency: currency)), \
Low: \(self.low.formatted(currency: currency))
"""
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
    let currency: String
    let timestamp: Date
    var id: Date { timestamp }

    let open: Decimal
    let close: Decimal
    let high: Decimal
    let low: Decimal

    init(candle: Candle, currency: String) {
        self.currency = currency
        self.timestamp = Date(millisecondsSince1970: candle.time)
        self.open =  Decimal(candle.open)
        self.close = Decimal(candle.close)
        self.high = Decimal(candle.high)
        self.low = Decimal(candle.low)
    }

}


class CandleList: ObservableObject, SnapshotDelegate {
    func receiveEvents(_ events: [DXFeedFramework.MarketEvent], isSnapshot: Bool) {

        var result = [Candle]()
        events.forEach { event in
            let candle = event.candle
            result.append(candle)
        }
        DispatchQueue.main.async {
            if isSnapshot {
                self.candles = result.map({ candle in
                    let price = StockPrice(candle: candle, currency: self.currency)
                    return price
                })
            } else {
                result.forEach { candle in
                    let newPrice = StockPrice(candle: candle, currency: self.currency)
                    if let index = self.candles.firstIndex(where: { price in
                        price.timestamp == newPrice.timestamp
                    }) {
                        self.candles.safeReplace(newPrice, at: index)
                    }
                }
            }
        }
    }

    let symbol: String
    public private(set) var currency = ""
    public private(set) var descriptionString = ""

    var endpoint: DXEndpoint!
    var feed: DXFeed!
    var subscription: DXFeedSubscription?
    var snapshotProcessor: SnapshotProcessor!

    @Published var candles: [StockPrice]

    init(symbol: String) {
        self.symbol = symbol
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
    static let startDate = Calendar.current.date(byAdding: .month, value: -12, to: Date())!

    static func calculateXaxisValues(firstValue: Date) -> [Date] {
        var values = [Date]()
        let endDate = Date.now
        let delta = endDate.distance(to: firstValue)

        let maxInterval = 4
        for index in 0...maxInterval {
            let value = endDate.addingTimeInterval(TimeInterval(index) * delta / TimeInterval(maxInterval))
            values.append(value)
        }
        return values.reversed()
    }

    @ObservedObject var list: CandleList
    @State private var selectedPrice: StockPrice?
    @State private var date = startDate
    @State private var type: CandleType = .month
    @State var xAxisValues = CandleStickChart.calculateXaxisValues(firstValue: startDate)
    let dateFormatter: DateFormatter
    let symbol: String

    init(symbol: String) {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.none

        self.symbol = symbol
        self.list = CandleList(symbol: symbol)
        self.list.updateDate(date: self.date, type: self.type)

    }

    var body: some View {
        GeometryReader { reader in
            List {

                Section {
                    chart.frame(height: max(reader.size.height/2, 300))
                }.listRowBackground(Color.cellBackground)


                Section("Chart parameters") {
                    Picker("Candle type", selection: $type) {
                        ForEach(CandleType.allCases, id: \.self) { category in
                            Text(String(describing: category).capitalized).tag(category)
                        }
                    }.onChange(of: type) { oldValue, newValue in
                        selectedPrice = nil
                        list.updateDate(date: date, type: newValue)
                    }.pickerStyle(SegmentedPickerStyle())

                        .foregroundStyle(.text)
                    DatePicker(
                        selection: $date,
                        displayedComponents: [.date]
                    ) {
                        Text("Choose from time")
                    }.onChange(of: date) { _, newValue in
                        selectedPrice = nil
                        xAxisValues = CandleStickChart.calculateXaxisValues(firstValue: newValue)
                        list.updateDate(date: newValue, type: type)
                    }
                    .datePickerStyle(.compact)
                    .foregroundStyle(.text)

                }
                .listRowBackground(Color.cellBackground)
                .listRowSeparator(.hidden)
            }
            .preferredColorScheme(.dark)
            .background(.tableBackground)
            .scrollContentBackground(.hidden)

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
            .foregroundStyle( price.isClosingHigher ? .green : .red)
        }
        .chartYAxis { AxisMarks(preset: .extended) }
        .chartXAxis {
            AxisMarks(values: xAxisValues) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel(horizontalSpacing: -14, verticalSpacing: 10) {
                        VStack(alignment: .leading) {
                            Text(dateFormatter.string(from: date))
                        }
                    }
                }
                AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.5))
                AxisTick(centered: true, length: 0, stroke: .none)
            }
        }

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

                        CandleInfoView(for: selectedPrice, currency: list.currency)
                            .frame(width: boxWidth, alignment: .leading)
                            .background {
                                RoundedRectangle(cornerRadius: 13)
                                    .fill(Color.priceBackground)
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
        ) { value in "Closing: \(value.formatted(currency: list.currency)))" }

        let openAxis = AXNumericDataAxisDescriptor(
            title: "Opening Price",
            range: lowestValue(\.open)...highestValue(\.open),
            gridlinePositions: []
        ) { value in "Opening: \(value.formatted(currency: list.currency))" }

        let highAxis = AXNumericDataAxisDescriptor(
            title: "Highest Price",
            range: lowestValue(\.high)...highestValue(\.high),
            gridlinePositions: []
        ) { value in "High: \(value.formatted(currency: list.currency))" }

        let lowAxis = AXNumericDataAxisDescriptor(
            title: "Lowest Price",
            range: lowestValue(\.low)...highestValue(\.low),
            gridlinePositions: []
        ) { value in "Low: \(value.formatted(currency: list.currency))" }

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

// MARK: - Detail Info View about candle

struct CandleInfoView: View {
    let price: StockPrice
    let currency: String

    init(for price: StockPrice, currency: String) {
        self.price = price
        self.currency = currency
    }

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(price.timestamp.formatted(date: .abbreviated, time: .omitted))
            HStack(spacing: 10) {
                Text("Open: \(price.open.formatted(.currency(code: currency)))" ).foregroundColor(.secondary).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).minimumScaleFactor(0.01)
                Text("Close: \(price.close.formatted(.currency(code: currency)))").foregroundColor(.secondary).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).minimumScaleFactor(0.01)
            }
            HStack(spacing: 10) {
                Text("High: \(price.high.formatted(.currency(code: currency)))").foregroundColor(.secondary).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).minimumScaleFactor(0.01)
                Text("Low: \(price.low.formatted(.currency(code: currency)))").foregroundColor(.secondary).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).minimumScaleFactor(0.01)
            }
        }
        .lineLimit(1)
        .font(.headline)
        .padding(.vertical)
    }

}
