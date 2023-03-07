//
//  DxFTimeSale.h
//  DxFeedFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#import <Foundation/Foundation.h>
#import <DxFeedFramework/DxFEvent.h>

NS_ASSUME_NONNULL_BEGIN

@interface DxFTimeSale : DxFEvent

@property (nonatomic, assign, readonly) int32_t event_flags;
@property (nonatomic, assign, readonly) int64_t index;
@property (nonatomic, assign, readonly) int32_t time_nano_part;
@property (nonatomic, assign, readonly) int16_t exchange_code;
@property (nonatomic, assign, readonly) double price;
@property (nonatomic, assign, readonly) double size;
@property (nonatomic, assign, readonly) double bid_price;
@property (nonatomic, assign, readonly) double ask_price;
@property (nonatomic, strong, readonly) NSString *exchange_sale_conditions;
@property (nonatomic, assign, readonly) int32_t flags;
@property (nonatomic, strong, readonly) NSString *buyer;
@property (nonatomic, strong, readonly) NSString *seller;

@end

NS_ASSUME_NONNULL_END
