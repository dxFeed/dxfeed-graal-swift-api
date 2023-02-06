//
//  DXFEvent+Private.h
//  DXFFramework
//
//  Created by Aleksey Kosylo on 2/6/23.
//

#import <DXFFramework/DXFFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface DXFEvent ()

@property (nonatomic, assign) DXFEventType event_type;
@property (nonatomic, retain) NSString *event_symbol;
@property (nonatomic, assign) int64_t event_time;

@end

NS_ASSUME_NONNULL_END
