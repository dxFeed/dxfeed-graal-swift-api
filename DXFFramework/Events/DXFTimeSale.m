//
//  DXFTimeSale.m
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#import "DXFTimeSale.h"
#import "dxfg_events.h"
#import "DXFTimeSale+Private.h"
#import "DXFEvent+Private.h"
#import "NSString+CString.h"

@implementation DXFTimeSale

- (instancetype)initWithItem:(dxfg_event_type_t *)item {
    dxfg_time_and_sale_t *dxf_item = (dxfg_time_and_sale_t *)item;
    if (self = [super initWithMarketEvent:dxf_item->market_event]) {
        _event_flags = dxf_item->event_flags;
        _index = dxf_item->index;
        _time_nano_part = dxf_item->time_nano_part;
        _exchange_code = dxf_item->exchange_code;
        _price = dxf_item->price;
        _size = dxf_item->size;
        _bid_price = dxf_item->bid_price;
        _ask_price = dxf_item->ask_price;
        _exchange_sale_conditions = [NSString newWithCstring:dxf_item->exchange_sale_conditions];
        _flags = dxf_item->flags;
        _buyer = [NSString newWithCstring:dxf_item->buyer];
        _seller = [NSString newWithCstring:dxf_item->seller];
    }
    return self;
}

- (NSString *)description {
    return [[NSString alloc] initWithFormat:@"DXFG_TIME_AND_SALE_T: %@  event_flags=%d, index=%lld, time_nano_part=%d, exchange_code=%hd, price=%f, size=%f, bid_price=%f, ask_price=%f, exchange_sale_conditions=%@, flags=%d, buyer=%@, seller=%@", self.event_symbol,self.event_flags,self.index,self.time_nano_part,self.exchange_code,self.price,self.size,self.bid_price,self.ask_price,self.exchange_sale_conditions,self.flags,self.buyer,self.seller];
}

@end
