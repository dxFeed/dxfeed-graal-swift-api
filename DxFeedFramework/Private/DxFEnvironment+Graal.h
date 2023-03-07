//
//  DxFEnvironment+Graal.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 1/29/23.
//

#import "DxFEnvironment.h"
#import "graal_isolate.h"

NS_ASSUME_NONNULL_BEGIN

@interface DxFEnvironment (Graal)

@property (readonly, readonly) graal_isolatethread_t *thread;
@property (readonly, readonly) graal_isolate_t *isolate;

@end

NS_ASSUME_NONNULL_END
