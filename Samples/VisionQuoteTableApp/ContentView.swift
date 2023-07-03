//
//  ContentView.swift
//  VisionQuoteTableApp
//
//  Created by Aleksey Kosylo on 29.06.23.
//

import SwiftUI
import RealityKit
import RealityKitContent
import DxFeedSwiftFramework

struct ContentView: View {
    @ObservedObject var endpoint = Endpoint()
    private let symbols = ["AAPL",
                           "IBM",
                           "MSFT",
                           "EUR/CAD",
                           "ETH/USD:GDAX",
                           "GOOG",
                           "BAC",
                           "CSCO",
                           "ABCE",
                           "INTC",
                           "PFE"]
    @ObservedObject var datasource: DataSource
    private let cellHeight: CGFloat = 70

    init() {
        datasource = DataSource(symbols: symbols)
        endpoint.addDataSource(datasource)
        endpoint.subscribe(address: "demo.dxfeed.com:7300", symbols: symbols)
    }
    var body: some View {
        VStack {
            GeometryReader { _ in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        Spacer().frame(height: 20)
                        ForEach(datasource.quotes) { item in
                           QuoteView(item: item).frame(height: cellHeight)
                        }
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
            }
            Spacer()
            Text(endpoint.state.convetToString()).frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 30).padding(.bottom, 20)
        }
        .background(Color(UIColor.tableBackground))
    }
}

#Preview {
    ContentView()
}
