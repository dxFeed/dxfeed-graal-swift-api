//
//  DXFEvent.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#import <Foundation/Foundation.h>
#import <DxFeedFramework/DXFEventType.h>

NS_ASSUME_NONNULL_BEGIN

@interface DXFEvent : NSObject

@property (nonatomic, assign, readonly) DXFEventType event_type;
@property (nonatomic, strong, readonly) NSString *event_symbol;
@property (nonatomic, assign, readonly) int64_t event_time;

@end

NS_ASSUME_NONNULL_END
