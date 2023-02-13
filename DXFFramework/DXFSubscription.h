//
//  DXFSubscription.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 12.02.2023.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DXFEnvironment, DXFFeed;
@protocol DXFSubscriptionListener;
@interface DXFSubscription : NSObject

@property (nonatomic, strong) NSArray *values;

- (instancetype)init:(DXFEnvironment *)env feed:(DXFFeed *)feed;

- (void)addListener:(id<DXFSubscriptionListener>)listener;

- (void)removeListener:(id<DXFSubscriptionListener>)listener;

- (void)subscribe:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
