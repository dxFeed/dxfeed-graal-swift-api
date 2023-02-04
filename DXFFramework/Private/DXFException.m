//
//  DXFException.m
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/4/23.
//

#import "DXFException.h"
#import "dxfg_api.h"
#import "NSString+CString.h"
#import "DXFEnvironment+Graal.h"

@interface DXFException ()

@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *className;
@property (nonatomic, retain) NSString *stackTrace;

@end

@implementation DXFException

- (instancetype)init:(DXFEnvironment *)env {
    dxfg_exception_t* exception = dxfg_get_and_clear_thread_exception_t(env.thread);
    if (exception) {
        if (self = [super init]) {
            self.message = [NSString newWithCstring:exception->message];
            self.className = [NSString newWithCstring:exception->className];
            self.stackTrace = [NSString newWithCstring:exception->stackTrace];
        }
        dxfg_Exception_release(env.thread, exception);
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Exception in:%@ message:%@\n%@\n", self.className, self.message, self.stackTrace];
}

@end
