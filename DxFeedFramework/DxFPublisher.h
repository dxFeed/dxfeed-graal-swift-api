//
//  DxFPublisher.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 19.02.2023.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DxFConnection, DxFEnvironment;
@interface DxFPublisher : NSObject

- (instancetype)init:(DxFConnection *)connection env:(DxFEnvironment *)env;

- (BOOL)publish:(NSArray *)events;

@end

NS_ASSUME_NONNULL_END
