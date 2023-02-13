//
//  DXFSubscription.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 12.02.2023.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DXFEnvironment;
@interface DXFSubscription : NSObject

- (instancetype)init:(DXFEnvironment *)env;

@end

NS_ASSUME_NONNULL_END
