//
//  DXFEnvironment.m
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 1/29/23.
//

#import "DXFEnvironment.h"
#import "graal_isolate.h"

@interface DXFEnvironment()

@property graal_isolatethread_t *thread;

@end

@implementation DXFEnvironment

- (void)dealloc {
    if (self.thread) {
        graal_tear_down_isolate(self.thread);
        self.thread = NULL;
    }
}

- (instancetype)init {
    if (self = [super init]) {
        graal_isolate_t *isolate = NULL;
        graal_isolatethread_t *thread = NULL;
    
        if (graal_create_isolate(NULL, &isolate, &thread) != 0) {
            fprintf(stderr, "initialization error\n");
            return NULL;
        }
        self.thread = thread;
    }
    return self;
}


@end
