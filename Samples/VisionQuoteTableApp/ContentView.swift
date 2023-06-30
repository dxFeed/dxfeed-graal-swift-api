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
        self.datasource = DataSource(symbols: symbols)
        self.endpoint.addDataSource(self.datasource)
    }
    var body: some View {
        VStack {
            GeometryReader { metrics in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(datasource.quotes) { item in
                            HStack(spacing: 10) {
                                Text(item.title)
                                    .padding(.leading, 10)
                                    .frame(maxHeight: .infinity)
                                Spacer()

                                HStack(spacing: 2) {
                                    Text(item.bidPrice)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(Color(item.bidColor))

                                    Text(item.askPrice)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(Color(item.askColor))
                                }
                                .cornerRadius(10)
                                .padding(.top, 5)
                                .padding(.bottom, 5)
                                .frame(width: metrics.size.width * 0.4)
                            }
                            .padding(.trailing, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10).foregroundColor(.cellBackground)
                            )

                            .frame(height: cellHeight)
                        }
                    }
                }.padding(.top, 20)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            }
            Spacer()
            Text(endpoint.state.convetToString()).onAppear {
                endpoint.subscribe(address: "demo.dxfeed.com:7300", symbols: symbols)

            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 30).padding(.bottom, 20)

        }
        .background(Color(UIColor.tableBackground))
    }
}

#Preview {
    ContentView()
}
