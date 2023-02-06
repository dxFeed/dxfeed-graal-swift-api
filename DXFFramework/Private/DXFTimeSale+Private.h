//
//  DXFTimeSale+Private.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#import "DXFTimeSale.h"

NS_ASSUME_NONNULL_BEGIN

@interface DXFTimeSale ()

@property (nonatomic, assign) int32_t event_flags;
@property (nonatomic, assign) int64_t index;
@property (nonatomic, assign) int32_t time_nano_part;
@property (nonatomic, assign) int16_t exchange_code;
@property (nonatomic, assign) double price;
@property (nonatomic, assign) double size;
@property (nonatomic, assign) double bid_price;
@property (nonatomic, assign) double ask_price;
@property (nonatomic, retain) NSString *exchange_sale_conditions;
@property (nonatomic, assign) int32_t flags;
@property (nonatomic, retain) NSString *buyer;
@property (nonatomic, retain) NSString *seller;

- (instancetype)initWithItem:(dxfg_time_and_sale_t *)dxf_item;

@end

NS_ASSUME_NONNULL_END
