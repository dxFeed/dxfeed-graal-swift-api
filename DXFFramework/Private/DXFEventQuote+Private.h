//
//  DXFEventQuote+Private.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/5/23.
//

#import <DXFFramework/DXFFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface DXFEventQuote ()

@property (nonatomic, assign) NSInteger time_millis_sequence;
@property (nonatomic, assign) NSInteger time_nano_part;
@property (nonatomic, assign) NSInteger bid_time;
@property (nonatomic, assign) NSInteger bid_exchange_code;
@property (nonatomic, assign) NSInteger bid_price;
@property (nonatomic, assign) NSInteger bid_size;
@property (nonatomic, retain) NSString *ask_time;
@property (nonatomic, retain) NSString *ask_exchange_code;
@property (nonatomic, assign) NSInteger ask_price;
@property (nonatomic, assign) NSInteger ask_size;

@end

NS_ASSUME_NONNULL_END
