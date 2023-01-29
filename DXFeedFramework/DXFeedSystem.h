//
//  TestCppClass.h
//  TestGraalvm
//
//  Created by Aleksey Kosylo on 1/28/23.
//

#import <Foundation/Foundation.h>

@class DXFeedInitializator;

NS_ASSUME_NONNULL_BEGIN

@interface DXFeedSystem : NSObject

- (instancetype)init:(DXFeedInitializator *)initializator;

- (BOOL)write:(NSString *)key value:(NSString *)value;

- (NSString *)read:(NSString *)key;

- (void)testWriteRead;

@end

NS_ASSUME_NONNULL_END
