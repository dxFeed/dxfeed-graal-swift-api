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
- (instancetype)initWithItem:(dxfg_time_and_sale_t *)dxf_item {
    if (self = [super init]) {
        
//        self.event_type = dxf_item->market_event.event_type;
        self.event_time = dxf_item->market_event.event_time;
        self.event_symbol = [NSString newWithCstring:dxf_item->market_event.event_symbol];
        
        self.event_flags = dxf_item->event_flags;
        self.index = dxf_item->index;
        self.time_nano_part = dxf_item->time_nano_part;
        self.exchange_code = dxf_item->exchange_code;
        self.price = dxf_item->price;
        self.size = dxf_item->size;
        self.bid_price = dxf_item->bid_price;
        self.ask_price = dxf_item->ask_price;
        self.exchange_sale_conditions = [NSString newWithCstring:dxf_item->exchange_sale_conditions];
        self.flags = dxf_item->flags;
        self.buyer = [NSString newWithCstring:dxf_item->buyer];
        self.seller = [NSString newWithCstring:dxf_item->seller];
    }
    return self;
}

@end
