//
//  DXFEventQuote.m
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/5/23.
//

#import "DXFEventQuote.h"
#import "dxfg_events.h"
#import "DXFEventQuote+Private.h"
#import "DXFEvent+Private.h"

@implementation DXFEventQuote

- (void)dealloc {
}

- (instancetype)initWithItem:(dxfg_event_type_t *)item {
    dxfg_quote_t *dxf_item = (dxfg_quote_t *)item;
    if (self = [super initWithMarketEvent:dxf_item->market_event]) {
        self.time_millis_sequence = dxf_item->time_millis_sequence;
        self.time_nano_part = dxf_item->time_nano_part;
        self.bid_time = [NSDate dateWithTimeIntervalSince1970:dxf_item->bid_time/1000];
        self.bid_exchange_code = dxf_item->bid_exchange_code;
        self.bid_price = dxf_item->bid_price;
        self.bid_size = dxf_item->bid_size;
        self.ask_time = [NSDate dateWithTimeIntervalSince1970:dxf_item->ask_time/1000];
        self.ask_exchange_code = dxf_item->ask_exchange_code;
        self.ask_price = dxf_item->ask_price;
        self.ask_size = dxf_item->ask_size;
    }
    return self;
}

- (NSString *)description {
    return [[NSString alloc] initWithFormat:@"DXFG_QUOTE_T: %@  time_millis_sequence=%d, time_nano_part=%d, bid_time=%@, bid_exchange_code=%hd, bid_price=%f, bid_size=%f, ask_time=%@, ask_exchange_code=%hd, ask_price=%f, ask_size=%f", self.event_symbol,self.time_millis_sequence,self.time_nano_part,self.bid_time,self.bid_exchange_code,self.bid_price,self.bid_size,self.ask_time,self.ask_exchange_code,self.ask_price,self.ask_size];
}

@end
