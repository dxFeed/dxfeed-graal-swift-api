//
//  DXFSystem.m
//  TestGraalvm
//
//  Created by Aleksey Kosylo on 1/28/23.
//

#import "DXFSystem.h"
#import "DXFInternal.h"

@interface DXFSystem()

@property (nonatomic, retain) DXFEnvironment *env;

@end

@implementation DXFSystem

- (void)dealloc {
}

- (instancetype)init:(DXFEnvironment *)env {
    if (self = [super init]) {
        self.env = env;
    }
    return self;
}

- (BOOL)write:(NSString *)value forKey:(NSString *)key {
    int res = dxfg_system_set_property(self.env.thread, [key cStringUsingEncoding:NSUTF8StringEncoding], [value cStringUsingEncoding:NSUTF8StringEncoding]);
    return res == DXF_SUCCESS;
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
