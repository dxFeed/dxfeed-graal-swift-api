//
//  DXFFeed.m
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/4/23.
//

#import "DXFFeed.h"
#import "DXFInternal.h"

@interface DXFFeed()

@property (nonatomic, retain) DXFConnection *connection;
@property (nonatomic, retain) DXFEnvironment *env;
@property (nonatomic) dxfg_feed_t *feed;
@property (nonatomic, strong) DXFEventFabric *fabric;
@end



@implementation DXFFeed

- (void)dealloc {
    if (self.feed) {
        dxfg_JavaObjectHandler_release(self.env.thread, &self.feed->handler);
        self.feed = nil;
    }
    NSLog(@"dealloc feed %@",self.feed);
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
