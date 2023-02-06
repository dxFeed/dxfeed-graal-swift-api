//
//  DXFEventFabric.m
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#import "DXFEventFabric.h"
#import "DXFEvent+Private.h"
#import "DXFTimeSale+Private.h"

@implementation DXFEventFabric

- (DXFEvent *)createEvent:(dxfg_event_type_t *)dxfEvent {
    if (dxfEvent->clazz == DXFG_EVENT_TIME_AND_SALE) {
        dxfg_time_and_sale_t *dxf_item = (dxfg_time_and_sale_t *)dxfEvent;
        DXFTimeSale *ts = [[DXFTimeSale alloc] initWithItem:dxf_item];
        return ts;
    } else {
        NSAssert(false, @"%@ doesn't support event with type %d", NSStringFromClass([self class]), dxfEvent->clazz);
        return nil;
    }
}

@end
