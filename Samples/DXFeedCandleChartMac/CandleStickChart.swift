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
    func execute(_ apply: (AnyView) -> (AnyView)) -> AnyView {
        return apply(AnyView(self))
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
            return Calendar.current.date(byAdding: .day, value: -7, to: Date())!
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
    let isPoint: Bool

    init(currency: String, timestamp: Date, open: Decimal, close: Decimal, high: Decimal, low: Decimal) {
        self.currency = currency
        self.timestamp = timestamp
        self.open = open
        self.close = close
        self.isPoint = open == close && high == low
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
        DispatchQueue.main.async {
            if isSnapshot {
                self.loadingInProgress = false
                print("received snapshot \(Date())")
                var maxValue = Double.zero
                var minValue = Double.greatestFiniteMagnitude

                var minDate: Int64 = Int64.max
                var maxDate: Int64 = 0
                let firstNElements = result.prefix(150)
                let temp = firstNElements.map { candle in
                    let time = candle.time
                    minDate = min(minDate, time)
                    maxDate = max(maxDate, time)
                    maxValue = max(maxValue, candle.max())
                    minValue = min(minValue, candle.min())
                    let price = StockPrice(candle: candle, currency: self.currency)
                    return price
                }

                self.maxValue = maxValue
                self.minValue = minValue
                self.maxDate = Date(millisecondsSince1970: maxDate + self.type.calculateRightShift())
                self.minDate = Date(millisecondsSince1970: minDate - self.type.calculateRightShift())
                if temp.count > 30 {
                    self.xScrollPosition = "\(temp[29].timestamp.timeIntervalSince1970)"
                } else {
                    self.xScrollPosition = "\(temp.last!.timestamp.timeIntervalSince1970)"
                }
                self.xAxisLabels = self.calculateXaxisValues(with: self.type, values: temp)

                self.candles = temp
                self.xValues = temp.map({ stock in
                    "\(stock.timestamp.timeIntervalSince1970)"
                }).reversed()
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
    func calculateXaxisValues(with type: CandleType, values: [StockPrice]) -> [String] {
        var visiblePages: Double = 1
        let valuesCount = values.count
        if #available(iOS 17.0, *) {
            let pointsOnScreen = visiblePointsOnScreen(type: type, valuesCount: valuesCount)
            visiblePages = Double(valuesCount)/Double(pointsOnScreen)
        }
        var stringValues = [String]()

        // initial case, to avoid showing lines on empty screen
        if values.count == 0 {
            return [String]()
        }

        let maxInterval = Int(visiblePages.isNaN ? 1 : visiblePages) * 4
        for position in stride(from: 0, to: valuesCount, by: valuesCount / maxInterval) {
            stringValues.append("\(values[position].timestamp.timeIntervalSince1970)")
        }
        return stringValues
    }


    let symbol: String
    public private(set) var currency = ""
    public private(set) var descriptionString = ""

    var endpoint: DXEndpoint!
    var feed: DXFeed!
    var subscription: DXFeedSubscription?
    var snapshotProcessor: SnapshotProcessor!

    @Published var candles: [StockPrice]
    @Published var xScrollPosition: String = ""
    @Published var xAxisLabels = [String]()
    var xValues = [String]()

    var maxValue: Double = 0
    var minValue: Double = Double.greatestFiniteMagnitude

    var minDate: Date
    var maxDate: Date

    var loadingInProgress = false
    let ipfAddress: String
    init(symbol: String,
         endpoint: DXEndpoint?,
         ipfAddress: String) {
        self.ipfAddress = ipfAddress
        let startDate = Date.now
        minDate = startDate
        maxDate = startDate
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
            let address = self.ipfAddress + self.symbol
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

    func fakeLoading() {
        loadingInProgress = true
        self.xScrollPosition = "\(Calendar.current.date(byAdding: .day, value: -1, to: Date())!.timeIntervalSince1970)"
        loadingInProgress = false
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
    var xAxisValues: [String]?

    init(symbol: String,
         type: CandleType = .week,
         endpoint: DXEndpoint?,
         ipfAddress: String) {

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"

        shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "MM.yyyy"
        hourDateFormatter = DateFormatter()
        hourDateFormatter.dateStyle = .none
        hourDateFormatter.timeStyle = .short

        self.symbol = symbol
        self.list = CandleList(symbol: symbol, 
                               endpoint: endpoint,
                               ipfAddress: ipfAddress)
        _type = State(initialValue: type)
    }

    var body: some View {
        GeometryReader { reader in
            List {
                Section {
                    chart.frame(height: max(reader.size.height - 150, 300))
                        .onAppear {
                            // just workaround for swiftuicharts + scroll to
                            self.list.fakeLoading()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.selectedPrice = nil
                                self.list.updateDate(type: self.type)
                            }

                        }
                }
                .listRowBackground(Color.sectionBackground)
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
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.sectionBackground)
            }
            // fix for datepicker selected color
            .preferredColorScheme(.dark)
            .background(Color.viewBackground)
            .scrollContentBackground(.hidden)
        }
    }

    func getYScale() -> ClosedRange<Double> {
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
                timestamp: .value("Date", "\(price.timestamp.timeIntervalSince1970)"),
                open: .value("Open", price.open),
                high: .value("High", price.high),
                low: .value("Low", price.low),
                close: .value("Close", price.close),
                stockPrice: price
            )
            .accessibilityLabel("""
\(price.timestamp.formatted(date: .numeric, time: .omitted)): \(price.accessibilityTrendSummary)
""")
            .accessibilityValue(price.accessibilityDescription)
            .accessibilityHidden(false)
            .foregroundStyle( price.isClosingHigher ? .green : .red)
        }
        .chartXScale(domain: .automatic(dataType: String.self) { dates in
            dates = list.xValues
        })
        .chartYScale(domain: getYScale())
        .chartYAxis { AxisMarks(preset: .extended) }
        .chartXAxis {

            if list.loadingInProgress {

            } else {
                let xAxisValues = self.list.xAxisLabels
                AxisMarks(values: xAxisValues) { value in
                    if let strDate = value.as(String.self) {
                        if (strDate == xAxisValues.first!) {
                            // workaround, to avoid ... inctead of latest value(now)
                            AxisValueLabel("")
                        } else {
                            let date = Date(timeIntervalSince1970: TimeInterval(strDate) ?? 0)
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
                        let startPositionX1 = proxy.position(forX: "\(dateInterval.start.timeIntervalSince1970)") ?? 0

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
        .accessibilityChartDescriptor(self)
        .execute { view in
#if os(iOS)
            if #available(iOS 17.0, *) {
                return AnyView(view
                    .chartScrollableAxes(.horizontal)
                    .chartXVisibleDomain(length: visibleDomains(type: type, valuesCount: list.candles.count))
                    .chartScrollPosition(x: $list.xScrollPosition))
            }
#endif
            return view
        }
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
        return pointsOnScreen
    }

    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> StockPrice? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as String? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var index: Int?
            for dataIndex in list.candles.indices {
                let nthSalesDataDistance = list.candles[dataIndex].timestamp.distance(to: Date(timeIntervalSince1970: TimeInterval(date) ?? 0))
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
    let timestamp: PlottableValue<String>
    let open: PlottableValue<Decimal>
    let high: PlottableValue<Decimal>
    let low: PlottableValue<Decimal>
    let close: PlottableValue<Decimal>
    let stockPrice: StockPrice

    var body: some ChartContent {
        Plot {
            // Composite ChartContent MUST be grouped into a plot for accessibility to work
            if stockPrice.isPoint {
                PointMark(x: timestamp,
                          y: open).symbolSize(CandleStickMark.openCloseWidth)
            } else {
                BarMark(
                    x: timestamp,
                    yStart: open,
                    yEnd: close,
                    width: MarkDimension(floatLiteral: CandleStickMark.openCloseWidth)
                )
                BarMark(
                    x: timestamp,
                    yStart: high,
                    yEnd: low,
                    width: MarkDimension(floatLiteral: CandleStickMark.highLowWidth)
                )
            }
        }
    }

    static let openCloseWidth: CGFloat = {
        if #available(iOS 17, *) {
            return 6
        } else {
            return 4
        }
    }()

    static let highLowWidth: CGFloat = {
        if #available(iOS 17, *) {
            return 2
        } else {
            return 1
        }
    }()
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
            date.formatted(date: .numeric, time: .omitted)
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
            Text(price.timestamp.formatted(date: .numeric, time: .shortened))
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
