//
//  DxFSystem.m
//  TestGraalvm
//
//  Created by Aleksey Kosylo on 1/28/23.
//

#import "DxFSystem.h"
#import "DxFInternal.h"

@interface DxFSystem()

@property (nonatomic, retain) DxFEnvironment *env;

@end

@implementation DxFSystem

- (void)dealloc {
}

- (instancetype)init:(DxFEnvironment *)env {
    if (self = [super init]) {
        self.env = env;
    }
    return self;
}

- (BOOL)write:(NSString *)value forKey:(NSString *)key {
    int res = dxfg_system_set_property(self.env.thread, [key cStringUsingEncoding:NSUTF8StringEncoding], [value cStringUsingEncoding:NSUTF8StringEncoding]);
    return res == DxF_SUCCESS;
}

- (nullable NSString *)read:(NSString *)key {
    const char * obj = dxfg_system_get_property(self.env.thread, [key cStringUsingEncoding:NSUTF8StringEncoding]);
    if (obj == nil) {
        return nil;
    } else {
        __auto_type res = [[NSString alloc] initWithCString:obj encoding:NSUTF8StringEncoding];
        dxfg_system_release_property(self.env.thread, obj);
        return res;
    }
}

@end