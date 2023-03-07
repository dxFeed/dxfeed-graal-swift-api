//
//  DxFFeed.m
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/4/23.
//

#import "DxFFeed.h"
#import "DxFInternal.h"

@interface DxFFeed()

@property (nonatomic, retain) DxFConnection *connection;
@property (nonatomic, retain) DxFEnvironment *env;
@property (nonatomic) dxfg_feed_t *feed;
@property (nonatomic, strong) DxFEventFabric *fabric;
@end



@implementation DxFFeed

- (void)dealloc {
    if (self.feed) {
        dxfg_JavaObjectHandler_release(self.env.thread, &self.feed->handler);
        self.feed = nil;
    }
    NSLog(@"dealloc feed %@",self.feed);
}

- (instancetype)init:(DxFConnection *)connection env:(DxFEnvironment *)env {
    if (self = [super init]) {
        self.connection = connection;
        self.env = env;
        self.feed = dxfg_DXEndpoint_getFeed(self.env.thread, self.connection.endpoint);
    }
    return self;
}

@end
