//
//  DXFFeed.m
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/4/23.
//

#import "DXFFeed.h"
#import "DXFConnection+Graal.h"
#import "DXFEnvironment+Graal.h"
#import "DXFException.h"
#import "DXFInternal.h"
#import "dxfg_api.h"
#import "DXFEventQuote+Private.h"
#import "DXFTimeSale+Private.h"
#import "DXFEventListener.h"
#import "DXFEventFabric.h"

@interface DXFFeed() <DXFEventListener>

@property (nonatomic, retain) DXFConnection *connection;
@property (nonatomic, retain) DXFEnvironment *env;
@property (nonatomic) dxfg_feed_t* feed;
@property (nonatomic, retain) id values;
@property (nonatomic, strong) DXFEventFabric *fabric;
@end



@implementation DXFFeed

- (void)dealloc {
    [self resetFeed];
}

- (void)resetFeed {
    if (self.feed) {
        dxfg_JavaObjectHandler_release(self.env.thread, &self.feed->handler);
    }
}

- (instancetype)init:(DXFConnection *)connection env:(DXFEnvironment *)env {
    if (self = [super init]) {
        self.connection = connection;
        self.env = env;
        self.fabric = [[DXFEventFabric alloc] init:@{@(DXFG_EVENT_TIME_AND_SALE): DXFTimeSale.class,
                                                     @(DXFG_EVENT_QUOTE): DXFEventQuote.class
                                                   }];
    }
    return self;
}

- (BOOL)load {
    @synchronized (self) {
        [self resetFeed];
        self.feed = dxfg_DXEndpoint_getFeed(self.env.thread, self.connection.endpoint);
        int state = dxfg_DXEndpoint_getState(self.env.thread, self.connection.endpoint);
        if (state == DXF_FAIL) {
            __auto_type exception = [[DXFException alloc] init:self.env];
            [Logger print:exception.description];
            return false;
        }
        return true;
    }
}

- (void)getFeedForSymbol:(NSString *)str  {
    NSInteger res = NSIntegerMax;
    
    dxfg_subscription_t *subscription = dxfg_DXFeed_createSubscription(self.env.thread, self.feed, DXFG_EVENT_QUOTE);
    res = dxfg_DXFeedSubscription_addEventListener(self.env.thread,
                                                   subscription,
                                                   dxfg_DXFeedEventListener_new(self.env.thread, &c_observable_list_listener_func, (__bridge void *)(self)));
    dxfg_symbol_t* symbol = dxfg_Symbol_new(self.env.thread, [str dxfCString], STRING);
    res = dxfg_DXFeedSubscription_addSymbol(self.env.thread, subscription, symbol);
    dxfg_Symbol_release(self.env.thread, symbol);
    
    
}


#pragma mark - DXFFeedListener
-(void)receivedEvents:(dxfg_event_type_list *)events {
    for (int i = 0; i < events->size; ++i) {
        dxfg_event_type_t *pEvent = (dxfg_event_type_t *)(events->elements[i]);
        DXFEvent *event = [self.fabric createEvent:pEvent];
        NSLog(@"%@",event);
    }
}

#pragma mark - C-API
static void c_observable_list_listener_func(graal_isolatethread_t *thread, dxfg_event_type_list *events, void *user_data) {
    if (user_data) {
        id<DXFEventListener> listener = (__bridge id)user_data;
        [listener receivedEvents:events];
    }
}

@end
