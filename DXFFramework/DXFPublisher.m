//
//  DXFPublisher.m
//  DXFFramework
//
//  Created by Aleksey Kosylo on 19.02.2023.
//

#import "DXFPublisher.h"
#import "DXFInternal.h"

@interface DXFPublisher()

@property (nonatomic, retain) DXFConnection *connection;
@property (nonatomic, retain) DXFEnvironment *env;
@property (nonatomic) dxfg_publisher_t *publisher;

@end

@implementation DXFPublisher

- (void)dealloc {
    if (self.publisher) {
        dxfg_JavaObjectHandler_release(self.env.thread, &self.publisher->handler);
        self.publisher = nil;
    }
    NSLog(@"dealloc publisher %@",self.publisher);
}

- (instancetype)init:(DXFConnection *)connection env:(DXFEnvironment *)env {
    if (self = [super init]) {
        self.connection = connection;
        self.env = env;
        self.publisher = dxfg_DXEndpoint_getPublisher(self.env.thread, self.connection.endpoint);
    }
    return self;
}

- (BOOL)publish:(NSArray *)events {
    dxfg_time_and_sale_t *ts = malloc(sizeof(dxfg_time_and_sale_t));
    ts->ask_price = 9999;
    ts->market_event.event_type.clazz = DXFG_EVENT_TIME_AND_SALE;
    ts->market_event.event_symbol = @"TEST1".dxfCString;
    dxfg_event_type_list *eventsList = malloc(sizeof(dxfg_event_type_list));
    eventsList->size = 1;
    eventsList->elements = malloc(sizeof(dxfg_time_and_sale_t));
    eventsList->elements[0] = (dxfg_event_type_t *)ts;
    
    NSInteger res = dxfg_DXPublisher_publishEvents(self.env.thread, self.publisher, eventsList);
    if (res != DXF_SUCCESS) {
        DXFException *exc = [[DXFException alloc] init:self.env];
        [Logger print:@"Publish events %@", exc];
    }
    
    for (int i = 0; i < eventsList->size; ++i) {
        dxfg_event_type_t *ev = eventsList->elements[i];
        free(ev);
    }
    free(eventsList->elements);
    free(eventsList);
    return res == DXF_SUCCESS;
}

@end