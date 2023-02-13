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

@interface DXFSubscription()

@property (nonatomic) dxfg_subscription_t* subscription;
@property (nonatomic, retain) DXFEnvironment *env;
@property (nonatomic, strong) DXFEventFabric *fabric;

@end

@implementation DXFSubscription

- (void)dealloc {
    if (self.subscription) {
        dxfg_JavaObjectHandler_release(self.env.thread, &self.subscription->handler);
    }
}

- (instancetype)init:(DXFEnvironment *)env {
    if (self = [super init]) {
        self.env = env;
        self.fabric = [[DXFEventFabric alloc] init:@{@(DXFG_EVENT_TIME_AND_SALE): DXFTimeSale.class,
                                                     @(DXFG_EVENT_QUOTE): DXFEventQuote.class
                                    }];
    }
    return self;
}

@end
