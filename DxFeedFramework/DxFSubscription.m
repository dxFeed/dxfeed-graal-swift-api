//
//  DxFSubscription.m
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 12.02.2023.
//

#import "DxFSubscription.h"
#import "DxFInternal.h"

#import "DxFTimeSale.h"
#import "DxFEventQuote.h"

#import "DxFSubscriptionListener.h"

@protocol DxFEventListener

- (void)receivedEvents:(dxfg_event_type_list *)events;

@end

@interface DxFSubscription() <DxFEventListener>

@property (nonatomic) dxfg_subscription_t* subscription;
@property (nonatomic, retain) DxFEnvironment *env;
@property (nonatomic, strong) DxFEventFabric *fabric;
@property (nonatomic) dxfg_feed_event_listener_t *listener;
@property (nonatomic, strong) NSPointerArray *listeners;
@end

@implementation DxFSubscription

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
    NSLog(@"dealloc subscription %@ %@",self.listener, self.subscription);
}

- (instancetype)init:(DxFEnvironment *)env feed:(DxFFeed *)feed type:(DxFEventType)type{
    if (self = [super init]) {
        self.fabric = [DxFEventFabric new];
        dxfg_event_clazz_t graalType = [DxFSubscription graalType:type];
        self.listeners = [NSPointerArray weakObjectsPointerArray];
        self.env = env;
        self.subscription = dxfg_DXFeed_createSubscription(self.env.thread, feed.feed, graalType);
        self.listener =  dxfg_DXFeedEventListener_new(self.env.thread, &c_observable_list_listener_func, (__bridge void *)(self));
        NSInteger res = dxfg_DXFeedSubscription_addEventListener(self.env.thread,
                                                                 self.subscription,
                                                                 self.listener);
        if (res != DxF_SUCCESS) {
            DxFException *exc = [[DxFException alloc] init:self.env];
            [Logger print:@"Create subscription %@", exc];
        }        
    }
    return self;
}

- (void)subscribe:(NSString *)str  {
    NSInteger res = NSIntegerMax;
    dxfg_symbol_t* symbol = dxfg_Symbol_new(self.env.thread, [str dxfCString], STRING);
    res = dxfg_DXFeedSubscription_addSymbol(self.env.thread, self.subscription, symbol);
    dxfg_Symbol_release(self.env.thread, symbol);
}

+ (dxfg_event_clazz_t)graalType:(DxFEventType)type {
    static NSDictionary<NSNumber *, NSNumber *> *types;
    if (!types) {
        types = @{@(DxFEventTypeQuote): @(DXFG_EVENT_QUOTE),
                  @(DxFEventTypeTimeSale): @(DXFG_EVENT_TIME_AND_SALE)
        };
    }
    return types[@(type)].intValue;
}

#pragma mark - DxFFeedListener

-(void)receivedEvents:(dxfg_event_type_list *)events {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:events->size];
    for (int i = 0; i < events->size; ++i) {
        dxfg_event_type_t *pEvent = (dxfg_event_type_t *)(events->elements[i]);
        DxFEvent *event = [self.fabric createEvent:pEvent];
        [array addObject:event];
    }
    for(id<DxFSubscriptionListener> listener in self.listeners) {
        [listener receivedEvents:array];
    }
}

#pragma mark - C-API
static void c_observable_list_listener_func(graal_isolatethread_t *thread, dxfg_event_type_list *events, void *user_data) {
    if (user_data) {
        id<DxFEventListener> listener = (__bridge id)user_data;
        [listener receivedEvents:events];
    }
}

#pragma mark - Listeners

- (void)addListener:(id<DxFSubscriptionListener>)listener {
    @synchronized (self) {
        [self.listeners addPointer:(__bridge void * _Nullable)(listener)];
    }
}

- (void)removeListener:(id<DxFSubscriptionListener>)listener {
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
