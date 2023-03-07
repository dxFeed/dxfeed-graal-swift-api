//
//  DxFEnvironment.m
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 1/29/23.
//

#import "DxFEnvironment.h"
#import "DxFInternal.h"

@interface DxFEnvironment()

@property graal_isolatethread_t *thread;
@property graal_isolate_t *isolate;

@end

@implementation DxFEnvironment

- (void)dealloc {
    
    if (self.thread) {
        graal_detach_all_threads_and_tear_down_isolate(self.thread);
        self.thread = nil;
    }
    NSLog(@"dealloc env %@",self.thread);
}

- (instancetype)init {
    if (self = [super init]) {
        graal_isolate_t *isolate = nil;
        graal_isolatethread_t *thread = nil;
        if (graal_create_isolate(NULL, &isolate, &thread) != DxF_SUCCESS) {
            fprintf(stderr, "initialization error\n");
            return nil;
        }
        self.thread = thread;
        self.isolate = isolate;
    }
    return self;
}

@end
