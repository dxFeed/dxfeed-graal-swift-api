//
//  DXFEventFabric.m
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#import "DXFEventFabric.h"
#import "DXFEvent+Private.h"
#import "DXFEventQuote+Private.h"
#import "DXFTimeSale+Private.h"

@implementation DXFEventFabric


- (DXFEvent *)createEvent:(dxfg_event_type_t *)dxfEvent {
    NSInteger clazz = dxfEvent->clazz;
    switch (clazz) {
        case DXFG_EVENT_QUOTE:
            return [[DXFEventQuote alloc] initWithItem:dxfEvent];
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
            return [[DXFTimeSale alloc] initWithItem:dxfEvent];
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
    NSAssert(false, @"%@ doesn't support event with type %zd", NSStringFromClass([self class]), clazz);
    return nil;
}

@end
