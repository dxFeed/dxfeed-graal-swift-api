//
//  DxFEventQuote.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/5/23.
//

#import <Foundation/Foundation.h>
#import <DxFeedFramework/DxFEvent.h>

NS_ASSUME_NONNULL_BEGIN

@interface DxFEventQuote : DxFEvent

@property (nonatomic, assign, readonly) int32_t time_millis_sequence;
@property (nonatomic, assign, readonly) int32_t time_nano_part;
@property (nonatomic, assign, readonly) int64_t bid_time;
@property (nonatomic, assign, readonly) int16_t bid_exchange_code;
@property (nonatomic, assign, readonly) double bid_price;
@property (nonatomic, assign, readonly) double bid_size;
@property (nonatomic, assign, readonly) int64_t ask_time;
@property (nonatomic, assign, readonly) int16_t ask_exchange_code;
@property (nonatomic, assign, readonly) double ask_price;
@property (nonatomic, assign, readonly) double ask_size;

@end

NS_ASSUME_NONNULL_END
