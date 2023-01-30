//
//  DXFSystem.h
//  TestGraalvm
//
//  Created by Aleksey Kosylo on 1/28/23.
//

#import <Foundation/Foundation.h>

@class DXFEnvironment;

NS_ASSUME_NONNULL_BEGIN

@interface DXFSystem : NSObject

- (instancetype)init:(DXFEnvironment *)initializator;

- (BOOL)write:(NSString *)key value:(NSString *)value;

- (nullable NSString *)read:(NSString *)key;


@end

NS_ASSUME_NONNULL_END
