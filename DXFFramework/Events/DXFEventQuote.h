//
//  DXFEventQuote.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/5/23.
//

#import <Foundation/Foundation.h>
#import <DXFFramework/DXFEvent.h>

NS_ASSUME_NONNULL_BEGIN

@interface DXFEventQuote : DXFEvent

@property (nonatomic, assign, readonly) NSInteger time_millis_sequence;
@property (nonatomic, assign, readonly) NSInteger time_nano_part;
@property (nonatomic, assign, readonly) NSInteger bid_time;
@property (nonatomic, assign, readonly) NSInteger bid_exchange_code;
@property (nonatomic, assign, readonly) NSInteger bid_price;
@property (nonatomic, assign, readonly) NSInteger bid_size;
@property (nonatomic, retain, readonly) NSString *ask_time;
@property (nonatomic, retain, readonly) NSString *ask_exchange_code;
@property (nonatomic, assign, readonly) NSInteger ask_price;
@property (nonatomic, assign, readonly) NSInteger ask_size;

@end

NS_ASSUME_NONNULL_END
