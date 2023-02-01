//
//  DXFSystem.h
//  TestGraalvm
//
//  Created by Aleksey Kosylo on 1/28/23.
//

#import <Foundation/Foundation.h>
#import "DXFControl.h"

@class DXFEnvironment;

NS_ASSUME_NONNULL_BEGIN

@interface DXFSystem : NSObject <DXFControl>

- (BOOL)write:(NSString *)value forKey:(NSString *)key;

- (nullable NSString *)read:(NSString *)key;


@end

NS_ASSUME_NONNULL_END
