//
//  DXFEvent.m
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#import "DXFEvent.h"
#import "DXFEvent+Private.h"
#import "NSString+CString.h"

@implementation DXFEvent

- (instancetype)initWithMarketEvent:(dxfg_market_event_t)item {
    if (self = [super init]) {
        self.event_symbol = [NSString newWithCstring:item.event_symbol];
        self.event_time = item.event_type.clazz;
        self.event_time = item.event_time;
        
    }
    return self;
}

@end
