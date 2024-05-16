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

extension View {
    func ifTrue(_ condition:Bool, apply:(AnyView) -> (AnyView)) -> AnyView {
        if condition {
            return apply(AnyView(self))
        }
        else {
            return AnyView(self)
        }
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
    mutating func safeReplace(_ newElement: Element, at index: Int) {
        if index >= 0 && index < self.count {
            self[index] = newElement
        } else {
            print("error during replace")
        }
    }
}
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
enum CandleType: CaseIterable, Identifiable {
    case minute, hour, day, week, month, year
    var id: Self { self }
    func toDxFeedValue() -> CandlePeriod {
        switch self {
        case .week:
            return CandlePeriod.valueOf(value: 1, type: .week)
        case .month:
            return CandlePeriod.valueOf(value: 1, type: .month)
        case .year:
            return CandlePeriod.valueOf(value: 1, type: .year)
        case .minute:
            return CandlePeriod.valueOf(value: 1, type: .minute)
        case .day:
            return CandlePeriod.valueOf(value: 1, type: .day)
        case .hour:
            return CandlePeriod.valueOf(value: 1, type: .hour)
        }
    }

    func calcualteStartDate() -> Date {
        switch self {
        case .minute:
            return Calendar.current.date(byAdding: .hour, value: -12, to: Date())!
        case .hour:
            return Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        case .day:
            return Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        case .week:
            return Calendar.current.date(byAdding: .year, value: -5, to: Date())!
        case .month:
            return Calendar.current.date(byAdding: .year, value: -10, to: Date())!
        case .year:
            return Date(timeIntervalSince1970: 0)

        }
    }

    func calculateRightShift() -> Int64 {
        switch self {
        case .minute:
            return 60 * 1000
        case .hour:
            return 60 * 60 * 1000
        case .day:
            return 24 * 60 * 60 * 1000
        case .week:
            return 7 * 24 * 60 * 60 * 1000
        case .month:
            return 30 * 24 * 60 * 60 * 1000
        case .year:
            return 365 * 24 * 60 * 60 * 1000
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
    
    init(currency: String, timestamp: Date, open: Decimal, close: Decimal, high: Decimal, low: Decimal) {
        self.currency = currency
        self.timestamp = timestamp
        self.open = open
        self.close = close
        self.high = high
        self.low = low
    }

    init(candle: Candle, currency: String) {
        self.init(currency: currency,
                  timestamp: Date(millisecondsSince1970: candle.time),
                  open: Decimal(candle.open),
                  close: Decimal(candle.close),
                  high: Decimal(candle.high),
                  low: Decimal(candle.low))
    }

}

class CandleList: ObservableObject, SnapshotDelegate {
    func receiveEvents(_ events: [DXFeedFramework.MarketEvent], isSnapshot: Bool) {

        var result = [Candle]()
        events.forEach { event in
            let candle = event.candle
            result.append(candle)
        }
        DispatchQueue.main.async{
            if isSnapshot {
                self.loadingInProgress = false
                print("received snapshot \(Date())")
                var maxValue = Double.zero
                var minValue = Double.greatestFiniteMagnitude
                
                var minDate: Int64 = Int64.max
                var maxDate: Int64 = 0

                var temp = result.map({ candle in
                    let time = candle.time
                    minDate = min(minDate, time)
                    maxDate = max(maxDate, time)
                    maxValue = max(maxValue, candle.max())
                    minValue = min(minValue, candle.min())
                    let price = StockPrice(candle: candle, currency: self.currency)
                    return price
                })

                self.maxValue = maxValue
                self.minValue = minValue
                self.maxDate = Date(millisecondsSince1970: maxDate + self.type.calculateRightShift())
                self.minDate = Date(millisecondsSince1970: minDate)
                self.candles = temp
                self.xScrollPosition = temp.first!.timestamp
                print("use \(self.xScrollPosition) \(temp[30])")
                print("Loaded \(self.type) \(temp.count) \(self.minDate) \(self.maxDate)  \(self.minValue) \(self.maxValue)")
            } else {
                result.forEach { candle in
                    self.maxValue = max(self.maxValue, candle.max())
                    self.minValue = min(self.minValue, candle.min())
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
    @Published var xScrollPosition: Date = Date()

    var maxValue: Double = 0
    var minValue: Double = Double.greatestFiniteMagnitude
    
    var minDate = Date.now
    var maxDate = Date.now

    var loadingInProgress = false

    init(symbol: String, endpoint: DXEndpoint?) {
        self.symbol = symbol
        self.candles = [StockPrice]()
        try? createSubscription(endpoint: endpoint)
        fetchInfo()
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

    func fetchInfo() {
        DispatchQueue.global(qos: .background).async {
            let reader = DXInstrumentProfileReader()
            let address = "https://demo:demo@tools.dxfeed.com/ipf?SYMBOL=\(self.symbol)"
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
    var type = CandleType.year
    func updateDate(type: CandleType) {
        print("start load \(Date()) \(type)")
        loadingInProgress = true
        self.type = type
        let date = type.calcualteStartDate()
        candles = [StockPrice]()
        let candleSymbol = CandleSymbol.valueOf(symbol, type.toDxFeedValue())
        let symbol = TimeSeriesSubscriptionSymbol(symbol: candleSymbol, date: date)
        try? subscription?.setSymbols([symbol])
    }
}

struct CandleStickChart: View {
    @ObservedObject var list: CandleList
    @State private var selectedPrice: StockPrice?
    @State private var type: CandleType = .week



    let dateFormatter: DateFormatter
    let shortDateFormatter: DateFormatter
    let hourDateFormatter: DateFormatter

    let symbol: String
    let xAxisCountPerScreen = 4

    init(symbol: String, type: CandleType = .week, date: Date? = nil, endpoint: DXEndpoint?) {

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"

        shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "MM.yyyy"
        hourDateFormatter = DateFormatter()
        hourDateFormatter.dateStyle = .none
        hourDateFormatter.timeStyle = .short

        self.symbol = symbol
        self.list = CandleList(symbol: symbol, endpoint: endpoint)
        _type = State(initialValue: type)
    }

    var body: some View {
        GeometryReader { reader in
            List {
                Section {
                    chart.frame(height: max(reader.size.height/2, 300))
                }.listRowBackground(Color.sectionBackground)

                Section("Chart parameters") {
                    Picker("Candle type", selection: $type) {
                        ForEach(CandleType.allCases, id: \.self) { category in
                            Text(String(describing: category).capitalized).tag(category)
                        }
                    }.onChange(of: type) { value in
                        selectedPrice = nil
                        list.updateDate(type: value)
                    }
                    .foregroundStyle(Color.labelText)
                }.listRowSeparator(.hidden)
                    .listRowBackground(Color.sectionBackground)
            }
            .preferredColorScheme(.dark)
            .background(Color.viewBackground)
            .scrollContentBackground(.hidden)
            .onAppear {
                self.list.updateDate(type: self.type)                
            }
        }
    }
    
    func getYScale() -> ScaleDomain {
        if list.candles.count == 0 {
            return 0...0
        }
        if type == .minute {
            return list.minValue...list.maxValue
        } else {
            return (list.minValue*0.95)...list.maxValue*1.05
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
            .accessibilityLabel("""
\(price.timestamp.formatted(date: .complete, time: .omitted)): \(price.accessibilityTrendSummary)
""")
            .accessibilityValue(price.accessibilityDescription)
            .accessibilityHidden(false)
            .foregroundStyle( price.isClosingHigher ? .green : .red)
        }
        .chartYAxis { AxisMarks(preset: .extended) }
        .chartYScale(domain: getYScale())
        .chartXScale(domain: [list.minDate, list.maxDate])
        .chartXAxis {
            if list.loadingInProgress {
            } else {
                let _ = print("load axis")
                var numberOfItems = list.candles.count
                let xAxisValues = calculateXaxisValues(firstValue: list.minDate, with: type, valuesCount: numberOfItems)
                AxisMarks(values: xAxisValues) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel(horizontalSpacing: -14, verticalSpacing: 10) {
                            switch type {
                            case .year:
                                Text(shortDateFormatter.string(from: date))
                            case .minute:
                                Text(hourDateFormatter.string(from: date))
                            default:
                                Text(dateFormatter.string(from: date))
                            }
                        }
                    }
                    AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.5))
                    AxisTick(centered: true, length: 0, stroke: .none)
                }
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
                                        selectedPrice = findElement(location: value.location,
                                                                    proxy: proxy,
                                                                    geometry: geo)
                                    }
                            )
                    )
            }
        }
        .chartOverlay { proxy in
            ZStack(alignment: .topLeading) {
                GeometryReader { geo in
                    if let selectedPrice {
                        let dateInterval = Calendar.current.dateInterval(of: .minute, for: selectedPrice.timestamp)!
                        let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0

                        let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
                        let lineHeight = geo[proxy.plotAreaFrame].maxY
                        let boxWidth: CGFloat = min(geo.size.width, 400)
                        let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))

                        Rectangle()
                            .fill(.gray.opacity(0.5))
                            .frame(width: 2, height: lineHeight)
                            .position(x: lineX, y: lineHeight / 2)

                        CandleInfoView(for: selectedPrice, currency: list.currency)
                            .frame(width: boxWidth, alignment: .leading)
                            .background {
                                RoundedRectangle(cornerRadius: 13)
                                    .fill(Color.infoBackground)
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
        .ifTrue(true, apply: { anyView in
            if #available(iOS 17.0, *) {
                AnyView(
                    anyView.chartScrollableAxes(.horizontal)
                        .chartScrollPosition(x: $list.xScrollPosition)
                        .chartXVisibleDomain(length: visibleDomains(type: type, valuesCount: list.candles.count)))

            } else {
                anyView
            }
        })
        .accessibilityChartDescriptor(self)
    }

    func calculateXaxisValues(firstValue: Date, with type: CandleType, valuesCount: Int) -> [Date] {
        var visiblePages: Double = 1
        if #available(iOS 17.0, *) {
            let pointsOnScreen = visiblePointsOnScreen(type: type, valuesCount: valuesCount)
            visiblePages = Double(valuesCount)/Double(pointsOnScreen)
        }
        var values = [Date]()
        let endDate = list.maxDate
        let delta = endDate.distance(to: firstValue)
        let maxInterval = Int(visiblePages.isNaN ? 1 : visiblePages) * xAxisCountPerScreen
        for index in 0...maxInterval {
            let value = endDate.addingTimeInterval(TimeInterval(index) * delta / TimeInterval(maxInterval))
            values.append(value)
        }
        return values
    }

    private func visiblePointsOnScreen(type: CandleType, valuesCount: Int) -> Int {
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

    private func visibleDomains(type: CandleType, valuesCount: Int) -> Int {
        if valuesCount == 0 {
            return 1
        }
        let pointsOnScreen = visiblePointsOnScreen(type: type, valuesCount: valuesCount)
        let minuteDuration = 60
        let hourDuration = 3600
        let dayDuration = hourDuration * 24
        switch type {
        case .month:
            return dayDuration * 30 * pointsOnScreen
        case .week:
            return dayDuration * 7 * pointsOnScreen
        case .year:
            return dayDuration * 365 * pointsOnScreen
        case .minute:
            return dayDuration / 48
        case .day:
            return dayDuration * 1 * pointsOnScreen
        case .hour:
            return hourDuration * 1 * pointsOnScreen
        }
    }

    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> StockPrice? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var index: Int?
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
    func createLowest() -> ((KeyPath<StockPrice, Decimal>) -> (Double)) {
        { path in
            return list.candles.map { $0[keyPath: path]} .min()?.asDouble ?? 0
        }
    }
    func createHighest() -> ((KeyPath<StockPrice, Decimal>) -> (Double)) {

        { path in
            return list.candles.map { $0[keyPath: path]} .max()?.asDouble ?? 0
        }
    }
    func makeChartDescriptor() -> AXChartDescriptor {
        let dateStringConverter: ((Date) -> (String)) = { date in
            date.formatted(date: .abbreviated, time: .omitted)
        }
        // These closures help find the min/max for each axis
        let lowestValue = createLowest()
        let highestValue = createHighest()
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
            Text(price.timestamp.formatted(date: .abbreviated, time: .shortened))
            HStack(spacing: 10) {
                Text("Open: \(price.open.formatted(.currency(code: currency)))")
                    .foregroundColor(.secondary)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .minimumScaleFactor(0.01)
                Text("Close: \(price.close.formatted(.currency(code: currency)))")
                    .foregroundColor(.secondary)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .minimumScaleFactor(0.01)
            }
            HStack(spacing: 10) {
                Text("High: \(price.high.formatted(.currency(code: currency)))")
                    .foregroundColor(.secondary)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .minimumScaleFactor(0.01)
                Text("Low: \(price.low.formatted(.currency(code: currency)))")
                    .foregroundColor(.secondary)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .minimumScaleFactor(0.01)
            }
        }
        .lineLimit(1)
        .font(.headline)
        .padding(.vertical)
    }

}
