//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

/// A collection of classes for mapping unmanaged native events dxfg_event_type_t
class EventMapper: Mapper {
    typealias TypeAlias = dxfg_event_type_t
    var type: dxfg_event_type_t.Type

    init() {
        self.type = dxfg_event_type_t.self
    }

    private let mappers: [EventCode: any Mapper] = [.quote: QuoteMapper(),
                                                    .timeAndSale: TimeAndSaleMapper(),
                                                    .profile: ProfileMapper(),
                                                    .trade: TradeMapper(),
                                                    .tradeETH: TradeETHMapper(),
                                                    .candle: CandleMapper(),
                                                    .summary: SummaryMapper(),
                                                    .greeks: GreeksMapper(),
                                                    .underlying: UnderlyingMapper(),
                                                    .theoPrice: TheoPriceMapper(),
                                                    .order: OrderMapper(),
                                                    .analyticOrder: AnalyticOrderMapper(),
                                                    .spreadOrder: SpreadOrderMapper(),
                                                    .series: SeriesMapper(),
                                                    .optionSale: OptionSaleMapper(),
                                                    .otcMarketsOrder: OtcMarketsOrderMapper()]

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) throws -> MarketEvent? {
        let code = try EnumUtil.valueOf(value: EventCode.convert(native.pointee.clazz))
        if let mapper = mappers[code] {
            return try mapper.fromNative(native: native)
        }
        return nil
    }

    func toNative(event: MarketEvent) throws -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let code = event.type
        if let mapper = mappers[code] {
            let native = try mapper.toNative(event: event)
            return native
        }
        return nil
    }

    func releaseNative(native: UnsafeMutablePointer<dxfg_event_type_t>) {
        if let code = try? EnumUtil.valueOf(value: EventCode.convert(native.pointee.clazz)) {
            if let mapper = mappers[code] {
                mapper.releaseNative(native: native)
            }
        }
    }
}
