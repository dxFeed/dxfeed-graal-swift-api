//
//  DXFeedInitializator+Graal.h
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 1/29/23.
//

#import <DXFeedFramework/DXFeedFramework.h>
#import "graal_isolate.h"

NS_ASSUME_NONNULL_BEGIN

@interface DXFeedInitializator ()

@property graal_isolatethread_t *thread;

@end

NS_ASSUME_NONNULL_END
