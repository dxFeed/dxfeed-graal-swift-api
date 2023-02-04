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

@end

@implementation DXFFeed

- (void)dealloc {
    
}

- (instancetype)init:(DXFConnection *)connection env:(DXFEnvironment *)env {
    if (self = [super init]) {
        self.connection = connection;
        self.env = env;
    }
    return self;
}

- (BOOL)load {
    dxfg_feed_t* feed = dxfg_DXEndpoint_getFeed(self.env.thread, self.connection.endpoint);
    int state = dxfg_DXEndpoint_getState(self.env.thread, self.connection.endpoint);
    if (state != DXF_SUCCESS) {
        __auto_type exception = [[DXFException alloc] init:self.env];
        [Logger print:exception.description];
        return false;
    }
    return true;
    
}

@end
