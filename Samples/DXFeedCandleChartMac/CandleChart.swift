//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import SwiftUI
import Charts
import DXFeedFramework

extension View {
    func execute(_ apply: (AnyView) -> (AnyView)) -> AnyView {
        return apply(AnyView(self))
    }
}

enum CandlePickerType: CaseIterable, Identifiable {
    case minute, hour, day, week, month, year
    var id: Self { self }
}

struct CandleModel: Identifiable {
    let currency: String
    let timestamp: Date
    var id: Date { timestamp }

    let open: Decimal
    let close: Decimal
    let high: Decimal
    let low: Decimal

    let isPoint: Bool
    let stringtimeStamp: String

    init(currency: String, timestamp: Date, open: Decimal, close: Decimal, high: Decimal, low: Decimal) {
        self.currency = currency
        self.timestamp = timestamp
        self.open = open
        self.close = close
        self.isPoint = open == close && high == low
        self.high = high
        self.low = low
        self.stringtimeStamp = "\(timestamp.timeIntervalSince1970)"
    }

    init(candle: Candle, currency: String) {
        self.init(currency: currency,
                  timestamp: Date(millisecondsSince1970: candle.time),
                  open: Decimal(candle.open),
                  close: Decimal(candle.close),
                  high: Decimal(candle.high),
                  low: Decimal(candle.low))
    }

    var isClosingHigher: Bool {
        self.open <= self.close
    }

}

struct CandleChart: View {
    @ObservedObject var list: CandleChartModel
    @State private var selectedPrice: CandleModel?
    @State private var type: CandlePickerType = .week

    let dateFormatter: DateFormatter
    let shortDateFormatter: DateFormatter
    let hourDateFormatter: DateFormatter

    init(symbol: String,
         type: CandlePickerType = .week,
         endpoint: DXEndpoint?,
         ipfAddress: String) {

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"

        shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "MM.yyyy"
        hourDateFormatter = DateFormatter()
        hourDateFormatter.dateStyle = .none
        hourDateFormatter.timeStyle = .short

        self.list = CandleChartModel(symbol: symbol,
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
                        ForEach(CandlePickerType.allCases, id: \.self) { category in
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

    private var chart: some View {
        Chart($list.candles) { binding in
            let price = binding.wrappedValue

            CandlePlot(
                timestamp: .value("Date", price.stringtimeStamp),
                open: .value("Open", price.open),
                high: .value("High", price.high),
                low: .value("Low", price.low),
                close: .value("Close", price.close),
                isPoint: price.isPoint
            )
            .foregroundStyle( price.isClosingHigher ? .green : .red)
        }
        .chartXScale(domain: .automatic(dataType: String.self) { dates in
            dates = list.xValues
        })
        .chartYScale(domain: list.yScale())
        .chartYAxis { AxisMarks(preset: .extended) }
        .chartXAxis {
            if list.loadingInProgress {
            } else {
                let xAxisValues = self.list.xAxisLabels
                AxisMarks(preset: .aligned, values: xAxisValues) { value in
                    if let strDate = value.as(String.self) {
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
        .execute { view in
#if os(iOS)
            if #available(iOS 17.0, *) {
                return AnyView(view
                    .chartScrollableAxes(.horizontal)
                    .chartXVisibleDomain(length: list.visibleDomains())
                    .chartScrollPosition(x: $list.xScrollPosition))
            }
#endif
            return view
        }
    }

    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> CandleModel? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as String?, let timeInterval = TimeInterval(date) {
            // Find the closest date element.
            let date = Date(timeIntervalSince1970: timeInterval)
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

struct CandlePlot: ChartContent {
    let timestamp: PlottableValue<String>
    let open: PlottableValue<Decimal>
    let high: PlottableValue<Decimal>
    let low: PlottableValue<Decimal>
    let close: PlottableValue<Decimal>
    let isPoint: Bool

    var body: some ChartContent {
        Plot {
            if isPoint {
                PointMark(x: timestamp,
                          y: open)
                .symbolSize(CandlePlot.openCloseWidth)
            } else {
                BarMark(
                    x: timestamp,
                    yStart: open,
                    yEnd: close,
                    width: MarkDimension(floatLiteral: CandlePlot.openCloseWidth)
                )
                BarMark(
                    x: timestamp,
                    yStart: high,
                    yEnd: low,
                    width: MarkDimension(floatLiteral: CandlePlot.highLowWidth)
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

// MARK: - Info View with Prices
struct CandleInfoView: View {
    let price: CandleModel
    let currency: String

    init(for price: CandleModel, currency: String) {
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
