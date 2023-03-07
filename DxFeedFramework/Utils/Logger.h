//
//  Logger.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/1/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Logger : NSObject

+ (void)print:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
