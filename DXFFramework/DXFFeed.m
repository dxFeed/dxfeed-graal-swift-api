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
#import "DXFEventFabric.h"

@interface DXFFeed()

@property (nonatomic, retain) DXFConnection *connection;
@property (nonatomic, retain) DXFEnvironment *env;
@property (nonatomic) dxfg_feed_t* feed;
@property (nonatomic, retain) id values;
@property (nonatomic, strong) DXFEventFabric *fabric;
@end



@implementation DXFFeed

- (void)dealloc {
    if (self.feed) {
        dxfg_JavaObjectHandler_release(self.env.thread, &self.feed->handler);
    }
}

- (instancetype)init:(DXFConnection *)connection env:(DXFEnvironment *)env {
    if (self = [super init]) {
        self.connection = connection;
        self.env = env;
        self.feed = dxfg_DXEndpoint_getFeed(self.env.thread, self.connection.endpoint);
    }
    return self;
}

@end
