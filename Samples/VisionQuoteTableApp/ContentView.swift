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
    private let symbols = ["AAPL", "IBM", "MSFT", "EUR/CAD", "ETH/USD:GDAX", "GOOG", "BAC", "CSCO", "ABCE", "INTC", "PFE"]
    @ObservedObject var datasource: DataSource

    init() {
        self.datasource = DataSource(symbols: symbols)
        self.endpoint.addDataSource(self.datasource)
    }
    var body: some View {
        VStack {
            List(datasource.quotes) { quote in
                Text(quote.title)
            }
            Spacer()
            Text(endpoint.state.convetToString()).onAppear {
                endpoint.subscribe(address: "demo.dxfeed.com:7300", symbols: symbols)

            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 30).padding(.bottom, 20)

        }
    }
}

#Preview {
    ContentView()
}
