//
//  DXFSubscription.m
//  DXFFramework
//
//  Created by Aleksey Kosylo on 12.02.2023.
//

#import "DXFSubscription.h"
#import "dxfg_api.h"
#import "DXFEnvironment+Graal.h"
#import "DXFEventFabric.h"
#import "DXFTimeSale.h"
#import "DXFEventQuote.h"
#import "DXFFeed+Graal.h"
#import "DXFEventListener.h"
#import "DXFException.h"
#import "Logger.h"
#import "NSString+CString.h"
#import "DXFSubscriptionListener.h"

@interface DXFSubscription() <DXFEventListener>

@property (nonatomic) dxfg_subscription_t* subscription;
@property (nonatomic, retain) DXFEnvironment *env;
@property (nonatomic, strong) DXFEventFabric *fabric;
@property (nonatomic) dxfg_feed_event_listener_t *listener;
@property (nonatomic, strong) NSPointerArray *listeners;
@end

@implementation DXFSubscription

- (void)dealloc {
    if (self.listener) {
        dxfg_DXFeedSubscription_removeEventListener(self.env.thread, self.subscription, self.listener);
        dxfg_JavaObjectHandler_release(self.env.thread, &self.listener->handler);
        self.listener = nil;
    }
    if (self.subscription) {
        dxfg_JavaObjectHandler_release(self.env.thread, &self.subscription->handler);
        self.subscription = nil;
    }
}

- (instancetype)init:(DXFEnvironment *)env feed:(DXFFeed *)feed {
    if (self = [super init]) {
        self.listeners = [NSPointerArray weakObjectsPointerArray];
        self.env = env;
        self.subscription = dxfg_DXFeed_createSubscription(self.env.thread, feed.feed, DXFG_EVENT_QUOTE);
        self.listener =  dxfg_DXFeedEventListener_new(self.env.thread, &c_observable_list_listener_func, (__bridge void *)(self));
        NSInteger res = dxfg_DXFeedSubscription_addEventListener(self.env.thread,
                                                                 self.subscription,
                                                                 self.listener);
        if (res != 0) {
            DXFException *exc = [DXFException new];
            [Logger print:@"Create subscription %@", exc];
        }
        self.fabric = [[DXFEventFabric alloc] init:@{@(DXFG_EVENT_TIME_AND_SALE): DXFTimeSale.class,
                                                     @(DXFG_EVENT_QUOTE): DXFEventQuote.class
                                    }];
    }
    return self;
}

- (void)subscribe:(NSString *)str  {
    NSInteger res = NSIntegerMax;
    dxfg_symbol_t* symbol = dxfg_Symbol_new(self.env.thread, [str dxfCString], STRING);
    res = dxfg_DXFeedSubscription_addSymbol(self.env.thread, self.subscription, symbol);
    dxfg_Symbol_release(self.env.thread, symbol);
}

#pragma mark - DXFFeedListener

-(void)receivedEvents:(dxfg_event_type_list *)events {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:events->size];
    for (int i = 0; i < events->size; ++i) {
        dxfg_event_type_t *pEvent = (dxfg_event_type_t *)(events->elements[i]);
        DXFEvent *event = [self.fabric createEvent:pEvent];
        [array addObject:event];
    }
    for(id<DXFSubscriptionListener> listener in self.listeners) {
        [listener receivedEvents:array];
    }
}

#pragma mark - C-API
static void c_observable_list_listener_func(graal_isolatethread_t *thread, dxfg_event_type_list *events, void *user_data) {
    if (user_data) {
        id<DXFEventListener> listener = (__bridge id)user_data;
        [listener receivedEvents:events];
    }
}

#pragma mark - Listeners

- (void)addListener:(id<DXFSubscriptionListener>)listener {
    @synchronized (self) {
        [self.listeners addPointer:(__bridge void * _Nullable)(listener)];
    }
}

- (void)removeListener:(id<DXFSubscriptionListener>)listener {
    @synchronized (self) {
        NSMutableArray<NSNumber *> *indexes = [NSMutableArray new];
        void *pointer = (__bridge void * _Nullable)(listener);
        for (int i = 0; i <= self.listeners.count; i++)    {
            if (pointer == [self.listeners pointerAtIndex:i]) {
                [indexes addObject:@(i)];
            }
        }
        for (NSNumber *index in indexes) {
            [self.listeners removePointerAtIndex:index.integerValue];
        }
    }
}

@end
