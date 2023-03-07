//
//  DxFEvent.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#import <Foundation/Foundation.h>
#import <DxFeedFramework/DxFEventType.h>

NS_ASSUME_NONNULL_BEGIN

@interface DxFEvent : NSObject

@property (nonatomic, assign, readonly) DxFEventType event_type;
@property (nonatomic, strong, readonly) NSString *event_symbol;
@property (nonatomic, assign, readonly) int64_t event_time;

@end

NS_ASSUME_NONNULL_END
