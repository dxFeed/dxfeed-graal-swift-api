//
//  DxFFeed.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/4/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DxFConnection, DxFEnvironment;
@interface DxFFeed : NSObject

- (instancetype)init:(DxFConnection *)connection env:(DxFEnvironment *)env;

@end

NS_ASSUME_NONNULL_END
