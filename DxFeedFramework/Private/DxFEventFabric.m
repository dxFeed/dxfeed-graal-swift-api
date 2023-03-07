//
//  DxFEventFabric.m
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#import "DxFEventFabric.h"
#import "DxFEvent+Private.h"
#import "DxFEventQuote+Private.h"
#import "DxFTimeSale+Private.h"

@implementation DxFEventFabric


- (DxFEvent *)createEvent:(dxfg_event_type_t *)dxfEvent {
    NSInteger clazz = dxfEvent->clazz;
    switch (clazz) {
        case DXFG_EVENT_QUOTE:
            return [[DxFEventQuote alloc] initWithItem:dxfEvent];
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
            return [[DxFTimeSale alloc] initWithItem:dxfEvent];
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
