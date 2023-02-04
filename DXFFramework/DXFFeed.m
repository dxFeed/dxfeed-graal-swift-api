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

@interface DXFFeed()

@property (nonatomic, retain) DXFConnection *connection;
@property (nonatomic, retain) DXFEnvironment *env;
@property (nonatomic) dxfg_feed_t* feed;
@end

@implementation DXFFeed

- (void)dealloc {
    [self resetFeed];
}

- (void)resetFeed {
    if (self.feed) {
        dxfg_JavaObjectHandler_release(self.env.thread, &(self.feed->handler));
    }
}

- (instancetype)init:(DXFConnection *)connection env:(DXFEnvironment *)env {
    if (self = [super init]) {
        self.connection = connection;
        self.env = env;
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

- (void)getFeedForSymbol:(NSString *)str {
    
}

@end
