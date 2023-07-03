//
//  QuoteView.swift
//  VisionQuoteTableApp
//
//  Created by Aleksey Kosylo on 30.06.23.
//

import SwiftUI

struct QuoteView: View {
    @ObservedObject var item: QuoteViewModel

    var body: some View {
        GeometryReader { metrics in
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
        }
    }
}

#Preview {
    QuoteView(item: QuoteViewModel(symbol: "APPL"))
}
