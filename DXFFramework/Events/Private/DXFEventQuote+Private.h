//
//  DXFEventQuote+Private.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/5/23.
//

#import <DXFFramework/DXFFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface DXFEventQuote ()

@property (nonatomic, assign) int32_t time_millis_sequence;
@property (nonatomic, assign) int32_t time_nano_part;
@property (nonatomic, strong) NSDate * bid_time;
@property (nonatomic, assign) int16_t bid_exchange_code;
@property (nonatomic, assign) double bid_price;
@property (nonatomic, assign) double bid_size;
@property (nonatomic, strong) NSDate * ask_time;
@property (nonatomic, assign) int16_t ask_exchange_code;
@property (nonatomic, assign) double ask_price;
@property (nonatomic, assign) double ask_size;

- (instancetype)initWithItem:(dxfg_event_type_t *)item;


@end

NS_ASSUME_NONNULL_END
