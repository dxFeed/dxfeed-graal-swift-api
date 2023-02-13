//
//  DXFControl.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/1/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DXFEnvironment;

@protocol DXFControl 

- (instancetype)init:(DXFEnvironment *)env;

@end

NS_ASSUME_NONNULL_END
