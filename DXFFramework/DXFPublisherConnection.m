//
//  DXFPublisherConnection.m
//  DXFFramework
//
//  Created by Aleksey Kosylo on 19.02.2023.
//

#import "DXFPublisherConnection.h"
#import "DXFInternal.h"

@interface DXFPublisherConnection()

@property (nonatomic, retain) DXFEnvironment *env;
@property (nonatomic, retain) NSString *port;

@property (nonatomic) dxfg_endpoint_t* endpoint;
@property (nonatomic) dxfg_executor_t* executor;
@property (nonatomic) dxfg_endpoint_state_change_listener_t* listener;

@end


@implementation DXFPublisherConnection

- (void)dealloc {
    if (self.listener) {
        dxfg_DXEndpoint_removeStateChangeListener(self.env.thread, self.endpoint, self.listener);
        dxfg_JavaObjectHandler_release(self.env.thread, &(self.listener->handler));
        self.listener = nil;
    }
    if (self.endpoint) {
        int32_t res = dxfg_DXEndpoint_closeAndAwaitTermination(self.env.thread, self.endpoint);
        [Logger print:@"Close connection %d", res];
        self.endpoint = nil;
    }
    NSLog(@"dealloc connection %@ %@",self.listener, self.endpoint);
}

- (nonnull instancetype)init:(nonnull DXFEnvironment *)env port:(NSString *)port {
    if (self = [super init]) {
        self.env = env;
        self.port = port;
    }
    return self;
}

- (BOOL)connect {
    @synchronized (self) {
        if (self.env.thread) {
            dxfg_endpoint_builder_t* builder = dxfg_DXEndpoint_newBuilder(self.env.thread);
            NSInteger res = dxfg_DXEndpoint_Builder_withProperty(self.env.thread, builder, "dxfeed.wildcard.enable", "true");
            res = dxfg_DXEndpoint_Builder_withRole(self.env.thread, builder, DXFG_ENDPOINT_ROLE_PUBLISHER);
            self.endpoint = dxfg_DXEndpoint_Builder_build(self.env.thread, builder);
            res = dxfg_DXEndpoint_connect(self.env.thread, self.endpoint, self.port.dxfCString);
            if (res != DXF_SUCCESS) {
                DXFException *exc = [[DXFException alloc] init:self.env];
                [Logger print:@"Create subscription %@", exc];
            }
            dxfg_JavaObjectHandler_release(self.env.thread, &builder->handler);
            return res == DXF_SUCCESS;
        }
        return false;
    }
}

- (void)connectionChanged:(dxfg_endpoint_state_t)newState {
    [Logger print:@"Connection new state %d\n", newState];
}

@end
