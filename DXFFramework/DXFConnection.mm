//
//  DXFConnection.m
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/1/23.
//

#import "DXFConnection.h"
#import "DXFEnvironment+Graal.h"
#import "DXFConnectionState.h"
#import "DXFInternal.h"
#import "dxfg_api.h"

@interface DXFConnection()

@property (nonatomic, retain) DXFEnvironment *env;
@property (nonatomic, retain) NSString *address;

@property (nonatomic) dxfg_endpoint_t* endpoint;
@property (nonatomic) dxfg_executor_t* executor;
@property (nonatomic) dxfg_endpoint_state_change_listener_t* listener;
@end


@implementation DXFConnection

- (void)dealloc {
    if (self.listener) {
        dxfg_DXEndpoint_removeStateChangeListener(self.env.thread, self.endpoint, self.listener);
        dxfg_JavaObjectHandler_release(self.env.thread, &(self.listener->handler));
    }
    if (self.endpoint) {
        int32_t res = dxfg_DXEndpoint_closeAndAwaitTermination(self.env.thread, self.endpoint);
        [Logger print:@"Close connection %d", res];
    }
    if (self.executor) {
        dxfg_JavaObjectHandler_release(self.env.thread, &(self.executor->handler));
    }
   
}

- (nonnull instancetype)init:(nonnull DXFEnvironment *)env address:(NSString *)address {
    if (self = [super init]) {
        self.env = env;
        self.address = address;
    }
    return self;
}

- (BOOL)connect {
    @synchronized (self) {
        if (self.env.thread) {
            self.endpoint = dxfg_DXEndpoint_create(self.env.thread);
            // Creates an endpoint object.
            if (self.endpoint == nil) {
                return false;
            }
            [Logger print:@"start connection"];
            self.executor = dxfg_Executors_newFixedThreadPool(self.env.thread, 2, "thread-processing-events");
            dxfg_DXEndpoint_executor(self.env.thread, self.endpoint, self.executor);
            dxfg_endpoint_state_change_listener_t* stateListener = dxfg_PropertyChangeListener_new(self.env.thread, endpoint_state_change_listener, (__bridge void *)self);
            self.listener = stateListener;
            dxfg_DXEndpoint_addStateChangeListener(self.env.thread, self.endpoint, stateListener);
            return dxfg_DXEndpoint_connect(self.env.thread, self.endpoint, self.address.dxfCString) == 0;
        }
        return false;
    }
}

- (void)connectionChanged:(dxfg_endpoint_state_t)newState {
    switch(newState){
        case DXFG_ENDPOINT_STATE_NOT_CONNECTED:
            self.state = NotConnected;
            break;
        case DXFG_ENDPOINT_STATE_CONNECTING:
            self.state = Connecting;
            break;
        case DXFG_ENDPOINT_STATE_CONNECTED:
            self.state = Connected;
            break;
        case DXFG_ENDPOINT_STATE_CLOSED:
            self.state = Disconnected;
            break;
    }
    [Logger print:@"Connection new state %d\n", self.state];
}

#pragma mark -
#pragma mark C-API
static void endpoint_state_change_listener(graal_isolatethread_t *thread, dxfg_endpoint_state_t old_state,
                                    dxfg_endpoint_state_t new_state, void *user_data) {
    DXFConnection* connection = (__bridge DXFConnection *)(user_data);
    [connection connectionChanged:new_state];
}


@end
