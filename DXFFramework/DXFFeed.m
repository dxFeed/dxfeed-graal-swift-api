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
#import "DXFEventQuote+Graal.h"
#import "DXFFeedListener.h"
#import "DXFEventFabric.h"

@interface DXFFeed() <DXFFeedListener>

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
        self.fabric = [DXFEventFabric new];
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
    graal_isolatethread_t *thread = self.env.thread;
    dxfg_feed_t* feed = self.feed;
    
    dxfg_indexed_event_model_t* indexed_event_model = dxfg_IndexedEventModel_new(thread, DXFG_EVENT_TIME_AND_SALE);
    dxfg_IndexedEventModel_setSizeLimit(thread, indexed_event_model, 30);
    dxfg_IndexedEventModel_attach(thread, indexed_event_model, feed);
    dxfg_observable_list_model_t* observable_list_model = dxfg_IndexedEventModel_getEventsList(thread, indexed_event_model);
    dxfg_string_symbol_t symbolAAPL;
    symbolAAPL.supper.type = STRING;
    symbolAAPL.symbol = [str dxfCString];
    dxfg_IndexedEventModel_setSymbol(thread, indexed_event_model, &symbolAAPL.supper);
    dxfg_observable_list_model_listener_t *observable_list_model_listener = dxfg_ObservableListModelListener_new(thread, &c_observable_list_listener_func, (__bridge void *)self);
    dxfg_ObservableListModel_addListener(thread, observable_list_model, observable_list_model_listener);
    dxfg_subscription_t* subscriptionQuote = dxfg_DXFeedSubscription_new(thread, DXFG_EVENT_QUOTE);
    dxfg_DXFeed_attachSubscription(thread, feed, subscriptionQuote);
    dxfg_DXFeedSubscription_addEventListener(
        thread,
        subscriptionQuote,
        dxfg_DXFeedEventListener_new(thread, &c_print, (__bridge void *)self)
    );
    //release
//    dxfg_ObservableListModel_removeListener(self.env.thread, observable_list_model, observable_list_model_listener);
//    dxfg_JavaObjectHandler_release(self.env.thread, &observable_list_model_listener->handler);
//    dxfg_JavaObjectHandler_release(self.env.thread, &indexed_event_model->handler);
//    dxfg_JavaObjectHandler_release(self.env.thread, &observable_list_model->handler);
//    dxfg_JavaObjectHandler_release(self.env.thread, &subscriptionQuote->handler);

    
}

#pragma mark - DXFFeedListener

- (void)receivedEventQuote:(DXFEventQuote *)event {
 
    self.values = event;
}

#pragma mark - C-API
static void c_observable_list_listener_func(graal_isolatethread_t *thread, dxfg_event_type_list* orders, void *user_data) {
    id<DXFFeedListener> feed = (__bridge id)user_data;
    for (int i = 0; i < orders->size; ++i) {
        dxfg_event_type_t *pEvent = (dxfg_event_type_t *)(orders->elements[0]);
        if (pEvent->clazz == DXFG_EVENT_QUOTE) {
            DXFEventQuote * quoute = [[DXFEventQuote alloc] initWithQuote:(dxfg_quote_t *)pEvent];
        } else if (pEvent->clazz == DXFG_EVENT_TIME_AND_SALE) {
            [[DXFEventFabric new] createEvent:(dxfg_time_and_sale_t *)pEvent];
        }
        [feed receivedEventQuote:nil];
//        printEvent(reinterpret_cast<dxfg_event_type_t *>(orders->elements[0]));
    }
    dxfg_CList_EventType_release(thread, orders);
}

static void c_print(graal_isolatethread_t *thread, dxfg_event_type_list *events, void *user_data) {
    for (int i = 0; i < events->size; ++i) {
//        printEvent(events->elements[i]);
    }
}

@end
