//
//  DxFSystem.h
//  TestGraalvm
//
//  Created by Aleksey Kosylo on 1/28/23.
//

#import <Foundation/Foundation.h>

@class DxFEnvironment;

NS_ASSUME_NONNULL_BEGIN

@interface DxFSystem : NSObject

- (instancetype)init:(DxFEnvironment *)env;

- (BOOL)write:(NSString *)value forKey:(NSString *)key;

- (nullable NSString *)read:(NSString *)key;


@end

NS_ASSUME_NONNULL_END
