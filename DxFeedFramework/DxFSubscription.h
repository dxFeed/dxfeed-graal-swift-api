//
//  DxFSubscription.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 12.02.2023.
//

#import <Foundation/Foundation.h>
#import <DxFeedFramework/DxFEventType.h>

NS_ASSUME_NONNULL_BEGIN

@class DxFEnvironment, DxFFeed;
@protocol DxFSubscriptionListener;
@interface DxFSubscription : NSObject

@property (nonatomic, strong) NSArray *values;

- (instancetype)init:(DxFEnvironment *)env feed:(DxFFeed *)feed type:(DxFEventType)type;

- (void)addListener:(id<DxFSubscriptionListener>)listener;

- (void)removeListener:(id<DxFSubscriptionListener>)listener;

- (void)subscribe:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
