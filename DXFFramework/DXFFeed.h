//
//  DXFFeed.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/4/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DXFConnection, DXFEnvironment;

@interface DXFFeed : NSObject

- (instancetype)init:(DXFConnection *)connection env:(DXFEnvironment *)env;

- (BOOL)load;

@end

NS_ASSUME_NONNULL_END
