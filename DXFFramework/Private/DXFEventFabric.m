//
//  DXFEventFabric.m
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#import "DXFEventFabric.h"
#import "DXFEvent+Private.h"
#import "DXFTimeSale+Private.h"
#import "DXFEventQuote+Private.h"

@interface DXFEventFabric()

@property (nonatomic, strong) NSDictionary *supportedEvents;

@end


@implementation DXFEventFabric

- (instancetype)init:(NSDictionary *)events {
    if (self = [super init]) {
        self.supportedEvents = events;
    }
    return self;
}

- (DXFEvent *)createEvent:(dxfg_event_type_t *)dxfEvent {    
    Class eventClass = self.supportedEvents[@(dxfEvent->clazz)];
    if (eventClass) {
        return [[eventClass alloc] initWithItem:dxfEvent];
    } else {
        NSAssert(false, @"%@ doesn't support event with type %d", NSStringFromClass([self class]), dxfEvent->clazz);
        return nil;
    }    
}

- (BOOL)isSupport:(dxfg_event_clazz_t)type {
    return self.supportedEvents[@(type)] != nil;
}

@end
