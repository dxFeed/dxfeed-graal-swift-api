//
//  DXFConnection.m
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/1/23.
//

#import "DXFConnection.h"
#import "DXFEnvironment+Graal.h"
#import "Logger.h"
#import "NSString+CString.h"
#import "dxfg_endpoint.h"

@interface DXFConnection()

@property (nonatomic, retain) DXFEnvironment *env;

@property (nonatomic) dxfg_endpoint_t* endpoint;
@property (nonatomic) dxfg_executor_t* executor;
@end


@implementation DXFConnection

- (void)dealloc {
    if (self.endpoint) {
        int32_t res = dxfg_DXEndpoint_closeAndAwaitTermination(self.env.thread, self.endpoint);
        [Logger print:@"Close connection %d", res];
    }
}

- (nonnull instancetype)init:(nonnull DXFEnvironment *)env {
    if (self = [super init]) {
        self.env = env;
    }
    return self;
}

void endpoint_state_change_listener(graal_isolatethread_t *thread, dxfg_endpoint_state_t old_state,
                                    dxfg_endpoint_state_t new_state, void *user_data) {
    [Logger print:@"C: state %d -> %d\n", old_state, new_state];
}


- (BOOL)connect:(nonnull NSString *)address {
    if (self.env.thread) {
        self.endpoint = dxfg_DXEndpoint_create(self.env.thread);
        // Creates an endpoint object.
        if (self.endpoint == nil) {
            return false;
        }
        
        self.executor = dxfg_Executors_newFixedThreadPool(self.env.thread, 2, "thread-processing-events");
        dxfg_DXEndpoint_executor(self.env.thread, self.endpoint, self.executor);

        dxfg_endpoint_state_change_listener_t* stateListener = dxfg_PropertyChangeListener_new(self.env.thread, endpoint_state_change_listener, (__bridge void *)self);
        dxfg_DXEndpoint_addStateChangeListener(self.env.thread, self.endpoint, stateListener);
        dxfg_DXEndpoint_connect(self.env.thread, self.endpoint, address.dxfCString);
    }
    return true;
}

@end
