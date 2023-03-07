//
//  DXFException.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/4/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DXFEnvironment;
@interface DXFException : NSObject

@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSString *className;
@property (nonatomic, readonly) NSString *stackTrace;

- (instancetype)init:(DXFEnvironment *)env;

@end

NS_ASSUME_NONNULL_END
