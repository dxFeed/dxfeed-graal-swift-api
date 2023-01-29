//
//  TestCppClass.m
//  TestGraalvm
//
//  Created by Aleksey Kosylo on 1/28/23.
//

#import "DXFeedSystem.h"
#import "graal_isolate.h"
#import "dxfg_system.h"
#import "DXFeedInitializator+Graal.h"

@interface DXFeedSystem()

@property (nonatomic, retain) DXFeedInitializator *initializator;

@end

@implementation DXFeedSystem

- (void)dealloc {
}

- (instancetype)init:(DXFeedInitializator *)initializator {
    if (self = [super init]) {
        self.initializator = initializator;
    }
    return self;
}

- (BOOL)write:(NSString *)key value:(NSString *)value {
    int res = dxfg_system_set_property(self.initializator.thread, [key cStringUsingEncoding:NSUTF8StringEncoding], [value cStringUsingEncoding:NSUTF8StringEncoding]);
    return res == 0;
}

- (nullable NSString *)read:(NSString *)key {
    const char * obj = dxfg_system_get_property(self.initializator.thread, [key cStringUsingEncoding:NSUTF8StringEncoding]);
    if (obj == NULL) {
        return NULL;
    } else {
        __auto_type res = [[NSString alloc] initWithCString:obj encoding:NSUTF8StringEncoding];
        dxfg_system_release_property(self.initializator.thread, obj);
        return res;
    }
}

@end
