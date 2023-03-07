//
//  DXFPublisher.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 19.02.2023.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DXFConnection, DXFEnvironment;
@interface DXFPublisher : NSObject

- (instancetype)init:(DXFConnection *)connection env:(DXFEnvironment *)env;

- (BOOL)publish:(NSArray *)events;

@end

NS_ASSUME_NONNULL_END
