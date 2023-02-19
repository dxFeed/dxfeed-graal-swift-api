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
        _event_symbol = [NSString newWithCstring:item.event_symbol];
        _event_type = [DXFEvent type:item.event_type.clazz];
        _event_time = item.event_time;
        
    }
    return self;
}

+ (DXFEventType)type:(dxfg_event_clazz_t)clazz {
    switch (clazz) {
        case DXFG_EVENT_QUOTE:
            return DXFEventTypeQuote;
        case DXFG_EVENT_PROFILE:
            
            break;
        case DXFG_EVENT_SUMMARY:
            
            break;
        case DXFG_EVENT_GREEKS:
            
            break;
        case DXFG_EVENT_CANDLE:
            
            break;
        case DXFG_EVENT_DAILY_CANDLE:
            
            break;
        case DXFG_EVENT_UNDERLYING:
            
            break;
        case DXFG_EVENT_THEO_PRICE:
            
            break;
        case DXFG_EVENT_TRADE:
            
            break;
        case DXFG_EVENT_TRADE_ETH:
            
            break;
        case DXFG_EVENT_CONFIGURATION:
            
            break;
        case DXFG_EVENT_MESSAGE:
            
            break;
        case DXFG_EVENT_TIME_AND_SALE:
            return DXFEventTypeTimeSale;
            break;
        case DXFG_EVENT_ORDER_BASE:
            
            break;
        case DXFG_EVENT_ORDER:
            
            break;
        case DXFG_EVENT_ANALYTIC_ORDER:
            
            break;
        case DXFG_EVENT_SPREAD_ORDER:
            
            break;
        case DXFG_EVENT_SERIES:
            
            break;
    }
    return DXFEventTypeUndefined;
}

@end
